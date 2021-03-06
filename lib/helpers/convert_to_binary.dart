import 'dart:math' as math;
import 'dart:typed_data';

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
      final r = data[((y * width + x) * 4) + 0];
      final g = data[((y * width + x) * 4) + 1];
      final b = data[((y * width + x) * 4) + 2];
      greyScalePixels.set(x, y, (0.2126 * r + 0.7152 * g + 0.0722 * b).toInt());
    }
  }
  final horizontalRegionCount = (width / REGION_SIZE).floor();
  final verticalRegionCount = (height / REGION_SIZE).floor();

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

  final binarized = BitMatrix.createEmpty(width, height);

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
  _GrayScaleMatrix(this.width, int height)
      : data = Uint8ClampedList(width * height);

  int get(int x, int y) {
    return data[y * width + x];
  }

  void set(int x, int y, int value) {
    data[y * width + x] = value;
  }
}
