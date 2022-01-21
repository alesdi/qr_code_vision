import 'package:flutter_test/flutter_test.dart';
import 'package:qr_code_vision/locator/locator.dart';

import 'helpers.dart';

void main() {
  const imagesPath = "./test/locator-test-data/";
  test('handles images with missing finder patterns', () {
    final binarized = loadBinarized("$imagesPath/missing-finder-patterns.png");
    expect(locate(binarized), null);
  });

  test('locates a "perfect" image', () {
    final binarized = loadBinarized("$imagesPath/perfect.png");
    expect(
      locate(binarized)![0],
      QRLocation(
        topRight: Point(173.5, 3.5),
        bottomLeft: Point(3.5, 173.5),
        topLeft: Point(3.5, 3.5),
        alignmentPattern: Point(170.5, 170.5),
        dimension: 177,
      ),
    );
  });

  test('locates a QR in a real world image', () {
    final binarized = loadBinarized("$imagesPath/real-world.png");
    expect(
      locate(binarized)![0],
      QRLocation(
        topRight: Point(270.75, 107.5),
        bottomLeft: Point(195.5, 191.5),
        topLeft: Point(191.75, 113.5),
        alignmentPattern: Point(264.25, 177),
        dimension: 33,
      ),
    );
  });

  test('locates a small QR code in real world photo', () {
    final binarized = loadBinarized("$imagesPath/small-photo.png");

    expect(
      locate(binarized)![0],
      QRLocation(
        topRight: Point(108, 118),
        bottomLeft: Point(73.5, 152),
        topLeft: Point(74, 117.5),
        alignmentPattern: Point(103, 147.5),
        dimension: 29,
      ),
    );
  });

  test('locates a extremely distored QR code', () {
    final binarized = loadBinarized("$imagesPath/distorted-extreme.png");

    expect(
      locate(binarized)![0],
      QRLocation(
        topRight: Point(122.75, 105),
        bottomLeft: Point(221.5, 18.5),
        topLeft: Point(180.5, 101),
        alignmentPattern: Point(164.5, 39),
        dimension: 25,
      ),
    );
  });

  test('locates a damaged QR code and guesses the finder pattern location', () {
    final binarized = loadBinarized("$imagesPath/damaged.png");
    expect(
      locate(binarized)![0],
      QRLocation(
        topRight: Point(221.75, 76),
        bottomLeft: Point(81.5, 215.5),
        topLeft: Point(82, 75.5),
        alignmentPattern: Point(219.75, 221),
        dimension: 29,
      ),
    );
  });

  test('doesn\'t locate a QR code in a malformed image', () {
    final binarized = loadBinarized("$imagesPath/malformed-infinity.png");

    expect(locate(binarized), null);
  });

  test('returns a centered alignment as a fallback', () {
    final binarized = loadBinarized("$imagesPath/odd-skew.png");

    expect(
      locate(binarized)![1],
      QRLocation(
        topRight: Point(185.5, 57.5),
        bottomLeft: Point(56.5, 185.5),
        topLeft: Point(57, 60),
        alignmentPattern: Point(163.5, 170),
        dimension: 29,
      ),
    );
  });
}
