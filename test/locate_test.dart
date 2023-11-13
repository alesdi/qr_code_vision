import 'package:qr_code_vision/entities/position.dart';
import 'package:qr_code_vision/entities/qr_location.dart';
import 'package:qr_code_vision/locate/locate.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  const imagesPath = "./test/locator_test_data/";
  group("Locator", () {
    test('handles images with missing finder patterns', () {
      final binarized =
          loadBinarized("$imagesPath/missing-finder-patterns.png");

      expect(locate(binarized), null);
    });

    test('locates a "perfect" image', () {
      final binarized = loadBinarized("$imagesPath/perfect.png");

      expect(
        locate(binarized)!,
        QrLocation(
          topRight: Position<double>(173.5, 3.5),
          bottomLeft: Position<double>(3.5, 173.5),
          topLeft: Position<double>(3.5, 3.5),
          alignmentPattern: Position<double>(170.5, 170.5),
          dimension: QrDimension(size: 177, module: 1),
        ),
      );
    });

    test('locates a QR in a real world image', () {
      final binarized = loadBinarized("$imagesPath/real-world.png");

      expect(
        locate(binarized)!,
        QrLocation(
          topRight: Position<double>(270.75, 107.5),
          bottomLeft: Position<double>(195.5, 191.5),
          topLeft: Position<double>(191.75, 113.5),
          alignmentPattern: Position<double>(264.25, 177),
          dimension: QrDimension(size: 33, module: 3.1144707209550013),
        ),
      );
    });

    test('locates a small QR code in real world photo', () {
      final binarized = loadBinarized("$imagesPath/small-photo.png");

      expect(
        locate(binarized)!,
        QrLocation(
          topRight: Position<double>(108, 118),
          bottomLeft: Position<double>(73.5, 152),
          topLeft: Position<double>(74, 117.5),
          alignmentPattern: Position<double>(103, 147.5),
          dimension: QrDimension(size: 29, module: 1.5357142857142858),
        ),
      );
    });

    test('locates a extremely distorted QR code', () {
      final binarized = loadBinarized("$imagesPath/distorted-extreme.png");

      expect(
        locate(binarized)!,
        QrLocation(
          topRight: Position<double>(122.75, 105),
          // bottomLeft: (221.5, 18.5) would be better but optimizing for it
          // by allowing a higher variance in _isFinderPattern degrades the
          // performance for less distorted QR codes
          bottomLeft: Position<double>(217.5, 24.5),
          topLeft: Position<double>(179.75, 101.5),
          alignmentPattern: Position<double>(164.5, 39),
          dimension: QrDimension(size: 23, module: 4.307884947045186),
        ),
      );
    });

    test('locates a damaged QR code and guesses the finder pattern location',
        () {
      final binarized = loadBinarized("$imagesPath/damaged.png");

      expect(
        locate(binarized)!,
        QrLocation(
          topRight: Position<double>(221.75, 76),
          bottomLeft: Position<double>(81.5, 215.5),
          topLeft: Position<double>(82, 75.5),
          alignmentPattern: Position<double>(219.75, 221),
          dimension: QrDimension(size: 29, module: 6.321428571428571),
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
        locate(binarized, recenterLocation: true)!,
        QrLocation(
          topRight: Position<double>(185.5, 57.5),
          bottomLeft: Position<double>(56.5, 185.5),
          topLeft: Position<double>(57, 60),
          alignmentPattern: Position<double>(163.5, 170),
          dimension: QrDimension(size: 29, module: 5.785714285714286),
        ),
      );
    });
  });
}
