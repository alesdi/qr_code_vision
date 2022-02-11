import 'dart:math';

import 'package:equatable/equatable.dart';

/// A generic position in a two-dimensional space, expressed as a pair of
/// coordinates (that can be either integer or double).
class Position<T extends num> extends Equatable {
  T x;
  T y;
  Position(this.x, this.y);

  /// Returns a copy of this position
  Position<T> clone() {
    return Position<T>(x, y);
  }

  /// Returns the distance between this position and [other]
  double distanceTo(Position other) {
    return sqrt((x - other.x) * (x - other.x) + (y - other.y) * (y - other.y));
  }

  /// Converts this position's coordinates to double
  Position<double> toDouble() {
    return Position<double>(x.toDouble(), y.toDouble());
  }

  @override
  List<Object?> get props => [x, y];
}
