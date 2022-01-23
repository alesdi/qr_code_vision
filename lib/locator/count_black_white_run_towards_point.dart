// Takes an origin point and an end point and counts the sizes of the black white run from the origin towards the end point.
// Returns an array of elements, representing the pixel size of the black white run.
// Uses a variant of http://en.wikipedia.org/wiki/Bresenham's_line_algorithm
import 'package:qr_code_vision/entities/bit_matrix.dart';
import 'package:qr_code_vision/entities/position.dart';

List<double> countBlackWhiteRunTowardsPoint(final Position origin,
    final Position end, final BitMatrix matrix, final int length) {
  final List<Position> switchPoints = [
    Position(origin.x.floorToDouble(), origin.y.floorToDouble())
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
      switchPoints.add(Position(realX.toDouble(), realY.toDouble()));
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
