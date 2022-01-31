import 'package:linalg/linalg.dart';
import 'package:qr_code_vision/entities/bit_matrix.dart';
import 'package:qr_code_vision/entities/position.dart';
import 'package:qr_code_vision/entities/qr_location.dart';

class QrRawContent {
  final BitMatrix matrix;
  final Position Function(double x, double y) mappingFunction;

  QrRawContent({
    required this.matrix,
    required this.mappingFunction,
  });
}

Matrix squareToQuadrilateral(
  Position p1,
  Position p2,
  Position p3,
  Position p4,
) {
  final dx3 = p1.x - p2.x + p3.x - p4.x;
  final dy3 = p1.y - p2.y + p3.y - p4.y;
  if (dx3 == 0 && dy3 == 0) {
    // Affine
    return Matrix([
      [p2.x - p1.x, p2.y - p1.y, 0],
      [p3.x - p2.x, p3.y - p2.y, 0],
      [p1.x, p1.y, 1],
    ]);
  } else {
    final dx1 = p2.x - p3.x;
    final dx2 = p4.x - p3.x;
    final dy1 = p2.y - p3.y;
    final dy2 = p4.y - p3.y;
    final denominator = dx1 * dy2 - dx2 * dy1;
    final a13 = (dx3 * dy2 - dx2 * dy3) / denominator;
    final a23 = (dx1 * dy3 - dx3 * dy1) / denominator;
    return Matrix([
      [p2.x - p1.x + a13 * p2.x, p2.y - p1.y + a13 * p2.y, a13],
      [p4.x - p1.x + a23 * p4.x, p4.y - p1.y + a23 * p4.y, a23],
      [p1.x, p1.y, 1]
    ]);
  }
}

QrRawContent extract(BitMatrix image, QrLocation location) {
  final qToS = squareToQuadrilateral(
    Position(3.5, 3.5),
    Position(location.dimension.size - 3.5, 3.5),
    Position(location.dimension.size - 6.5, location.dimension.size - 6.5),
    Position(3.5, location.dimension.size - 3.5),
  ).coFactors().transpose();
  final sToQ = squareToQuadrilateral(location.topLeft, location.topRight,
      location.alignmentPattern, location.bottomLeft);
  final transform = qToS * sToQ;

  final matrix =
      BitMatrix.createEmpty(location.dimension.size, location.dimension.size);

  Position mappingFunction(double x, double y) {
    final denominator =
        transform[0][2] * x + transform[1][2] * y + transform[2][2];
    return Position(
      (transform[0][0] * x + transform[1][0] * y + transform[2][0]) /
          denominator,
      (transform[0][1] * x + transform[1][1] * y + transform[2][1]) /
          denominator,
    );
  }

  for (int y = 0; y < location.dimension.size; y++) {
    for (int x = 0; x < location.dimension.size; x++) {
      final xValue = x + 0.5;
      final yValue = y + 0.5;
      final sourcePixel = mappingFunction(xValue, yValue);
      matrix.set(x, y, image.get(sourcePixel.x.floor(), sourcePixel.y.floor()));
    }
  }

  return QrRawContent(
    mappingFunction: mappingFunction,
    matrix: matrix,
  );
}
