import 'package:qr_code_vision/entities/position.dart';
import 'package:qr_code_vision/entities/qr_location.dart';
import 'package:qr_code_vision/extractor/extractor.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  const imagesPath = "./test/extractor_test_data/";
  test('is a no-op when applied to an already extracted code', () {
    final data = loadBinarized("$imagesPath/output.png");

    final extracted = extract(
        data,
        QrLocation(
          topLeft: Position<double>(3.5, 3.5),
          bottomLeft: Position<double>(3.5, 21.5),
          topRight: Position<double>(21.5, 3.5),
          alignmentPattern: Position<double>(18.5, 18.5),
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
          topLeft: Position<double>(56, 94),
          bottomLeft: Position<double>(88, 268),
          topRight: Position<double>(275, 175),
          alignmentPattern: Position<double>(197, 315),
          dimension: QrDimension(size: 25, module: 1),
        ));

    expect(extracted.matrix, expected);
  });
}
