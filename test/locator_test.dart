import 'package:flutter_test/flutter_test.dart';
import 'package:qr_code_vision/locator/locator.dart';

import 'helpers.dart';

void main() {
  test('Locate qr code', () {
    final Set<QRLocation> testLocations = {
      QRLocation(Point(58.5, 240.5), Point(58.5, 240.5), Point(58.5, 58.5),
          Point(170.5, 240.5), 33.0),
      QRLocation(Point(58.0, 240.0), Point(58.0, 240.0), Point(58.0, 58.0),
          Point(170.5, 240.5), 33.0),
    };

    // Load image from path
    const path = "test/images/small_flat.png";
    final matrix = loadBinarized(path);
    final locations = locate(matrix);

    expect(locations, testLocations);
  });
}
