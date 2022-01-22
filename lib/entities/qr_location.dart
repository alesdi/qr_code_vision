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
