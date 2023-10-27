import 'dart:io';

import 'package:qr_code_vision/qr_code_vision.dart';
import 'package:test/test.dart';

void main() {
  test('can locate and decode totp qr code without margin', () {
    final imageBytes = File("./test/qrcode_scan_test_data/otp_qr_code.png").readAsBytesSync();
    var qrCode = new QrCode();
    qrCode.scanImageBytes(imageBytes);
    expect(qrCode.location, isNotNull);
    expect(qrCode.content?.text,
        "otpauth://totp/max.musterman%40gate.company.test?secret=CNIA7THKN26W4B7RYIOUFKOL4ZVFKWPYUDJGFNLOXHOMCVBP7IRZ%3D%3D%3D%3D&algorithm=SHA256&issuer=company&period=60");
  });
}
