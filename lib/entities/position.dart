import 'dart:math';

class Position<T extends num> {
  T x;
  T y;
  Position(this.x, this.y);

  Position<T> clone() {
    return Position<T>(x, y);
  }

  double distanceTo(Position other) {
    return sqrt((x - other.x) * (x - other.x) + (y - other.y) * (y - other.y));
  }

  Position<double> toDouble() {
    return Position<double>(x.toDouble(), y.toDouble());
  }

  @override
  bool operator ==(Object other) =>
      other is Position<T> && x == other.x && y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}
