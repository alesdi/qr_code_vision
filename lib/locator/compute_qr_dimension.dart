// Computes the dimension (number of modules on a side) of the QR Code based on the position of the finder patterns
import 'package:qr_code_vision/entities/position.dart';
import 'package:qr_code_vision/entities/qr_location.dart';

import '../entities/bit_matrix.dart';
import 'count_black_white_run.dart';

QrDimension? computeQrDimension({
  required final Position<double> topLeft,
  required final Position<double> topRight,
  required final Position<double> bottomLeft,
  required final BitMatrix matrix,
}) {
  // Compute the size of finder patterns along multiple directions
  // vertical and horizontal directions, assuming that each finder pattern
  // can be recognized in any direction as a sequence of 5 alternating black and
  // white modules.
  final topLeftVertical = countBlackWhiteRun(
    origin: topLeft,
    end: bottomLeft,
    matrix: matrix,
    length: 5,
  ).reduce((a, b) => a + b);

  final topLeftHorizontal = countBlackWhiteRun(
    origin: topLeft,
    end: topRight,
    matrix: matrix,
    length: 5,
  ).reduce((a, b) => a + b);

  final bottomLeftVertical = countBlackWhiteRun(
    origin: bottomLeft,
    end: topLeft,
    matrix: matrix,
    length: 5,
  ).reduce((a, b) => a + b);

  final topRightHorizontal = countBlackWhiteRun(
    origin: topRight,
    end: topLeft,
    matrix: matrix,
    length: 5,
  ).reduce((a, b) => a + b);

  // Make sure the measures make sense (each measure must be at least 7,
  // given that a finder pattern is 7 x 7 modules)
  if (topLeftVertical < 7 ||
      topLeftHorizontal < 7 ||
      bottomLeftVertical < 7 ||
      topRightHorizontal < 7) {
    return null;
  }

  // Find the module dimension from the average of the finder pattern sizes
  final double module = (topLeftVertical +
          topLeftHorizontal +
          bottomLeftVertical +
          topRightHorizontal) /
      4 /
      7;

  final topSize = (topLeft.distanceTo(topRight) / module).round();
  final sideSize = (topLeft.distanceTo(bottomLeft) / module).round();
  int size = ((topSize + sideSize) / 2).floor() + 7;
  switch (size % 4) {
    case 0:
      size++;
      break;
    case 2:
      size--;
      break;
  }
  return QrDimension(size: size, module: module);
}
