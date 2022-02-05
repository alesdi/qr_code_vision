import 'dart:math';

import 'package:qr_code_vision/entities/bit_matrix.dart';
import 'package:qr_code_vision/entities/position.dart';

import 'count_black_white_run.dart';

class BlackWhiteRunScore {
  final double averageSize;
  final double error;

  BlackWhiteRunScore({
    required this.averageSize,
    required this.error,
  });
}

// Takes in a black white run and an array of expected ratios. Returns the average size of the run as well as the "error" -
// that is the amount the run diverges from the expected ratio
BlackWhiteRunScore scoreBlackWhiteRun(
    List<double> sequence, List<double> ratios) {
  final averageSize =
      sequence.reduce((a, b) => a + b) / ratios.reduce((a, b) => a + b);
  double error = 0;
  for (var i = 0; i < ratios.length; i++) {
    error += pow(sequence[i] - ratios[i] * averageSize, 2);
  }

  return BlackWhiteRunScore(averageSize: averageSize, error: error);
}

// Takes an X,Y point and an array of sizes and scores the point against those ratios.
// For example for a finder pattern takes the ratio list of 1:1:3:1:1 and checks horizontal, vertical and diagonal ratios
// against that.
double scorePattern(
    Position<double> point, List<double> ratios, BitMatrix matrix) {
  try {
    final horizontalRun = countBlackWhiteRun(
      origin: point,
      end: Position<double>(-1, point.y),
      matrix: matrix,
      length: ratios.length,
    );

    final verticalRun = countBlackWhiteRun(
      origin: point,
      end: Position<double>(point.x, -1),
      matrix: matrix,
      length: ratios.length,
    );

    final topLeftPoint = Position<double>(
      max(0, point.x - point.y) - 1,
      max(0, point.y - point.x) - 1,
    );

    final topLeftBottomRightRun = countBlackWhiteRun(
      origin: point,
      end: topLeftPoint,
      matrix: matrix,
      length: ratios.length,
    );

    final bottomLeftPoint = Position<double>(
      min(matrix.width, point.x + point.y) + 1,
      min(matrix.height, point.y + point.x) + 1,
    );

    final bottomLeftTopRightRun = countBlackWhiteRun(
      origin: point,
      end: bottomLeftPoint,
      matrix: matrix,
      length: ratios.length,
    );

    final horzError = scoreBlackWhiteRun(horizontalRun, ratios);
    final vertError = scoreBlackWhiteRun(verticalRun, ratios);
    final diagDownError = scoreBlackWhiteRun(topLeftBottomRightRun, ratios);
    final diagUpError = scoreBlackWhiteRun(bottomLeftTopRightRun, ratios);

    final ratioError = sqrt(horzError.error * horzError.error +
        vertError.error * vertError.error +
        diagDownError.error * diagDownError.error +
        diagUpError.error * diagUpError.error);

    final avgSize = (horzError.averageSize +
            vertError.averageSize +
            diagDownError.averageSize +
            diagUpError.averageSize) /
        4;

    final sizeError = (pow(horzError.averageSize - avgSize, 2) +
            pow(vertError.averageSize - avgSize, 2) +
            pow(diagDownError.averageSize - avgSize, 2) +
            pow(diagUpError.averageSize - avgSize, 2)) /
        avgSize;
    return ratioError + sizeError;
  } catch (e) {
    return double.infinity;
  }
}
