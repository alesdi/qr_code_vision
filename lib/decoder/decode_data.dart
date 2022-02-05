import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';

import 'bit_stream.dart';
import 'shift_jis_table.dart';

class Chunk {
  final Mode type;
  final String? text;
  final List<int>? bytes;
  final int? assignmentNumber;

  Chunk({required this.type, this.text, this.bytes, this.assignmentNumber});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Chunk &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          text == other.text &&
          ListEquality().equals(bytes, other.bytes) &&
          assignmentNumber == other.assignmentNumber;

  @override
  int get hashCode =>
      type.hashCode ^
      text.hashCode ^
      bytes.hashCode ^
      assignmentNumber.hashCode;
}

class QrContent {
  String text;
  List<int> bytes;
  List<Chunk> chunks;
  int version;

  QrContent(
      {required this.text,
      required this.bytes,
      required this.chunks,
      required this.version});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QrContent &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          ListEquality().equals(bytes, other.bytes) &&
          ListEquality().equals(chunks, other.chunks) &&
          version == other.version;

  @override
  int get hashCode =>
      text.hashCode ^ bytes.hashCode ^ chunks.hashCode ^ version.hashCode;
}

enum Mode {
  numeric,
  alphanumeric,
  byte,
  kanji,
  eci,
}

enum ModeByte {
  terminator,
  numeric,
  alphanumeric,
  byte,
  kanji,
  eci,
}

const modeByteIndex = {
  ModeByte.terminator: 0,
  ModeByte.numeric: 1,
  ModeByte.alphanumeric: 2,
  ModeByte.byte: 4,
  ModeByte.kanji: 8,
  ModeByte.eci: 7,
};

class DecodedData {
  final String text;
  final List<int> bytes;

  DecodedData({required this.text, required this.bytes});
}

DecodedData decodeNumeric(BitStream stream, int size) {
  List<int> bytes = [];
  String text = "";

  final characterCountSize = [10, 12, 14][size];
  int length = stream.readBits(characterCountSize);
  // Read digits in groups of 3
  while (length >= 3) {
    final num = stream.readBits(10);
    if (num >= 1000) {
      throw Exception("Invalid numeric value above 999");
    }

    final a = (num / 100).floor();
    final b = (num / 10).floor() % 10;
    final c = num % 10;

    bytes.addAll([48 + a, 48 + b, 48 + c]);
    text += a.toString() + b.toString() + c.toString();
    length -= 3;
  }

  // If the number of digits aren't a multiple of 3, the remaining digits are special cased.
  if (length == 2) {
    final num = stream.readBits(7);
    if (num >= 100) {
      throw Exception("Invalid numeric value above 99");
    }

    final a = (num / 10).floor();
    final b = num % 10;

    bytes.addAll([48 + a, 48 + b]);
    text += a.toString() + b.toString();
  } else if (length == 1) {
    final num = stream.readBits(4);
    if (num >= 10) {
      throw Exception("Invalid numeric value above 9");
    }

    bytes.add(48 + num);
    text += num.toString();
  }

  return DecodedData(text: text, bytes: bytes);
}

final alphanumericCharacterCodes = [
  "0",
  "1",
  "2",
  "3",
  "4",
  "5",
  "6",
  "7",
  "8",
  "9",
  "A",
  "B",
  "C",
  "D",
  "E",
  "F",
  "G",
  "H",
  "I",
  "J",
  "K",
  "L",
  "M",
  "N",
  "O",
  "P",
  "Q",
  "R",
  "S",
  "T",
  "U",
  "V",
  "W",
  "X",
  "Y",
  "Z",
  " ",
  r"$",
  "%",
  "*",
  "+",
  "-",
  ".",
  "/",
  ":",
];

DecodedData decodeAlphanumeric(BitStream stream, int size) {
  final List<int> bytes = [];
  String text = "";

  final characterCountSize = [9, 11, 13][size];
  int length = stream.readBits(characterCountSize);
  while (length >= 2) {
    final v = stream.readBits(11);

    final a = (v / 45).floor();
    final b = v % 45;

    bytes.addAll([
      alphanumericCharacterCodes[a].codeUnitAt(0),
      alphanumericCharacterCodes[b].codeUnitAt(0),
    ]);
    text += alphanumericCharacterCodes[a] + alphanumericCharacterCodes[b];
    length -= 2;
  }

  if (length == 1) {
    final a = stream.readBits(6);
    bytes.add(alphanumericCharacterCodes[a].codeUnitAt(0));
    text += alphanumericCharacterCodes[a];
  }

  return DecodedData(text: text, bytes: bytes);
}

DecodedData decodeByte(BitStream stream, int size) {
  final List<int> bytes = [];
  String text = "";

  final characterCountSize = [8, 16, 16][size];
  final length = stream.readBits(characterCountSize);
  for (int i = 0; i < length; i++) {
    final b = stream.readBits(8);
    bytes.add(b);
  }
  try {
    text += utf8.decode(bytes);
    /*Uri.decodeComponent(bytes
        .map((b) => '%${("0" + b.toRadixString(16)).substring(-2)}')
        .join(""))*/
  } catch (e) {
    // failed to decode
  }

  return DecodedData(text: text, bytes: bytes);
}

DecodedData decodeKanji(BitStream stream, int size) {
  final List<int> bytes = [];
  String text = "";

  final characterCountSize = [8, 10, 12][size];
  final length = stream.readBits(characterCountSize);
  for (int i = 0; i < length; i++) {
    final k = stream.readBits(13);

    int c = ((k / 0xC0).floor() << 8) | (k % 0xC0);
    if (c < 0x1F00) {
      c += 0x8140;
    } else {
      c += 0xC140;
    }

    bytes.addAll([c >> 8, c & 0xFF]);
    text += String.fromCharCode(shiftJisTable[c]!);
  }

  return DecodedData(text: text, bytes: bytes);
}

QrContent? decodeData(Uint8ClampedList data, int version) {
  final stream = BitStream(data);

  // There are 3 'sizes' based on the version. 1-9 is small (0), 10-26 is medium (1) and 27-40 is large (2).
  final size = version <= 9
      ? 0
      : version <= 26
          ? 1
          : 2;

  QrContent result = QrContent(
    text: "",
    bytes: [],
    chunks: [],
    version: version,
  );

  while (stream.available() >= 4) {
    final mode = stream.readBits(4);
    if (mode == modeByteIndex[ModeByte.terminator]) {
      return result;
    } else if (mode == modeByteIndex[ModeByte.eci]) {
      if (stream.readBits(1) == 0) {
        result.chunks.add(Chunk(
          type: Mode.eci,
          assignmentNumber: stream.readBits(7),
        ));
      } else if (stream.readBits(1) == 0) {
        result.chunks.add(Chunk(
          type: Mode.eci,
          assignmentNumber: stream.readBits(14),
        ));
      } else if (stream.readBits(1) == 0) {
        result.chunks.add(Chunk(
          type: Mode.eci,
          assignmentNumber: stream.readBits(21),
        ));
      } else {
        // ECI data seems corrupted
        result.chunks.add(Chunk(
          type: Mode.eci,
          assignmentNumber: -1,
        ));
      }
    } else if (mode == modeByteIndex[ModeByte.numeric]) {
      final numericResult = decodeNumeric(stream, size);
      result.text += numericResult.text;
      result.bytes.addAll(numericResult.bytes);
      result.chunks.add(Chunk(
        type: Mode.numeric,
        text: numericResult.text,
      ));
    } else if (mode == modeByteIndex[ModeByte.alphanumeric]) {
      final alphanumericResult = decodeAlphanumeric(stream, size);
      result.text += alphanumericResult.text;
      result.bytes.addAll(alphanumericResult.bytes);
      result.chunks.add(Chunk(
        type: Mode.alphanumeric,
        text: alphanumericResult.text,
      ));
    } else if (mode == modeByteIndex[ModeByte.byte]) {
      final byteResult = decodeByte(stream, size);
      result.text += byteResult.text;
      result.bytes.addAll(byteResult.bytes);
      result.chunks.add(
        Chunk(
          type: Mode.byte,
          bytes: byteResult.bytes,
          text: byteResult.text,
        ),
      );
    } else if (mode == modeByteIndex[ModeByte.kanji]) {
      final kanjiResult = decodeKanji(stream, size);
      result.text += kanjiResult.text;
      result.bytes.addAll(kanjiResult.bytes);
      result.chunks.add(Chunk(
        type: Mode.kanji,
        bytes: kanjiResult.bytes,
        text: kanjiResult.text,
      ));
    }
  }

  // If there is no data left, or the remaining bits are all 0, then that counts as a termination marker
  if (stream.available() == 0 || stream.readBits(stream.available()) == 0) {
    return result;
  }
}
