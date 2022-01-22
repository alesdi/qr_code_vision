import 'package:flutter_test/flutter_test.dart';
import 'package:qr_code_vision/entities/position.dart';
import 'package:qr_code_vision/entities/qr_location.dart';
import 'package:qr_code_vision/locator/locator.dart';

import 'helpers.dart';

void main() {
  const imagesPath = "./test/locator-test-data/";
  test('handles images with missing finder patterns', () {
    final binarized = loadBinarized("$imagesPath/missing-finder-patterns.png");
    final locator = Locator();

    expect(locator.locate(binarized), null);
  });

  test('locates a "perfect" image', () {
    final binarized = loadBinarized("$imagesPath/perfect.png");
    final locator = Locator();

    expect(
      locator.locate(binarized)!,
      QrLocation(
        topRight: Position(173.5, 3.5),
        bottomLeft: Position(3.5, 173.5),
        topLeft: Position(3.5, 3.5),
        alignmentPattern: Position(170.5, 170.5),
        dimension: QrDimension(size: 177, module: 1),
      ),
    );
  });

  test('locates a QR in a real world image', () {
    final binarized = loadBinarized("$imagesPath/real-world.png");
    final locator = Locator();

    expect(
      locator.locate(binarized)!,
      QrLocation(
        topRight: Position(270.75, 107.5),
        bottomLeft: Position(195.5, 191.5),
        topLeft: Position(191.75, 113.5),
        alignmentPattern: Position(264.25, 177),
        dimension: QrDimension(size: 33, module: 3.1144707209550013),
      ),
    );
  });

  test('locates a small QR code in real world photo', () {
    final binarized = loadBinarized("$imagesPath/small-photo.png");
    final locator = Locator();

    expect(
      locator.locate(binarized)!,
      QrLocation(
        topRight: Position(108, 118),
        bottomLeft: Position(73.5, 152),
        topLeft: Position(74, 117.5),
        alignmentPattern: Position(103, 147.5),
        dimension: QrDimension(size: 29, module: 1.5357142857142858),
      ),
    );
  });

  test('locates a extremely distored QR code', () {
    final binarized = loadBinarized("$imagesPath/distorted-extreme.png");
    final locator = Locator();

    expect(
      locator.locate(binarized)!,
      QrLocation(
        topRight: Position(122.75, 105),
        bottomLeft: Position(221.5, 18.5),
        topLeft: Position(180.5, 101),
        alignmentPattern: Position(164.5, 39),
        dimension: QrDimension(size: 25, module: 4.306136459723239),
      ),
    );
  });

  test('locates a damaged QR code and guesses the finder pattern location', () {
    final binarized = loadBinarized("$imagesPath/damaged.png");
    final locator = Locator();

    expect(
      locator.locate(binarized)!,
      QrLocation(
        topRight: Position(221.75, 76),
        bottomLeft: Position(81.5, 215.5),
        topLeft: Position(82, 75.5),
        alignmentPattern: Position(219.75, 221),
        dimension: QrDimension(size: 29, module: 6.321428571428571),
      ),
    );
  });

  test('doesn\'t locate a QR code in a malformed image', () {
    final binarized = loadBinarized("$imagesPath/malformed-infinity.png");
    final locator = Locator();

    expect(locator.locate(binarized), null);
  });

  test('returns a centered alignment as a fallback', () {
    final binarized = loadBinarized("$imagesPath/odd-skew.png");
    final locator = Locator();

    expect(
      locator.locate(binarized, recenterLocation: true)!,
      QrLocation(
        topRight: Position(185.5, 57.5),
        bottomLeft: Position(56.5, 185.5),
        topLeft: Position(57, 60),
        alignmentPattern: Position(163.5, 170),
        dimension: QrDimension(size: 29, module: 5.788670090367794),
      ),
    );
  });
}
