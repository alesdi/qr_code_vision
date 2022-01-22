import 'dart:math';
import 'dart:ui';

class Position {
  final double x;
  final double y;

  Position(this.x, this.y);

  Position clone() => Position(x, y);

  double distanceTo(final Position position) {
    return sqrt(pow(position.x - x, 2) + pow(position.y - y, 2));
  }

  @override
  bool operator ==(Object other) =>
      other is Position && x == other.x && y == other.y;

  @override
  int get hashCode => hashValues(x, y);
}
