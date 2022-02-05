import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:qr_code_vision/decoder/decode_data.dart';
import 'package:qr_code_vision/decoder/decoder.dart';
import 'package:qr_code_vision/entities/bit_matrix.dart';

import 'helpers.dart';

void main() {
  const imagesPath = "./test/decoder-test-data/";

  test('decodes a numeric code', () {
    final data = loadBinarized("$imagesPath/numeric.png");
    expect(
      decode(data),
      DecodedQr(
        text: "123456789",
        bytes: [49, 50, 51, 52, 53, 54, 55, 56, 57],
        chunks: [Chunk(type: Mode.numeric, text: "123456789")],
        version: 1,
      ),
    );
  });

  test('decodes an alphanumeric code', () {
    final data = loadBinarized("$imagesPath/alphanumeric.png");
    expect(
      decode(data),
      DecodedQr(
        text: "ABCD1234",
        bytes: [65, 66, 67, 68, 49, 50, 51, 52],
        chunks: [Chunk(type: Mode.alphanumeric, text: "ABCD1234")],
        version: 1,
      ),
    );
  });

  test('decodes a byte code', () {
    final data = loadBinarized("$imagesPath/byte.png");
    expect(
      decode(data),
      DecodedQr(
        text: "Test",
        bytes: [84, 101, 115, 116],
        chunks: [
          Chunk(type: Mode.byte, bytes: [84, 101, 115, 116], text: "Test")
        ],
        version: 1,
      ),
    );
  });

  test('decodes a kanji code', () {
    final data = loadBinarized("$imagesPath/kanji.png");
    final actual = decode(data);
    final expected = DecodedQr(
      text: "テスト",
      bytes: [131, 101, 131, 88, 131, 103],
      chunks: [
        Chunk(
          type: Mode.kanji,
          bytes: [131, 101, 131, 88, 131, 103],
          text: "テスト",
        )
      ],
      version: 1,
    );
    expect(actual, expected);
  });

  test('decodes a mixed code', () {
    final data = loadBinarized("$imagesPath/mixed.png");
    final actual = decode(data);
    final expected = DecodedQr(
      text: "123456789ABCD1234Testテスト",
      bytes: [
        49, 50, 51, 52, 53, 54, 55, 56, 57, 65, 66, 67, 68, 49, 50, 51, 52, //
        84, 101, 115, 116, 131, 101, 131, 88, 131, 103
      ],
      chunks: [
        Chunk(type: Mode.numeric, text: "123456789"),
        Chunk(type: Mode.alphanumeric, text: "ABCD1234"),
        Chunk(type: Mode.byte, bytes: [84, 101, 115, 116], text: "Test"),
        Chunk(
            type: Mode.kanji,
            bytes: [131, 101, 131, 88, 131, 103],
            text: "テスト"),
      ],
      version: 2,
    );
    expect(actual, expected);
  });

  test("returns null if there aren't enough codewords in the matrix", () {
    // This matrix decodes to an empty byte array, but shouldn't decode at all
    final d = Uint8ClampedList.fromList(
        File("$imagesPath/truncated-null.bin").readAsBytesSync());
    final matrix = BitMatrix(d, sqrt(d.length).toInt());
    expect(decode(matrix), null);
  });

  test(
      "returns null if there aren't enough codewords in the matrix (corrupted)",
      () {
    // This matrix decodes to an empty byte array, but shouldn't decode at all
    final d = Uint8ClampedList.fromList(
        File("$imagesPath/truncated-corrupted.bin").readAsBytesSync());
    final matrix = BitMatrix(d, sqrt(d.length).toInt());
    expect(decode(matrix), null);
  });

  test('Supports ECI chunks', () {
    final data = loadBinarized("$imagesPath/eci.png");
    final actual = decode(data);
    final expected = DecodedQr(
      text: "7948,328,1019,149,12,12,15,4,14,11,32,4",
      bytes: [
        55, 57, 52, 56, 44, 51, 50, 56, 44, 49, 48, 49, 57, 44, 49, 52, //
        57, 44, 49, 50, 44, 49, 50, 44, 49, 53, 44, 52, 44, 49, 52, 44, 49, //
        49, 44, 51, 50, 44, 52
      ],
      chunks: [
        Chunk(
          type: Mode.eci,
          assignmentNumber: 26,
        ),
        Chunk(
          type: Mode.byte,
          bytes: [
            55, 57, 52, 56, 44, 51, 50, 56, 44, 49, 48, 49, 57, 44, 49, //
            52, 57, 44, 49, 50, 44, 49, 50, 44, 49, 53, 44, 52, 44, 49, 52, //
            44, 49, 49, 44, 51, 50, 44, 52
          ],
          text: "7948,328,1019,149,12,12,15,4,14,11,32,4",
        ),
      ],
      version: 3,
    );
    expect(actual, expected);
  });

  test('Extracts a QR code that is missing the termination byte', () {
    final data = loadBinarized("$imagesPath/no-termination-byte.png");
    final actual = decode(data);
    final expected = DecodedQr(
      text: "1788c74b1c9262866c2071b65df7bfcb7911c2b064c931b580515c2d9d2cd7f8",
      bytes: [
        49, 55, 56, 56, 99, 55, 52, 98, 49, 99, 57, 50, 54, 50, 56, //
        54, 54, 99, 50, 48, 55, 49, 98, 54, 53, 100, 102, 55, 98, 102, 99, //
        98, 55, 57, 49, 49, 99, 50, 98, 48, 54, 52, 99, 57, 51, 49, 98, 53, //
        56, 48, 53, 49, 53, 99, 50, 100, 57, 100, 50, 99, 100, 55, 102, 56
      ],
      chunks: [
        Chunk(
          type: Mode.numeric,
          text: "1788",
        ),
        Chunk(
          type: Mode.byte,
          bytes: [99, 55, 52, 98, 49, 99],
          text: "c74b1c",
        ),
        Chunk(
          type: Mode.numeric,
          text: "9262866",
        ),
        Chunk(
          type: Mode.byte,
          bytes: [
            99, 50, 48, 55, 49, 98, 54, 53, 100, 102, 55, 98, 102, 99, 98, //
            55, 57, 49, 49, 99, 50, 98, 48, 54, 52, 99, 57, 51, 49, 98
          ],
          text: "c2071b65df7bfcb7911c2b064c931b",
        ),
        Chunk(
          type: Mode.numeric,
          text: "580515",
        ),
        Chunk(
          type: Mode.byte,
          bytes: [99, 50, 100, 57, 100, 50, 99, 100, 55, 102, 56],
          text: "c2d9d2cd7f8",
        ),
      ],
      version: 4,
    );
    expect(actual, expected);
  });
}
