import 'package:qr_code_vision/entities/bit_matrix.dart';
import 'package:qr_code_vision/entities/position.dart';
import 'package:qr_code_vision/entities/qr_location.dart';
import 'package:qr_code_vision/extractor/perspective.dart';

class QrRawContent {
  final BitMatrix matrix;
  final PerspectiveTransform transformation;

  QrRawContent({
    required this.matrix,
    required this.transformation,
  });
}

QrRawContent extract(BitMatrix image, QrLocation location) {
  final matrix =
      BitMatrix.createEmpty(location.dimension.size, location.dimension.size);

  final transform = location.computePerspectiveTransform();

  for (int y = 0; y < location.dimension.size; y++) {
    for (int x = 0; x < location.dimension.size; x++) {
      final xValue = x + 0.5;
      final yValue = y + 0.5;
      final sourcePixel = transform(Position(xValue, yValue));
      matrix.set(x, y, image.get(sourcePixel.x.floor(), sourcePixel.y.floor()));
    }
  }

  return QrRawContent(
    transformation: transform,
    matrix: matrix,
  );
}
