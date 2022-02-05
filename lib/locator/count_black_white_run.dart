// Takes an origin point and an end point and counts the sizes of the black white run in the origin point
// along the line that intersects with the end point. Returns an array of elements, representing the pixel sizes
// of the black white run. Takes a length which represents the number of switches from black to white to look for.
import 'package:qr_code_vision/entities/bit_matrix.dart';
import 'package:qr_code_vision/entities/position.dart';

import 'count_black_white_run_towards_point.dart';

List<double> countBlackWhiteRun({
  required final Position<double> origin,
  required final Position<double> end,
  required final BitMatrix matrix,
  required final int length,
}) {
  final rise = end.y - origin.y;
  final run = end.x - origin.x;

  final towardsEnd = countBlackWhiteRunTowardsPoint(
    origin,
    end,
    matrix,
    (length / 2).ceil(),
  );

  final awayFromEnd = countBlackWhiteRunTowardsPoint(
    origin,
    Position<double>(origin.x - run, origin.y - rise),
    matrix,
    (length / 2).ceil(),
  );

  final middleValue = towardsEnd.removeAt(0) +
      awayFromEnd.removeAt(0) -
      1; // Substract one so we don't double count a pixel
  return [...awayFromEnd, middleValue, ...towardsEnd];
}
