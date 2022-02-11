import 'package:equatable/equatable.dart';
import 'package:qr_code_vision/helpers/perspective_transform.dart';

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

  /// Compute a
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

  @override
  List<Object?> get props => [
        topRight,
        bottomLeft,
        topLeft,
        alignmentPattern,
        dimension,
      ];
}
