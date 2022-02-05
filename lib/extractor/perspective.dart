import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:qr_code_vision/entities/position.dart';

class PerspectiveTransform {
  final _PerspectiveMatrix _matrix;

  PerspectiveTransform(List<double> elements)
      : _matrix = _PerspectiveMatrix.fromList(elements);

  factory PerspectiveTransform.fromTransformedSquare(
    List<Position> vertices,
  ) {
    assert(vertices.length == 4);
    final p1 = vertices[0].toDouble(),
        p2 = vertices[1].toDouble(),
        p3 = vertices[2].toDouble(),
        p4 = vertices[3].toDouble();

    final dx3 = p1.x - p2.x + p3.x - p4.x;
    final dy3 = p1.y - p2.y + p3.y - p4.y;
    if (dx3 == 0 && dy3 == 0) {
      // Affine
      return PerspectiveTransform([
        p2.x - p1.x, p2.y - p1.y, 0, //
        p3.x - p2.x, p3.y - p2.y, 0, //
        p1.x, p1.y, 1, //
      ]);
    } else {
      final dx1 = p2.x - p3.x;
      final dx2 = p4.x - p3.x;
      final dy1 = p2.y - p3.y;
      final dy2 = p4.y - p3.y;
      final denominator = dx1 * dy2 - dx2 * dy1;
      final a13 = (dx3 * dy2 - dx2 * dy3) / denominator;
      final a23 = (dx1 * dy3 - dx3 * dy1) / denominator;
      return PerspectiveTransform([
        p2.x - p1.x + a13 * p2.x, p2.y - p1.y + a13 * p2.y, a13, //
        p4.x - p1.x + a23 * p4.x, p4.y - p1.y + a23 * p4.y, a23, //
        p1.x, p1.y, 1 //
      ]);
    }
  }

  factory PerspectiveTransform.fromQuadrilaterals(
    List<Position> originVertices,
    List<Position> destinationVertices,
  ) {
    final fromOriginToSquare =
        PerspectiveTransform.fromTransformedSquare(originVertices).inverse();
    final fromSquareToDestination =
        PerspectiveTransform.fromTransformedSquare(destinationVertices);
    return fromSquareToDestination.compose(fromOriginToSquare);
  }

  PerspectiveTransform compose(PerspectiveTransform other) {
    final A = other._matrix.toList();
    final B = _matrix.toList();
    final result = List<double>.filled(9, 0);
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        for (int k = 0; k < 3; k++) {
          result[i * 3 + j] += A[i * 3 + k] * B[k * 3 + j];
        }
      }
    }

    return PerspectiveTransform(result);
  }

  PerspectiveTransform inverse() {
    final A = _matrix;

    // Compute the adjoint matrix (transposed cofactors matrix)
    return PerspectiveTransform(
      _PerspectiveMatrix([
        [
          A(2, 2) * A(3, 3) - A(2, 3) * A(3, 2),
          A(1, 3) * A(3, 2) - A(1, 2) * A(3, 3),
          A(1, 2) * A(2, 3) - A(1, 3) * A(2, 2),
        ],
        [
          A(3, 1) * A(2, 3) - A(3, 3) * A(2, 1),
          A(1, 1) * A(3, 3) - A(1, 3) * A(3, 1),
          A(1, 3) * A(2, 1) - A(1, 1) * A(2, 3),
        ],
        [
          A(2, 1) * A(3, 2) - A(2, 2) * A(3, 1),
          A(1, 2) * A(3, 1) - A(1, 1) * A(3, 2),
          A(1, 1) * A(2, 2) - A(1, 2) * A(2, 1),
        ],
      ]),
    );

    // transpose
  }

  Position<double> call(Position point) {
    final matrix = _matrix.toList();
    final x = point.x.toDouble();
    final y = point.y.toDouble();
    final denominator =
        matrix[3 * 0 + 2] * x + matrix[3 * 1 + 2] * y + matrix[3 * 2 + 2];
    return Position<double>(
      (matrix[3 * 0 + 0] * x + matrix[3 * 1 + 0] * y + matrix[3 * 2 + 0]) /
          denominator,
      (matrix[3 * 0 + 1] * x + matrix[3 * 1 + 1] * y + matrix[3 * 2 + 1]) /
          denominator,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PerspectiveTransform &&
          runtimeType == other.runtimeType &&
          _matrix == other._matrix;

  @override
  int get hashCode => _matrix.hashCode;
}

class _PerspectiveMatrix extends ListBase<double> with EquatableMixin {
  final List<double> _values;

  _PerspectiveMatrix.fromList(this._values);

  _PerspectiveMatrix(List<List<double>> matrix)
      : _values = matrix.reduce((value, element) => [...value, ...element]);

  double call(int row, int column) {
    return this[(row - 1) * 3 + column - 1];
  }

  @override
  int length = 9;

  @override
  double operator [](int index) {
    return _values[index];
  }

  @override
  void operator []=(int index, double value) {
    _values[index] = value;
  }

  @override
  String toString() {
    return "PerspectiveMatrix:\n${_values.sublist(0, 3).join(', ')}\n"
        "${_values.sublist(3, 6).join(', ')}\n"
        "${_values.sublist(6, 9).join(', ')}";
  }

  @override
  List<Object?> get props => [_values];
}
