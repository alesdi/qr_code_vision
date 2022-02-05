library flutter_qr_tracker;

import 'dart:typed_data';

import 'package:qr_code_vision/binarizer/convert_to_binary.dart';
import 'package:qr_code_vision/decoder/decode_data.dart';
import 'package:qr_code_vision/decoder/decoder.dart';
import 'package:qr_code_vision/entities/bit_matrix.dart';
import 'package:qr_code_vision/entities/qr_location.dart';
import 'package:qr_code_vision/locator/locator.dart';

import 'extractor/extractor.dart';

export 'entities/bit_matrix.dart' show BitMatrix;
export 'entities/qr_location.dart' show QrLocation, QrDimension;

class QrCode {
  final int staleContentLimit;
  QrContent? _content;
  QrLocation? _location;

  int _staleCounter = 0;

  QrCode({this.staleContentLimit = 10});

  QrContent? get content => _content;
  QrLocation? get location => _location;

  scanBitMatrix(BitMatrix matrix, {bool forceDecode = false}) {
    // Keep old content as default, unless stale or forceDecode is true
    QrContent? newContent;

    if (!forceDecode && _staleCounter < staleContentLimit) {
      newContent = _content;
      _staleCounter++;
    } else {
      _staleCounter = 0;
    }

    // Get new location
    // TODO: Evaluate whether the new location is realistic
    // Consider using the old location instead or interpolating
    _location = locate(matrix) ?? _location;
    if (_location != null) {
      // Get new content
      final extractedQrCode = extract(matrix, _location!);
      newContent = decode(extractedQrCode.matrix);
    }

    _content = newContent;
  }

  scanRgbaBytes(Uint8List bytes, int width, int height) {
    return convertToBinary(bytes, width, height);
  }
}
