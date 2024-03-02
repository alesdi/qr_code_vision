import 'dart:io';
import 'dart:math';

import 'package:barcode_image/barcode_image.dart';
import 'package:image/image.dart';
import 'package:qr_code_vision/qr_code_vision.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  group("QR Scanner", () {
    test('can locate and decode totp qr code without margin', () {
      final imageBytes = File("./test/qrcode_scan_test_data/otp_qr_code.png")
          .readAsBytesSync();
      final qrCode = new QrCode();
      qrCode.scanImageBytes(imageBytes);
      expect(qrCode.location, isNotNull);
      expect(qrCode.content?.text,
          "otpauth://totp/max.musterman%40gate.company.test?secret=CNIA7THKN26W4B7RYIOUFKOL4ZVFKWPYUDJGFNLOXHOMCVBP7IRZ%3D%3D%3D%3D&algorithm=SHA256&issuer=company&period=60");
    });

    test('can locate and decode totp qr code with transparency', () {
      // This QR Code has transparent instead of white pixels
      final imageBytes =
          File("./test/qrcode_scan_test_data/otp_qr_code_with_transparency.png")
              .readAsBytesSync();
      final qrCode = new QrCode();
      qrCode.scanImageBytes(imageBytes);
      expect(qrCode.location, isNotNull);
      expect(qrCode.content?.text,
          "otpauth://totp/max.musterman%40gate.company.test?secret=CNIA7THKN26W4B7RYIOUFKOL4ZVFKWPYUDJGFNLOXHOMCVBP7IRZ%3D%3D%3D%3D&algorithm=SHA256&issuer=company&period=60");
    });

    test(
        'can locate and decode totp qr code from windows clipboard with transparency',
        () {
      // When copying a PNG file with transparency rendered in a browser to the windows clipboard
      // (right-click -> copy image) the PNG is converted into a BMP.
      // The BMP has a header (BITMAPINFOHEADER) which, according to the spec, does not support transparency.
      // However, the alpha value of each pixel is still encoded in the file since
      // every pixel has 4 bytes with 1 byte per channel which leaves an unused extra byte.
      // Every PNG decoder that follows the spec, like the dart BMPDecoder, ignores the extra byte.
      // The result is a completely black image.
      //
      // This library should detect this and decode the BMP preserving transparency
      final imageBytes = File(
              "./test/qrcode_scan_test_data/otp_qr_code_with_transparency_from_windows_clipboard.bmp")
          .readAsBytesSync();
      final qrCode = new QrCode();
      qrCode.scanImageBytes(imageBytes);
      expect(qrCode.location, isNotNull);
      expect(qrCode.content?.text,
          "otpauth://totp/max.musterman%40gate.company.test?secret=CNIA7THKN26W4B7RYIOUFKOL4ZVFKWPYUDJGFNLOXHOMCVBP7IRZ%3D%3D%3D%3D&algorithm=SHA256&issuer=company&period=60");
    });

    test('can scan perfect qr codes with low error correction level', () {
      // Generate QR codes with random content of increasing length and assert
      // that the scanner can locate and decode them correctly.
      Random rnd = Random(1234); // constant seed
      final image = Image(width: 147, height: 147);
      for (int len = 70; len < 200; len++) {
        for (int i = 0; i < 100; i++) {
          String data = generateRandomString(len, rnd);
          fill(image, color: ColorRgb8(255, 255, 255));
          drawBarcode(image, Barcode.qrCode(), data);

          final qrCode = new QrCode();
          qrCode.scanImage(image);

          // If the detection and decoding fails dump the QR code into an
          // image file for debugging.
          File? qr;
          if (qrCode.location == null || qrCode.content?.text != data) {
            qr = dumpImageToFile(image, "qr_code_error");
          }

          final reason = "Length: $len, Iteration: $i, QR code: ${qr?.path}";
          expect(qrCode.location, isNotNull, reason: reason);
          expect(qrCode.content?.text, data, reason: reason);
        }
      }
    });
  });
}
