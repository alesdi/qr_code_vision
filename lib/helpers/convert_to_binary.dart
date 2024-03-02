import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart';

import 'bit_matrix.dart';

const REGION_SIZE = 8;
const MIN_DYNAMIC_RANGE = 24;

/// Convert a List of image bytes into a 2D matrix of bits representing
/// black and white pixels
BitMatrix convertToBinary(
  Uint8List data,
  int width,
  int height, {
  bool returnInverted = false,
}) {
  if (data.length != width * height * 4) {
    throw Exception("Malformed data passed to convertToBinary.");
  }

  // Convert image to grey scale
  final greyScalePixels = _GrayScaleMatrix(width, height);
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      final pixelIndex = (y * width + x) * 4;
      final r = data[pixelIndex + 0];
      final g = data[pixelIndex + 1];
      final b = data[pixelIndex + 2];
      final a = data[pixelIndex + 3];

      greyScalePixels.set(x, y, _calculateGrayscaleLuminance(r, g, b, a));
    }
  }
  return _convertGrayScaleToBinary(greyScalePixels, returnInverted);
}

BitMatrix convertImageToBinary(
  Image image, {
  bool returnInverted = false,
}) {
  // Convert image to gray scale, but add a white margin with 12px on each side.
  // Without the margin, the gray scale to bitmap conversion will misclassify
  // some black pixels in a perfect QR code as 0-bit's.
  // A perfect QR code has only black (#000000) or white (#FFFFFF) pixels and
  // no white margin.
  // I'm not sure why exactly that happens but probably it's caused by the averaging
  // when applied to regions that are mostly black like,
  // the position-pattern-squares in the corners of the QR code.
  final grayScalePixels = _GrayScaleMatrix(image.width + 24, image.height + 24);
  grayScalePixels.setAll(255);
  for (Pixel pixel in image) {
    grayScalePixels.set(
        pixel.x,
        pixel.y,
        _calculateGrayscaleLuminance(
            pixel.r, pixel.g, pixel.b, image.hasAlpha ? pixel.a : 255));
  }
  return _convertGrayScaleToBinary(grayScalePixels, returnInverted);
}

/// Convert RGB into perceptual luminance-preserving grayscale
int _calculateGrayscaleLuminance(num r, num g, num b, num a) {
  // Remove alpha channel by blending the image on a white background
  final normalizedAlpha = a / 255.0;
  final backgroundFraction = 255.0 * (1 - normalizedAlpha);
  final blendedR = r * normalizedAlpha + backgroundFraction;
  final blendedG = g * normalizedAlpha + backgroundFraction;
  final blendedB = b * normalizedAlpha + backgroundFraction;

  // Calculate luminance (https://en.wikipedia.org/wiki/Grayscale)
  return (0.2126 * blendedR + 0.7152 * blendedG + 0.0722 * blendedB).toInt();
}

BitMatrix _convertGrayScaleToBinary(
    _GrayScaleMatrix greyScalePixels, bool returnInverted) {
  final horizontalRegionCount = (greyScalePixels.width / REGION_SIZE).floor();
  final verticalRegionCount = (greyScalePixels.height / REGION_SIZE).floor();

  final blackPoints =
      _GrayScaleMatrix(horizontalRegionCount, verticalRegionCount);
  for (int verticalRegion = 0;
      verticalRegion < verticalRegionCount;
      verticalRegion++) {
    for (int hortizontalRegion = 0;
        hortizontalRegion < horizontalRegionCount;
        hortizontalRegion++) {
      double sum = 0;
      double min = double.infinity;
      double max = 0;
      for (int y = 0; y < REGION_SIZE; y++) {
        for (int x = 0; x < REGION_SIZE; x++) {
          final pixelLumosity = greyScalePixels
              .get(hortizontalRegion * REGION_SIZE + x,
                  verticalRegion * REGION_SIZE + y)
              .toDouble();
          sum += pixelLumosity;
          min = math.min(min, pixelLumosity);
          max = math.max(max, pixelLumosity);
        }
      }

      double average = sum / math.pow(REGION_SIZE, 2);
      if (max - min <= MIN_DYNAMIC_RANGE) {
        // If variation within the block is low, assume this is a block with only light or only
        // dark pixels. In that case we do not want to use the average, as it would divide this
        // low contrast area into black and white pixels, essentially creating data out of noise.
        //
        // Default the blackpoint for these blocks to be half the min - effectively white them out
        average = min / 2;

        if (verticalRegion > 0 && hortizontalRegion > 0) {
          // Correct the "white background" assumption for blocks that have neighbors by comparing
          // the pixels in this block to the previously calculated black points. This is based on
          // the fact that dark barcode symbology is always surrounded by some amount of light
          // background for which reasonable black point estimates were made. The bp estimated at
          // the boundaries is used for the interior.

          // The (min < bp) is arbitrary but works better than other heuristics that were tried.
          final averageNeighborBlackPoint = (blackPoints.get(
                      hortizontalRegion, verticalRegion - 1) +
                  (2 * blackPoints.get(hortizontalRegion - 1, verticalRegion)) +
                  blackPoints.get(hortizontalRegion - 1, verticalRegion - 1)) /
              4;
          if (min < averageNeighborBlackPoint) {
            average = averageNeighborBlackPoint;
          }
        }
      }
      blackPoints.set(hortizontalRegion, verticalRegion, average.toInt());
    }
  }

  final binarized =
      BitMatrix.createEmpty(greyScalePixels.width, greyScalePixels.height);

  for (int verticalRegion = 0;
      verticalRegion < verticalRegionCount;
      verticalRegion++) {
    for (int hortizontalRegion = 0;
        hortizontalRegion < horizontalRegionCount;
        hortizontalRegion++) {
      final left = _isBetween(hortizontalRegion, 2, horizontalRegionCount - 3);
      final top = _isBetween(verticalRegion, 2, verticalRegionCount - 3);
      int sum = 0;
      for (int xRegion = -2; xRegion <= 2; xRegion++) {
        for (int yRegion = -2; yRegion <= 2; yRegion++) {
          sum += blackPoints.get(left + xRegion, top + yRegion);
        }
      }
      final threshold = sum / 25;
      for (int xRegion = 0; xRegion < REGION_SIZE; xRegion++) {
        for (int yRegion = 0; yRegion < REGION_SIZE; yRegion++) {
          final x = hortizontalRegion * REGION_SIZE + xRegion;
          final y = verticalRegion * REGION_SIZE + yRegion;
          final lum = greyScalePixels.get(x, y);
          if (returnInverted) {
            binarized.set(x, y, !(lum <= threshold));
          } else {
            binarized.set(x, y, lum <= threshold);
          }
        }
      }
    }
  }
  return binarized;
}

int _isBetween(int value, int min, int max) {
  return value < min
      ? min
      : value > max
          ? max
          : value;
}

class _GrayScaleMatrix {
  final Uint8ClampedList data;
  final int width;
  final int height;

  _GrayScaleMatrix(this.width, this.height)
      : data = Uint8ClampedList(width * height);

  int get(int x, int y) {
    return data[y * width + x];
  }

  void set(int x, int y, int value) {
    data[y * width + x] = value;
  }

  void setAll(int value) {
    data.fillRange(0, data.length - 1, value);
  }
}

/// Converts the image into a bit matrix with one bit per pixel.
/// A bit is set (1) when the corresponding pixel in the image is black.
/// Otherwise the pixel is unset (0).
/// A pixel is considered black if its red, green and blue channel are zero
/// and it's alpha channel, if present, is 255.
BitMatrix convertBlackWhiteImageToBinary(Image image) {
  final out = BitMatrix.createEmpty(image.width, image.height);
  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      out.set(x, y, _isBlackPixel(image, x, y));
    }
  }
  return out;
}

bool _isBlackPixel(Image image, int x, int y) {
  final pixel = image.getPixel(x, y);
  if (image.hasAlpha && pixel.a != 255) {
    return false;
  }
  return pixel.r == 0 && pixel.g == 0 && pixel.b == 0;
}

class BmpInfoWithAlphaChannel extends BmpDecoder {

}