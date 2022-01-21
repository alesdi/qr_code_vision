import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../BitMatrix.dart';

const maxFinderPatternsToSearch = 4;
const minQuadRatio = 0.5;
const maxQuadRatio = 1.5;

class Point {
  final double x;
  final double y;

  Point(this.x, this.y);

  Point clone() => Point(x, y);

  @override
  bool operator ==(Object other) =>
      other is Point && x == other.x && y == other.y;

  @override
  int get hashCode => hashValues(x, y);
}

class QRLocation {
  final Point topRight;
  final Point bottomLeft;
  final Point topLeft;
  final Point alignmentPattern;
  final double dimension;

  QRLocation({
    required this.topRight,
    required this.bottomLeft,
    required this.topLeft,
    required this.alignmentPattern,
    required this.dimension,
  });

  @override
  String toString() {
    return 'topRight: ${topRight.x}, ${topRight.y}; '
        'bottomLeft: ${bottomLeft.x}, ${bottomLeft.y}; '
        'topLeft: ${topLeft.x}, ${topLeft.y}; '
        'alignmentPattern: ${alignmentPattern.x}, ${alignmentPattern.y}; '
        'dimension: $dimension';
  }

  @override
  bool operator ==(other) {
    return (other is QRLocation) &&
        other.topRight == topRight &&
        other.bottomLeft == bottomLeft &&
        other.topLeft == topLeft &&
        other.alignmentPattern == alignmentPattern &&
        other.dimension == dimension;
  }

  @override
  int get hashCode =>
      hashValues(topRight, bottomLeft, topLeft, alignmentPattern, dimension);
}

double distance(final Point a, final Point b) {
  return math.sqrt(math.pow((b.x - a.x), 2) + math.pow((b.y - a.y), 2));
}

double sum(Iterable<double> values) {
  return values.reduce((a, b) => a + b);
}

// Takes three finder patterns and organizes them into topLeft, topRight, etc
OrderedFinderPatternGroup reorderFinderPatterns(
    final Point pattern1, final Point pattern2, final Point pattern3) {
  // Find distances between pattern centers
  final oneTwoDistance = distance(pattern1, pattern2);
  final twoThreeDistance = distance(pattern2, pattern3);
  final oneThreeDistance = distance(pattern1, pattern3);

  Point bottomLeft;
  Point topLeft;
  Point topRight;

  // Assume one closest to other two is B; A and C will just be guesses at first
  if (twoThreeDistance >= oneTwoDistance &&
      twoThreeDistance >= oneThreeDistance) {
    bottomLeft = pattern2;
    topLeft = pattern1;
    topRight = pattern3;
  } else if (oneThreeDistance >= twoThreeDistance &&
      oneThreeDistance >= oneTwoDistance) {
    bottomLeft = pattern1;
    topLeft = pattern2;
    topRight = pattern3;
  } else {
    bottomLeft = pattern1;
    topLeft = pattern3;
    topRight = pattern2;
  }

  // Use cross product to figure out whether bottomLeft (A) and topRight (C) are correct or flipped in relation to topLeft (B)
  // This asks whether BC x BA has a positive z component, which is the arrangement we want. If it's negative, then
  // we've got it flipped around and should swap topRight and bottomLeft.
  if (((topRight.x - topLeft.x) * (bottomLeft.y - topLeft.y)) -
          ((topRight.y - topLeft.y) * (bottomLeft.x - topLeft.x)) <
      0) {
    final swapTemp = bottomLeft;
    bottomLeft = topRight;
    topRight = swapTemp;
  }

  return OrderedFinderPatternGroup(
    topRight: topRight,
    topLeft: topLeft,
    bottomLeft: bottomLeft,
  );
}

class Dimension {
  final double dimension;
  final double moduleSize;

  Dimension({
    required this.dimension,
    required this.moduleSize,
  });
}

// Computes the dimension (number of modules on a side) of the QR Code based on the position of the finder patterns
Dimension computeDimension({
  required final Point topLeft,
  required final Point topRight,
  required final Point bottomLeft,
  required final BitMatrix matrix,
}) {
  final topToBottom = countBlackWhiteRun(
    origin: topLeft,
    end: bottomLeft,
    matrix: matrix,
    length: 5,
  );

  final leftToRight = countBlackWhiteRun(
    origin: topLeft,
    end: topRight,
    matrix: matrix,
    length: 5,
  );

  final bottomToTop = countBlackWhiteRun(
    origin: bottomLeft,
    end: topLeft,
    matrix: matrix,
    length: 5,
  );

  final rightToLeft = countBlackWhiteRun(
    origin: topRight,
    end: topLeft,
    matrix: matrix,
    length: 5,
  );
  final double moduleSize =
      (sum(topToBottom) / 7 + // Divide by 7 since the ratio is 1:1:3:1:1
              sum(leftToRight) / 7 +
              sum(bottomToTop) / 7 +
              sum(rightToLeft) / 7) /
          4;

  if (moduleSize < 1) {
    throw Exception("Invalid module size");
  }

  final topDimension = (distance(topLeft, topRight) / moduleSize).round();
  final sideDimension = (distance(topLeft, bottomLeft) / moduleSize).round();
  int dimension = ((topDimension + sideDimension) / 2).floor() + 7;
  switch (dimension % 4) {
    case 0:
      dimension++;
      break;
    case 2:
      dimension--;
      break;
  }
  return Dimension(dimension: dimension.toDouble(), moduleSize: moduleSize);
}

// Takes an origin point and an end point and counts the sizes of the black white run from the origin towards the end point.
// Returns an array of elements, representing the pixel size of the black white run.
// Uses a variant of http://en.wikipedia.org/wiki/Bresenham's_line_algorithm
List<double> countBlackWhiteRunTowardsPoint(final Point origin, final Point end,
    final BitMatrix matrix, final int length) {
  final List<Point> switchPoints = [
    Point(origin.x.floorToDouble(), origin.y.floorToDouble())
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
      switchPoints.add(Point(realX.toDouble(), realY.toDouble()));
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
      distances.add(distance(switchPoints[i], switchPoints[i + 1]));
    } else {
      distances.add(0);
    }
  }
  return distances;
}

class BlackWhiteRunScore {
  final double averageSize;
  final double error;

  BlackWhiteRunScore({
    required this.averageSize,
    required this.error,
  });
}

// Takes an origin point and an end point and counts the sizes of the black white run in the origin point
// along the line that intersects with the end point. Returns an array of elements, representing the pixel sizes
// of the black white run. Takes a length which represents the number of switches from black to white to look for.
List<double> countBlackWhiteRun({
  required final Point origin,
  required final Point end,
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
    Point(origin.x - run, origin.y - rise),
    matrix,
    (length / 2).ceil(),
  );

  final middleValue = towardsEnd.removeAt(0) +
      awayFromEnd.removeAt(0) -
      1; // Substract one so we don't double count a pixel
  return [...awayFromEnd, middleValue, ...towardsEnd];
}

// Takes in a black white run and an array of expected ratios. Returns the average size of the run as well as the "error" -
// that is the amount the run diverges from the expected ratio
BlackWhiteRunScore scoreBlackWhiteRun(
    List<double> sequence, List<double> ratios) {
  final averageSize = sum(sequence) / sum(ratios);
  double error = 0;
  for (var i = 0; i < ratios.length; i++) {
    error += math.pow(sequence[i] - ratios[i] * averageSize, 2);
  }

  return BlackWhiteRunScore(averageSize: averageSize, error: error);
}

// Takes an X,Y point and an array of sizes and scores the point against those ratios.
// For example for a finder pattern takes the ratio list of 1:1:3:1:1 and checks horizontal, vertical and diagonal ratios
// against that.
double scorePattern(Point point, List<double> ratios, BitMatrix matrix) {
  try {
    final horizontalRun = countBlackWhiteRun(
      origin: point,
      end: Point(-1, point.y),
      matrix: matrix,
      length: ratios.length,
    );

    final verticalRun = countBlackWhiteRun(
      origin: point,
      end: Point(point.x, -1),
      matrix: matrix,
      length: ratios.length,
    );

    final topLeftPoint = Point(
      math.max(0, point.x - point.y) - 1,
      math.max(0, point.y - point.x) - 1,
    );

    final topLeftBottomRightRun = countBlackWhiteRun(
      origin: point,
      end: topLeftPoint,
      matrix: matrix,
      length: ratios.length,
    );

    final bottomLeftPoint = Point(
      math.min(matrix.width, point.x + point.y) + 1,
      math.min(matrix.height, point.y + point.x) + 1,
    );

    final bottomLeftTopRightRun = countBlackWhiteRun(
      origin: point,
      end: bottomLeftPoint,
      matrix: matrix,
      length: ratios.length,
    );

    final horzError = scoreBlackWhiteRun(horizontalRun, ratios);
    final vertError = scoreBlackWhiteRun(verticalRun, ratios);
    final diagDownError = scoreBlackWhiteRun(topLeftBottomRightRun, ratios);
    final diagUpError = scoreBlackWhiteRun(bottomLeftTopRightRun, ratios);

    final ratioError = math.sqrt(horzError.error * horzError.error +
        vertError.error * vertError.error +
        diagDownError.error * diagDownError.error +
        diagUpError.error * diagUpError.error);

    final avgSize = (horzError.averageSize +
            vertError.averageSize +
            diagDownError.averageSize +
            diagUpError.averageSize) /
        4;

    final sizeError = (math.pow(horzError.averageSize - avgSize, 2) +
            math.pow(vertError.averageSize - avgSize, 2) +
            math.pow(diagDownError.averageSize - avgSize, 2) +
            math.pow(diagUpError.averageSize - avgSize, 2)) /
        avgSize;
    return ratioError + sizeError;
  } catch (e) {
    return double.infinity;
  }
}

Point recenterLocation(BitMatrix matrix, Point p) {
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

  return Point(x, y);
}

class Quad {
  QuadBound top;
  QuadBound bottom;

  Quad(this.top, this.bottom);
}

class QuadBound {
  final double startX;
  final double endX;
  final double y;

  QuadBound(this.startX, this.endX, this.y);
}

class FinderPattern extends Point {
  final double score;
  final double size;

  FinderPattern(this.score, double x, double y, this.size) : super(x, y);

  Point toPoint() {
    return Point(x, y);
  }
}

class FinderPatternGroup {
  final List<FinderPattern> points;
  final double score;

  FinderPatternGroup(this.points, this.score);
}

class OrderedFinderPatternGroup {
  final Point topRight;
  final Point topLeft;
  final Point bottomLeft;

  OrderedFinderPatternGroup({
    required this.topRight,
    required this.topLeft,
    required this.bottomLeft,
  });
}

List<QRLocation>? locate(BitMatrix matrix) {
  final List<Quad> finderPatternQuads = [];
  List<Quad> activeFinderPatternQuads = [];
  final List<Quad> alignmentPatternQuads = [];
  List<Quad> activeAlignmentPatternQuads = [];

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
        final averageFinderPatternBlocksize = sum(scans) / 7;
        final validFinderPattern = (scans[
                            0] -
                        averageFinderPatternBlocksize)
                    .abs() <
                averageFinderPatternBlocksize &&
            (scans[1] - averageFinderPatternBlocksize).abs() <
                averageFinderPatternBlocksize &&
            (scans[2] - 3 * averageFinderPatternBlocksize).abs() <
                3 * averageFinderPatternBlocksize &&
            (scans[3] - averageFinderPatternBlocksize).abs() <
                averageFinderPatternBlocksize &&
            (scans[4] - averageFinderPatternBlocksize).abs() <
                averageFinderPatternBlocksize &&
            !v; // And make sure the current pixel is white since finder patterns are bordered in white

        // Do the last 3 color changes ~ match the expected ratio for an alignment pattern? 1:1:1 of w:b:w
        final averageAlignmentPatternBlocksize =
            sum(scans.sublist(scans.length - 3)) / 3;
        final validAlignmentPattern = (scans[2] -
                        averageAlignmentPatternBlocksize)
                    .abs() <
                averageAlignmentPatternBlocksize &&
            (scans[3] - averageAlignmentPatternBlocksize).abs() <
                averageAlignmentPatternBlocksize &&
            (scans[4] - averageAlignmentPatternBlocksize).abs() <
                averageAlignmentPatternBlocksize &&
            v; // Is the current pixel black since alignment patterns are bordered in black

        if (validFinderPattern) {
          // Compute the start and end x values of the large center black square
          final endX = x - scans[3] - scans[4];
          final startX = endX - scans[2];

          final line = QuadBound(startX, endX, y.toDouble());
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
            activeFinderPatternQuads.add(Quad(line, line));
          }
        }
        if (validAlignmentPattern) {
          // Compute the start and end x values of the center black square
          final endX = x - scans[4];
          final startX = endX - scans[3];

          final line = QuadBound(startX, endX, y.toDouble());
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
            activeAlignmentPatternQuads.add(Quad(line, line));
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

  final List<FinderPattern> finderPatterns = finderPatternQuads
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
        final size = sum(lengths) / lengths.length;
        final score = scorePattern(Point(x.roundToDouble(), y.roundToDouble()),
            [1, 1, 3, 1, 1], matrix);
        return FinderPattern(score, x, y, size);
      })
      .whereNotNull() // Filter out any rejected quads from above
      .toList();
  finderPatterns.sort((a, b) => a.score.compareTo(b.score));
  // Now take the top finder pattern options and try to find 2 other options with a similar size.

  final List<FinderPatternGroup> finderPatternGroups = [];
  for (var i = 0; i < finderPatterns.length; i++) {
    final point = finderPatterns[i];
    if (i > maxFinderPatternsToSearch) {
      continue;
    }
    final otherPoints = finderPatterns
        .whereIndexed((ii, p) => i != ii)
        .map((p) => (FinderPattern(
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
    finderPatternGroups
        .add(FinderPatternGroup([point, ...otherPoints.sublist(0, 2)], score));
  }

  finderPatternGroups.sort((a, b) => a.score.compareTo(b.score));

  if (finderPatternGroups.isEmpty) {
    return null;
  }

  final OrderedFinderPatternGroup orderedFinderPatternGroup =
      reorderFinderPatterns(
    finderPatternGroups[0].points[0],
    finderPatternGroups[0].points[1],
    finderPatternGroups[0].points[2],
  );
  final alignment = findAlignmentPattern(
    matrix,
    alignmentPatternQuads,
    orderedFinderPatternGroup.topRight,
    orderedFinderPatternGroup.topLeft,
    orderedFinderPatternGroup.bottomLeft,
  );
  final List<QRLocation> result = [];
  if (alignment != null) {
    result.add(QRLocation(
      topRight: orderedFinderPatternGroup.topRight.clone(),
      bottomLeft: orderedFinderPatternGroup.bottomLeft.clone(),
      topLeft: orderedFinderPatternGroup.topLeft.clone(),
      alignmentPattern: alignment.alignmentPattern.clone(),
      dimension: alignment.dimension,
    ));
  }

  // We normally use the center of the quads as the location of the tracking points, which is optimal for most cases and will account
  // for a skew in the image. However, In some cases, a slight skew might not be real and instead be caused by image compression
  // errors and/or low resolution. For those cases, we'd be better off centering the point exactly in the middle of the black area. We
  // compute and return the location data for the naively centered points as it is little additional work and allows for multiple
  // attempts at decoding harder images.
  final midTopRight =
      recenterLocation(matrix, orderedFinderPatternGroup.topRight);
  final midTopLeft =
      recenterLocation(matrix, orderedFinderPatternGroup.topLeft);
  final midBottomLeft =
      recenterLocation(matrix, orderedFinderPatternGroup.bottomLeft);
  final centeredAlignment = findAlignmentPattern(
      matrix, alignmentPatternQuads, midTopRight, midTopLeft, midBottomLeft);
  if (centeredAlignment != null) {
    result.add(QRLocation(
      topRight: midTopRight.clone(),
      bottomLeft: midBottomLeft.clone(),
      topLeft: midTopLeft.clone(),
      alignmentPattern: centeredAlignment.alignmentPattern.clone(),
      dimension: centeredAlignment.dimension,
    ));
  }

  if (result.isEmpty) {
    return null;
  }

  return result;
}

class AlignmentPattern {
  Point alignmentPattern;
  double dimension;

  AlignmentPattern(this.alignmentPattern, this.dimension);
}

class ScoredPoint extends Point {
  final double score;

  ScoredPoint(double x, double y, this.score) : super(x, y);
}

AlignmentPattern? findAlignmentPattern(
    BitMatrix matrix,
    List<Quad> alignmentPatternQuads,
    Point topRight,
    Point topLeft,
    Point bottomLeft) {
  // Now that we've found the three finder patterns we can determine the blockSize and the size of the QR code.
  // We'll use these to help find the alignment pattern but also later when we do the extraction.
  double dimension;
  double moduleSize;
  try {
    final dimensionModuleSize = computeDimension(
      topLeft: topLeft,
      topRight: topRight,
      bottomLeft: bottomLeft,
      matrix: matrix,
    );

    dimension = dimensionModuleSize.dimension;
    moduleSize = dimensionModuleSize.moduleSize;
  } catch (e) {
    return null;
  }

  // Now find the alignment pattern
  final bottomRightFinderPattern = Point(
    // Best guess at where a bottomRight finder pattern would be
    topRight.x - topLeft.x + bottomLeft.x,
    topRight.y - topLeft.y + bottomLeft.y,
  );
  final modulesBetweenFinderPatterns =
      ((distance(topLeft, bottomLeft) + distance(topLeft, topRight)) /
          2 /
          moduleSize);
  final correctionToTopLeft = 1 - (3 / modulesBetweenFinderPatterns);
  final expectedAlignmentPattern = Point(
    topLeft.x + correctionToTopLeft * (bottomRightFinderPattern.x - topLeft.x),
    topLeft.y + correctionToTopLeft * (bottomRightFinderPattern.y - topLeft.y),
  );

  final List<ScoredPoint> alignmentPatterns = alignmentPatternQuads
      .map((q) {
        final x =
            (q.top.startX + q.top.endX + q.bottom.startX + q.bottom.endX) / 4;
        final y = (q.top.y + q.bottom.y + 1) / 2;
        if (!matrix.get((x).floor(), (y).floor())) {
          return null;
        }

        final sizeScore = scorePattern(
            Point(x.floorToDouble(), y.floorToDouble()), [1, 1, 1], matrix);
        final score =
            sizeScore + distance(Point(x, y), expectedAlignmentPattern);
        return ScoredPoint(x, y, score);
      })
      .whereNotNull()
      .toList();

  alignmentPatterns.sort((a, b) => a.score.compareTo(b.score));

  // If there are less than 15 modules between finder patterns it's a version 1 QR code and as such has no alignmemnt pattern
  // so we can only use our best guess.
  final alignmentPattern =
      modulesBetweenFinderPatterns >= 15 && alignmentPatterns.isNotEmpty
          ? alignmentPatterns[0]
          : expectedAlignmentPattern;

  return AlignmentPattern(alignmentPattern, dimension);
}
