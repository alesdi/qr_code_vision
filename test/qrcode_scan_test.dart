import 'dart:io';
import 'dart:math';

import 'package:barcode_image/barcode_image.dart';
import 'package:image/image.dart';
import 'package:qr_code_vision/qr_code_vision.dart';
import 'package:test/test.dart';

void main() {
  test('can locate and decode totp qr code without margin', () {
    final imageBytes =
        File("./test/qrcode_scan_test_data/otp_qr_code.png").readAsBytesSync();
    final qrCode = new QrCode();
    qrCode.scanImageBytes(imageBytes);
    expect(qrCode.location, isNotNull);
    expect(qrCode.content?.text,
        "otpauth://totp/max.musterman%40gate.company.test?secret=CNIA7THKN26W4B7RYIOUFKOL4ZVFKWPYUDJGFNLOXHOMCVBP7IRZ%3D%3D%3D%3D&algorithm=SHA256&issuer=company&period=60");
  });

  const randomQrCodesThatDoNotWork = {
    108: {15, 43},
    110: {48},
    112: {13},
    113: {22, 39, 49},
    114: {0},
    115: {89, 96},
    116: {47},
    117: {26},
    118: {45},
    119: {58, 60},
    122: {8, 58},
    123: {7, 33, 61},
    127: {1},
    128: {5, 29, 57},
    129: {69},
    130: {2, 37, 44},
    159: {21},
    164: {5, 53},
    169: {79},
    177: {60},
    183: {23},
    186: {51},
    190: {43, 72},
    191: {3}
  };

  test('can locate and parse perfect qr codes', () {
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890:/#%';
    Random _rnd = Random(1234); // constant seed
    String getRandomString(int length) =>
        String.fromCharCodes(Iterable.generate(
            length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

    final image = Image(width: 147, height: 147);
    for (int len = 70; len < 200; len++) {
      for (int i = 0; i < 100; i++) {
        String data = getRandomString(len);
        //print(data);
        if (randomQrCodesThatDoNotWork[len]?.contains(i) ?? false) {
          continue;
        }
        fill(image, color: ColorRgb8(255, 255, 255));
        drawBarcode(image, Barcode.qrCode(), data);

        final qrCode = new QrCode();
        qrCode.scanImage(image);

        File? qrFile;
        if (qrCode.location == null || qrCode.content?.text != data) {
          final dir = Directory.systemTemp.createTempSync();
          qrFile = File("${dir.path}/qr_code_error.png");
          qrFile.writeAsBytesSync(encodePng(image));
        }

        final reason = "Length: $len, Iteration: $i, QR code: ${qrFile?.path}";
        expect(qrCode.location, isNotNull, reason: reason);
        expect(qrCode.content?.text, data, reason: reason);
      }
    }
  });

  test('can locate and decode qr code len 108 iteration 15', () {
    final image = Image(width: 147, height: 147);
    fill(image, color: ColorRgb8(255, 255, 255));
    drawBarcode(image, Barcode.qrCode(),
        "/xLNd%xnbTnZPs09BgZ2fz7r/CeFh7ZszQmYn4ZKkp362SLgWiYhd9NebDw1fTVG#Vg4CR0gVuhkKV5d:u47LyW71IQNFtmwLsGC/V8kgl6F");

    final dir = Directory.systemTemp.createTempSync();
    final qrFile = File("${dir.path}/qr_code.png");
    qrFile.writeAsBytesSync(encodePng(image));
    print(qrFile);

    final qrCode = new QrCode();
    qrCode.scanImage(image);
    expect(qrCode.location, isNotNull);
    expect(qrCode.content?.text,
        "/xLNd%xnbTnZPs09BgZ2fz7r/CeFh7ZszQmYn4ZKkp362SLgWiYhd9NebDw1fTVG#Vg4CR0gVuhkKV5d:u47LyW71IQNFtmwLsGC/V8kgl6F");
  });

  test('can locate and decode qr code len 108 iteration 43', () {
    final image = Image(width: 147, height: 147);
    fill(image, color: ColorRgb8(255, 255, 255));
    drawBarcode(image, Barcode.qrCode(),
        "y:9nvASVAnIMCSEofmdR%3/j3dhjF8cR3zOx6gRXk#4pDPdmlRt3asm9Gd3/kZoNSMIUm0%#HOwujc1mcjjId09GYhFveIn94v2omKmwbwgR");

    final dir = Directory.systemTemp.createTempSync();
    final qrFile = File("${dir.path}/qr_code.png");
    qrFile.writeAsBytesSync(encodePng(image));
    print(qrFile);

    final qrCode = new QrCode();
    qrCode.scanImage(image);
    expect(qrCode.location, isNotNull);
    expect(qrCode.content?.text,
        "y:9nvASVAnIMCSEofmdR%3/j3dhjF8cR3zOx6gRXk#4pDPdmlRt3asm9Gd3/kZoNSMIUm0%#HOwujc1mcjjId09GYhFveIn94v2omKmwbwgR");
  });

  test('can locate and decode qr code len 110 iteration 48', () {
    final image = Image(width: 147, height: 147);
    fill(image, color: ColorRgb8(255, 255, 255));
    drawBarcode(image, Barcode.qrCode(),
        "xs58fteTIRST:lDKuiVFWUP:SQ#1pp9cP2kAIr4M%YaIlwCkbxO/XL8o38UMx/0:3FpCvgPnT2%rdYsTOUK8ceM/hutHhf:bJsTyX2NJ2ZjHjW");

    final dir = Directory.systemTemp.createTempSync();
    final qrFile = File("${dir.path}/qr_code.png");
    qrFile.writeAsBytesSync(encodePng(image));
    print(qrFile);

    final qrCode = new QrCode();
    qrCode.scanImage(image);
    expect(qrCode.location, isNotNull);
    expect(qrCode.content?.text,
        "xs58fteTIRST:lDKuiVFWUP:SQ#1pp9cP2kAIr4M%YaIlwCkbxO/XL8o38UMx/0:3FpCvgPnT2%rdYsTOUK8ceM/hutHhf:bJsTyX2NJ2ZjHjW");
  });
}
