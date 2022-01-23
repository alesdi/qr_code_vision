import 'dart:typed_data';
import 'dart:ui';

import 'position.dart';

class QrDimension {
  final int size;
  final double module;

  QrDimension({
    required this.size,
    required this.module,
  });

  @override
  String toString() {
    return 'size: ${size}; module: ${module}';
  }

  @override
  bool operator ==(other) {
    return (other is QrDimension) &&
        (other.size == size) &&
        (other.module == module);
  }

  @override
  int get hashCode => hashValues(size, module);
}

class QrLocation {
  final Position topRight;
  final Position bottomLeft;
  final Position topLeft;
  final Position alignmentPattern;
  final QrDimension dimension;

  QrLocation({
    required this.topRight,
    required this.bottomLeft,
    required this.topLeft,
    required this.alignmentPattern,
    required this.dimension,
  });

  /// Extract a transformation matrix representing the QR code location
  /// in the image, given the expected real size of the QR code.
  Float64List toTransformationMatrix(final num size) {
    final double a = (topRight.x - topLeft.x) / size;
    final double b = (topRight.y - topLeft.y) / size;
    final double c = (bottomLeft.x - topLeft.x) / size;
    final double d = (bottomLeft.y - topLeft.y) / size;
    final e = topLeft.x;
    final f = topLeft.y;

    return Float64List.fromList([
      a, b, 0, 0, //
      c, d, 0, 0, //
      0, 0, 1, 0, //
      e, f, 0, 1, //
    ]);
  }

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
    return (other is QrLocation) &&
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
