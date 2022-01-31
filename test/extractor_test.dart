import 'package:flutter_test/flutter_test.dart';
import 'package:qr_code_vision/entities/position.dart';
import 'package:qr_code_vision/entities/qr_location.dart';
import 'package:qr_code_vision/extractor/extractor.dart';

import 'helpers.dart';

void main() {
  const imagesPath = "./test/extractor-test-data/";
  test('is a no-op when applied to an already extracted code', () {
    final data = loadBinarized("$imagesPath/output.png");

    final extracted = extract(
        data,
        QrLocation(
          topLeft: Position(3.5, 3.5),
          bottomLeft: Position(3.5, 21.5),
          topRight: Position(21.5, 3.5),
          alignmentPattern: Position(18.5, 18.5),
          dimension: QrDimension(size: 25, module: 1),
        ));

    expect(extracted.matrix, data);
  });

  test('extracts a distorted QR code', () {
    final input = loadBinarized("$imagesPath/input.png");
    final expected = loadBinarized("$imagesPath/output.png");

    final extracted = extract(
        input,
        QrLocation(
          topLeft: Position(56, 94),
          bottomLeft: Position(88, 268),
          topRight: Position(275, 175),
          alignmentPattern: Position(197, 315),
          dimension: QrDimension(size: 25, module: 1),
        ));

    expect(extracted.matrix, expected);
  });
}
