import 'dart:math' as math;
import 'dart:math';

import 'package:collection/collection.dart';

import '../entities/position.dart';
import '../entities/qr_location.dart';
import '../helpers/bit_matrix.dart';
import 'compute_dimension.dart';
import 'score_pattern.dart';

const maxFinderPatternsToSearch = 4;
const minQuadRatio = 0.5;
const maxQuadRatio = 1.5;

/// Locates a QR code given a BitMatrix representing a binary image.
QrLocation? locate(
  final BitMatrix matrix, {
  final bool recenterLocation = false,
}) {
  final List<_Quad> finderPatternQuads = [];
  List<_Quad> activeFinderPatternQuads = [];
  final List<_Quad> alignmentPatternQuads = [];
  List<_Quad> activeAlignmentPatternQuads = [];

  for (var y = 0; y <= matrix.height; y++) {
    double length = 0;
    bool lastBit = false;
    List<double> scans = [0, 0, 0, 0, 0];

    for (var x = -1; x <= matrix.width; x++) {
      final v = matrix.get(x, y);
      if (v == lastBit) {
        length++;
      } else {
        scans = [scans[1], scans[2], scans[3], scans[4], length];
        length = 1;
        lastBit = v;

        // Do the last 5 color changes ~ match the expected ratio for a finder pattern? 1:1:3:1:1 of b:w:b:w:b
        final averageFinderPatternBlockSize = scans.reduce((a, b) => a + b) / 7;
        final validFinderPattern = (scans[
                            0] -
                        averageFinderPatternBlockSize)
                    .abs() <
                averageFinderPatternBlockSize &&
            (scans[1] - averageFinderPatternBlockSize).abs() <
                averageFinderPatternBlockSize &&
            (scans[2] - 3 * averageFinderPatternBlockSize).abs() <
                3 * averageFinderPatternBlockSize &&
            (scans[3] - averageFinderPatternBlockSize).abs() <
                averageFinderPatternBlockSize &&
            (scans[4] - averageFinderPatternBlockSize).abs() <
                averageFinderPatternBlockSize &&
            !v; // And make sure the current pixel is white since finder patterns are bordered in white

        // Do the last 3 color changes ~ match the expected ratio for an alignment pattern? 1:1:1 of w:b:w
        final averageAlignmentPatternBlockSize =
            scans.sublist(scans.length - 3).reduce((a, b) => a + b) / 3;
        final validAlignmentPattern = (scans[2] -
                        averageAlignmentPatternBlockSize)
                    .abs() <
                averageAlignmentPatternBlockSize &&
            (scans[3] - averageAlignmentPatternBlockSize).abs() <
                averageAlignmentPatternBlockSize &&
            (scans[4] - averageAlignmentPatternBlockSize).abs() <
                averageAlignmentPatternBlockSize &&
            v; // Is the current pixel black since alignment patterns are bordered in black

        if (validFinderPattern) {
          // Compute the start and end x values of the large center black square
          final endX = x - scans[3] - scans[4];
          final startX = endX - scans[2];

          final line = _QuadBound(startX, endX, y.toDouble());
          // Is there a quad directly above the current spot? If so, extend it with the new line. Otherwise, create a new quad with
          // that line as the starting point.
          final matchingQuads = activeFinderPatternQuads
              .where(
                (q) =>
                    (startX >= q.bottom.startX && startX <= q.bottom.endX) ||
                    (endX >= q.bottom.startX && startX <= q.bottom.endX) ||
                    (startX <= q.bottom.startX &&
                        endX >= q.bottom.endX &&
                        ((scans[2] / (q.bottom.endX - q.bottom.startX)) <
                                maxQuadRatio &&
                            (scans[2] / (q.bottom.endX - q.bottom.startX)) >
                                minQuadRatio)),
              )
              .toList();
          if (matchingQuads.isNotEmpty) {
            matchingQuads[0].bottom = line;
          } else {
            activeFinderPatternQuads.add(_Quad(line, line));
          }
        }
        if (validAlignmentPattern) {
          // Compute the start and end x values of the center black square
          final endX = x - scans[4];
          final startX = endX - scans[3];

          final line = _QuadBound(startX, endX, y.toDouble());
          // Is there a quad directly above the current spot? If so, extend it with the new line. Otherwise, create a new quad with
          // that line as the starting point.
          final matchingQuads = activeAlignmentPatternQuads
              .where(
                (q) =>
                    (startX >= q.bottom.startX && startX <= q.bottom.endX) ||
                    (endX >= q.bottom.startX && startX <= q.bottom.endX) ||
                    (startX <= q.bottom.startX &&
                        endX >= q.bottom.endX &&
                        ((scans[2] / (q.bottom.endX - q.bottom.startX)) <
                                maxQuadRatio &&
                            (scans[2] / (q.bottom.endX - q.bottom.startX)) >
                                minQuadRatio)),
              )
              .toList();
          if (matchingQuads.isNotEmpty) {
            matchingQuads[0].bottom = line;
          } else {
            activeAlignmentPatternQuads.add(_Quad(line, line));
          }
        }
      }
    }
    finderPatternQuads.addAll(activeFinderPatternQuads
        .where((q) => q.bottom.y != y && q.bottom.y - q.top.y >= 2));
    activeFinderPatternQuads =
        activeFinderPatternQuads.where((q) => q.bottom.y == y).toList();

    alignmentPatternQuads
        .addAll(activeAlignmentPatternQuads.where((q) => q.bottom.y != y));
    activeAlignmentPatternQuads =
        activeAlignmentPatternQuads.where((q) => q.bottom.y == y).toList();
  }

  finderPatternQuads
      .addAll(activeFinderPatternQuads.where((q) => q.bottom.y - q.top.y >= 2));
  alignmentPatternQuads.addAll(activeAlignmentPatternQuads);

  final List<_ScoredSizedPosition> finderPatterns = finderPatternQuads
      .where((q) =>
          q.bottom.y - q.top.y >=
          2) // All quads must be at least 2px tall since the center square is larger than a block
      .map((q) {
        // Initial scoring of finder pattern quads by looking at their ratios, not taking into account position
        final x =
            (q.top.startX + q.top.endX + q.bottom.startX + q.bottom.endX) / 4;
        final y = (q.top.y + q.bottom.y + 1) / 2;
        if (!matrix.get(x.round(), y.round())) {
          return null;
        }

        final lengths = [
          q.top.endX - q.top.startX,
          q.bottom.endX - q.bottom.startX,
          q.bottom.y - q.top.y + 1
        ];
        final size = lengths.reduce((a, b) => a + b) / lengths.length;
        final score = scorePattern(
            Position<double>(x.roundToDouble(), y.roundToDouble()),
            [1, 1, 3, 1, 1],
            matrix);
        return _ScoredSizedPosition(score, x, y, size);
      })
      .whereNotNull() // Filter out any rejected quads from above
      .toList();
  finderPatterns.sort((a, b) => a.score.compareTo(b.score));

  // Now take the top finder pattern options (lower score is better) and try to
  // find 2 other options with a similar size.
  Set<Position<double>>? bestFinderPathSet;
  double bestFinderPathSetScore = double.infinity;
  for (var i = 0; i < finderPatterns.length; i++) {
    final point = finderPatterns[i];
    if (i > maxFinderPatternsToSearch) {
      continue;
    }
    final otherPoints = finderPatterns
        .whereIndexed((ii, p) => i != ii)
        .map((p) => (_ScoredSizedPosition(
            p.score + math.pow(p.size - point.size, 2) / point.size,
            p.x,
            p.y,
            p.size)))
        .toList();

    otherPoints.sort((a, b) => a.score.compareTo(b.score));
    if (otherPoints.length < 2) {
      continue;
    }
    final score = point.score + otherPoints[0].score + otherPoints[1].score;

    if (score < bestFinderPathSetScore) {
      bestFinderPathSetScore = score;
      bestFinderPathSet = {point, ...otherPoints.sublist(0, 2)};
    }
  }

  if (bestFinderPathSet == null) {
    return null;
  }

  final _FinderPatternSet orderedFinderPatternGroup =
      _FinderPatternSet.fromPoints(bestFinderPathSet);

  // Now that we've found the three finder patterns we can determine the blockSize and the size of the QR code.
  // We'll use these to help find the alignment pattern but also later when we do the extraction.
  final dimension = computeDimension(
    topLeft: orderedFinderPatternGroup.topLeft,
    topRight: orderedFinderPatternGroup.topRight,
    bottomLeft: orderedFinderPatternGroup.bottomLeft,
    matrix: matrix,
  );

  if (dimension == null) {
    return null;
  }

  // Now find the alignment pattern
  final bottomRightFinderPattern = Position<double>(
    // Best guess at where a bottomRight finder pattern would be
    orderedFinderPatternGroup.topRight.x -
        orderedFinderPatternGroup.topLeft.x +
        orderedFinderPatternGroup.bottomLeft.x,
    orderedFinderPatternGroup.topRight.y -
        orderedFinderPatternGroup.topLeft.y +
        orderedFinderPatternGroup.bottomLeft.y,
  );
  final modulesBetweenFinderPatterns = ((orderedFinderPatternGroup.topLeft
              .distanceTo(orderedFinderPatternGroup.bottomLeft) +
          orderedFinderPatternGroup.topLeft
              .distanceTo(orderedFinderPatternGroup.topRight)) /
      2 /
      dimension.module);
  final correctionToTopLeft = 1 - (3 / modulesBetweenFinderPatterns);
  final expectedAlignmentPattern = Position<double>(
    orderedFinderPatternGroup.topLeft.x +
        correctionToTopLeft *
            (bottomRightFinderPattern.x - orderedFinderPatternGroup.topLeft.x),
    orderedFinderPatternGroup.topLeft.y +
        correctionToTopLeft *
            (bottomRightFinderPattern.y - orderedFinderPatternGroup.topLeft.y),
  );

  Position<double>? bestPattern;
  double bestPatternScore = double.infinity;

  for (var q in alignmentPatternQuads) {
    final x = (q.top.startX + q.top.endX + q.bottom.startX + q.bottom.endX) / 4;
    final y = (q.top.y + q.bottom.y + 1) / 2;
    if (!matrix.get((x).floor(), (y).floor())) {
      continue;
    }

    final sizeScore = scorePattern(
        Position<double>(x.floorToDouble(), y.floorToDouble()),
        [1, 1, 1],
        matrix);
    final score =
        sizeScore + Position<double>(x, y).distanceTo(expectedAlignmentPattern);

    if (score < bestPatternScore) {
      bestPatternScore = score;
      bestPattern = Position<double>(x, y);
    }
  }

  // If there are less than 15 modules between finder patterns it's a version 1 QR code and as such has no alignmemnt pattern
  // so we can only use our best guess.
  final alignment = modulesBetweenFinderPatterns >= 15 && bestPattern != null
      ? bestPattern
      : expectedAlignmentPattern;

  if (recenterLocation) {
    return QrLocation(
      topRight:
          _blackAreaCenter(matrix, orderedFinderPatternGroup.topRight.clone()),
      bottomLeft: _blackAreaCenter(
          matrix, orderedFinderPatternGroup.bottomLeft.clone()),
      topLeft:
          _blackAreaCenter(matrix, orderedFinderPatternGroup.topLeft.clone()),
      alignmentPattern: alignment.clone(),
      dimension: dimension,
    );
  } else {
    return QrLocation(
      topRight: orderedFinderPatternGroup.topRight.clone(),
      bottomLeft: orderedFinderPatternGroup.bottomLeft.clone(),
      topLeft: orderedFinderPatternGroup.topLeft.clone(),
      alignmentPattern: alignment.clone(),
      dimension: dimension,
    );
  }
}

// Data classes
class _Quad {
  _QuadBound top;
  _QuadBound bottom;

  _Quad(this.top, this.bottom);
}

class _QuadBound {
  final double startX;
  final double endX;
  final double y;

  _QuadBound(this.startX, this.endX, this.y);
}

class _ScoredSizedPosition extends Position<double> {
  final double score;
  final double size;

  _ScoredSizedPosition(this.score, double x, double y, this.size) : super(x, y);

  Position<double> toPoint() {
    return Position<double>(x, y);
  }
}

/// A set of finder patterns that identify the position of a QR code
class _FinderPatternSet {
  final Position<double> topRight;
  final Position<double> topLeft;
  final Position<double> bottomLeft;

  _FinderPatternSet({
    required this.topRight,
    required this.topLeft,
    required this.bottomLeft,
  });

  factory _FinderPatternSet.fromPoints(final Set<Position<double>> points) {
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
      return _FinderPatternSet(
        topRight: vertices[0],
        topLeft: topLeft,
        bottomLeft: vertices[1],
      );
    } else {
      return _FinderPatternSet(
        topRight: vertices[1],
        topLeft: topLeft,
        bottomLeft: vertices[0],
      );
    }
  }
}

Position<double> _blackAreaCenter(BitMatrix matrix, Position<double> p) {
  int leftX = (p.x).round();
  while (matrix.get(leftX, (p.y).round())) {
    leftX--;
  }
  int rightX = (p.x).round();
  while (matrix.get(rightX, (p.y).round())) {
    rightX++;
  }
  final x = (leftX + rightX) / 2;

  int topY = (p.y).round();
  while (matrix.get((x).round(), topY)) {
    topY--;
  }
  int bottomY = (p.y).round();
  while (matrix.get((x).round(), bottomY)) {
    bottomY++;
  }
  final y = (topY + bottomY) / 2;

  return Position<double>(x, y);
}
