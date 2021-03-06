// Takes an origin point and an end point and counts the sizes of the black white run in the origin point
// along the line that intersects with the end point. Returns an array of elements, representing the pixel sizes
// of the black white run. Takes a length which represents the number of switches from black to white to look for.
import 'package:qr_code_vision/entities/position.dart';
import 'package:qr_code_vision/helpers/bit_matrix.dart';

/// Count changes between black and white segments in a BitMatrix along a given
/// segment.
List<double> countBlackWhiteRun({
  required final Position<double> origin,
  required final Position<double> end,
  required final BitMatrix matrix,
  required final int length,
}) {
  final rise = end.y - origin.y;
  final run = end.x - origin.x;

  final towardsEnd = _countBlackWhiteRunTowardsPoint(
    origin,
    end,
    matrix,
    (length / 2).ceil(),
  );

  final awayFromEnd = _countBlackWhiteRunTowardsPoint(
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

List<double> _countBlackWhiteRunTowardsPoint(final Position<double> origin,
    final Position<double> end, final BitMatrix matrix, final int length) {
  final List<Position<double>> switchPoints = [
    Position<double>(origin.x.floorToDouble(), origin.y.floorToDouble())
  ];
  final steep = (end.y - origin.y).abs() > (end.x - origin.x).abs();

  final int fromX;
  final int fromY;
  final int toX;
  final int toY;
  if (steep) {
    fromX = (origin.y).floor();
    fromY = (origin.x).floor();
    toX = (end.y).floor();
    toY = (end.x).floor();
  } else {
    fromX = (origin.x).floor();
    fromY = (origin.y).floor();
    toX = (end.x).floor();
    toY = (end.y).floor();
  }

  final dx = (toX - fromX).abs();
  final dy = (toY - fromY).abs();
  var error = (-dx / 2).floor();
  final xStep = fromX < toX ? 1 : -1;
  final yStep = fromY < toY ? 1 : -1;

  var currentPixel = true;
  // Loop up until x == toX, but not beyond
  for (var x = fromX, y = fromY; x != toX + xStep; x += xStep) {
    // Does current pixel mean we have moved white to black or vice versa?
    // Scanning black in state 0,2 and white in state 1, so if we find the wrong
    // color, advance to next state or end if we are in state 2 already
    final realX = steep ? y : x;
    final realY = steep ? x : y;
    if (matrix.get(realX, realY) != currentPixel) {
      currentPixel = !currentPixel;
      switchPoints.add(Position<double>(realX.toDouble(), realY.toDouble()));
      if (switchPoints.length == length + 1) {
        break;
      }
    }
    error += dy;
    if (error > 0) {
      if (y == toY) {
        break;
      }
      y += yStep;
      error -= dx;
    }
  }
  final List<double> distances = [];
  for (var i = 0; i < length; i++) {
    if (i < switchPoints.length - 1) {
      distances.add(switchPoints[i].distanceTo(switchPoints[i + 1]));
    } else {
      distances.add(0);
    }
  }
  return distances;
}
