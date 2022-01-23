import '../entities/bit_matrix.dart';
import '../entities/position.dart';

Position blackAreaCenter(BitMatrix matrix, Position p) {
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

  return Position(x, y);
}
