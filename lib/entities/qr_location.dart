import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:qr_code_vision/extractor/perspective.dart';

import 'position.dart';

class QrDimension extends Equatable {
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
  List<Object?> get props => [size, module];
}

class QrLocation extends Equatable {
  final Position<double> topRight;
  final Position<double> bottomLeft;
  final Position<double> topLeft;
  final Position<double> alignmentPattern;
  final QrDimension dimension;

  QrLocation({
    required this.topRight,
    required this.bottomLeft,
    required this.topLeft,
    required this.alignmentPattern,
    required this.dimension,
  });

  PerspectiveTransform computePerspectiveTransform() {
    return PerspectiveTransform.fromQuadrilaterals(
      [
        Position(3.5, 3.5),
        Position(dimension.size - 3.5, 3.5),
        Position(dimension.size - 6.5, dimension.size - 6.5),
        Position(3.5, dimension.size - 3.5),
      ],
      [
        topLeft,
        topRight,
        alignmentPattern,
        bottomLeft,
      ],
    );
  }

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
  List<Object?> get props => [
        topRight,
        bottomLeft,
        topLeft,
        alignmentPattern,
        dimension,
      ];
}
