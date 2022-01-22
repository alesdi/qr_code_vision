import 'dart:math';

import '../entities/position.dart';

/// A set of finder patterns that identify the position of a QR code
class FinderPatternSet {
  final Position topRight;
  final Position topLeft;
  final Position bottomLeft;

  FinderPatternSet({
    required this.topRight,
    required this.topLeft,
    required this.bottomLeft,
  });

  factory FinderPatternSet.fromPoints(final Set<Position> points) {
    assert(points.length == 3,
        "A Finder Pattern Set must have exactly 3 points. ${points.length} were given.");
    // The patterns form the vertices of a right triangle.
    // Assuming the barcode is not excessively distorted, they can be mapped to
    // the standard positions (top left, top right, bottom left) based on the
    // size of the triangle sides.
    final vertices = points.toList();
    final oppositeDistances = [
      vertices[1].distanceTo(vertices[2]),
      vertices[2].distanceTo(vertices[0]),
      vertices[0].distanceTo(vertices[1]),
    ];

    // Extract the top left pattern (the one with the greatest opposite side)
    final maxDistanceIndex =
        oppositeDistances.indexOf(oppositeDistances.reduce(max));
    final topLeft = vertices.removeAt(maxDistanceIndex);

    // The remaining two vertices of the triangle are the top right and bottom
    // left. The correspondence can be determined by considering the sign of the
    // cross product of the sides' vectors. Left side x top side must be positive.
    if (((vertices[0].x - topLeft.x) * (vertices[1].y - topLeft.y)) -
            ((vertices[0].y - topLeft.y) * (vertices[1].x - topLeft.x)) >
        0) {
      return FinderPatternSet(
        topRight: vertices[0],
        topLeft: topLeft,
        bottomLeft: vertices[1],
      );
    } else {
      return FinderPatternSet(
        topRight: vertices[1],
        topLeft: topLeft,
        bottomLeft: vertices[0],
      );
    }
  }
}
