import 'package:qr_code_vision/helpers/perspective_transform.dart';
import 'package:test/test.dart';

void main() {
  test('Compute the inverse transform', () {
    final matrix = PerspectiveTransform([1, 2, 3, 4, 5, 6, 7, 8, 9]);
    final adjoint = matrix.inverse();

    expect(adjoint, PerspectiveTransform([-3, 6, -3, 6, -12, 6, -3, 6, -3]));
  });
}
