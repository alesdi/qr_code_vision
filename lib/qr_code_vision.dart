library flutter_qr_tracker;

import 'dart:typed_data';

import 'package:image/image.dart';
import 'package:qr_code_vision/helpers/image_format_repair.dart';

import 'decode/decode.dart';
import 'decode/decode_data.dart';
import 'entities/position.dart';
import 'entities/qr_location.dart';
import 'helpers/bit_matrix.dart';
import 'helpers/convert_to_binary.dart';
import 'locate/locate.dart';

export 'entities/qr_location.dart' show QrLocation, QrDimension;

/// A QR code captured from images (e.g. the frames of a camera stream),
/// with its location and content.
class QrCode {
  /// The number the number of times the content is kept as valid when
  /// decoding fails.
  final int contentCacheLimit;

  QrContent? _content;
  QrLocation? _location;
  int _staleCounter = 0;

  /// The content of the QR code.
  QrContent? get content => _content;

  /// The location of the QR code.
  QrLocation? get location => _location;

  /// Initializes a new QR code.
  /// [contentCacheLimit] is the number of times the content is kept as valid
  /// when decoding fails.
  QrCode({this.contentCacheLimit = 10});

  /// Scan a BitMatrix to update QR code content and location.
  scanBitMatrix(
    BitMatrix matrix, {
    bool invalidateContent = false,
    bool ignoreIfUnreadable = false,
    bool perfectQrCode = false,
  }) {
    // Keep old content as default, unless stale or forceDecode is true
    QrContent? newContent;

    // Get new location
    // TODO: Evaluate whether the new location is realistic
    // Consider using the old location instead or interpolating
    final newLocation = locate(matrix, perfectQrCode: perfectQrCode);
    if (newLocation != null) {
      newContent = decode(_extract(matrix, newLocation));
    }

    // Handle content caching
    if (invalidateContent || _staleCounter >= contentCacheLimit) {
      _staleCounter = 0;
    } else {
      // If content could not be decoded, keep the old value
      if (newContent == null) {
        newContent = _content;
      }

      _staleCounter++;
    }

    // If the ignoreIfUnreadable flag is set, and the content could not be
    // decoded, do not update the content nor the location.
    if (ignoreIfUnreadable) {
      if (newContent == null) {
        return;
      }
    }

    // Update content and location
    _content = newContent;
    _location = newLocation;
  }

  /// Scan an image encoded as a Uint8List of RGBA values to update QR code
  /// content and location.
  scanRgbaBytes(
    Uint8List bytes,
    int width,
    int height, {
    bool ignoreIfUnreadable = false,
  }) {
    scanBitMatrix(convertToBinary(bytes, width, height));
  }

  /// Scan an encoded image in any format supported by the dart image library
  /// to update QR code and location
  scanImageBytes(Uint8List bytes) {
    final image = decodeImage(bytes);
    scanImage(image);
    if (location == null && couldBeQRCodeBMPWithHiddenTransparency(bytes)) {
      scanImage(fixQRCodeBMPWithHiddenTransparency(bytes));
    }
  }

  scanImage(Image? image) {
    if (image == null) {
      return;
    }
    // First pass: Simple black/white conversion. Only works with "perfect" QR codes.
    // E.g. if it's the original QR code image file or the QR code is captured as a screenshot.
    scanBitMatrix(convertBlackWhiteImageToBinary(image), perfectQrCode: true);
    if (location != null && content != null) {
      return;
    }
    // Second pass: Convert the image to gray scale and then to a bit matrix
    // while considering regional luminance. Works better for QR codes
    // that are captured with a physical camera but sometimes fails
    // for "perfect" QR codes.
    scanBitMatrix(convertImageToBinary(image));
  }

  /// Extract the raw content of the QR code from an image BitMatrix, given
  /// the location.
  BitMatrix _extract(BitMatrix matrix, QrLocation location) {
    final transformed =
        BitMatrix.createEmpty(location.dimension.size, location.dimension.size);

    final transformation = location.computePerspectiveTransform();

    for (int y = 0; y < location.dimension.size; y++) {
      for (int x = 0; x < location.dimension.size; x++) {
        final xValue = x + 0.5;
        final yValue = y + 0.5;
        final sourcePixel = transformation.apply(Position(xValue, yValue));
        transformed.set(
            x, y, matrix.get(sourcePixel.x.floor(), sourcePixel.y.floor()));
      }
    }

    return transformed;
  }
}
