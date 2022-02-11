import 'package:qr_code_vision/locator/locator.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  const imagesPath = "./test/locator_test_data/";
  test('apply an image', () {
    final binarized = loadBinarized("$imagesPath/missing-finder-patterns.png");

    expect(locate(binarized), null);
  });
}
