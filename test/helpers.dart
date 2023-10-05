import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart';
import 'package:qr_code_vision/helpers/bit_matrix.dart';
import 'package:qr_code_vision/helpers/convert_to_binary.dart';

Image bitMatrixToImage(BitMatrix matrix) {
  final output = Uint8ClampedList(matrix.width * matrix.height * 4);
  for (var y = 0; y < matrix.height; y++) {
    for (var x = 0; x < matrix.width; x++) {
      final v = matrix.get(x, y);
      final i = (y * matrix.width + x) * 4;
      output[i + 0] = v ? 0x00 : 0xff;
      output[i + 1] = v ? 0x00 : 0xff;
      output[i + 2] = v ? 0x00 : 0xff;
      output[i + 3] = 0xff;
    }
  }
  return Image.fromBytes(
      width: matrix.width, height: matrix.height, bytes: output.buffer);
}

BitMatrix loadMatrix(String path) {
  final image = decodeImage(File(path).readAsBytesSync())!;
  return convertToBinary(image.getBytes(), image.width, image.height);
}

/// Load image file from the given path and convert it into a bit matrix with
/// one bit per pixel. A bit is set (1) when the corresponding pixel in the
/// image is black. A pixel is considered black if its red, green and blue
/// channel are zero.
BitMatrix loadBinarized(String path) {
  final image = decodeImage(File(path).readAsBytesSync())!;
  final out = BitMatrix.createEmpty(image.width, image.height);
  for (var x = 0; x < image.width; x++) {
    for (var y = 0; y < image.height; y++) {
      var pixel = image.getPixel(x, y);
      out.set(x, y, pixel.r == 0 && pixel.g == 0 && pixel.b == 0);
    }
  }
  return out;
}
