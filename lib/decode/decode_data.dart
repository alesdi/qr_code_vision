import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

import 'shift_jis_table.dart';

/// Reads the content of QR code encoded data, according to its version.
QrContent? readData(Uint8ClampedList data, int version) {
  final stream = _BitStream(data);

  // There are 3 'sizes' based on the version. 1-9 is small (0), 10-26 is medium (1) and 27-40 is large (2).
  final size = version <= 9
      ? 0
      : version <= 26
          ? 1
          : 2;

  String text = "";
  List<int> bytes = [];
  List<Chunk> chunks = [];

  while (stream.available() >= 4) {
    final mode = stream.readBits(4);
    if (mode == _modeByteIndex[_ModeByte.terminator]) {
      return QrContent(
        text: text,
        bytes: bytes,
        chunks: chunks,
        version: version,
      );
    } else if (mode == _modeByteIndex[_ModeByte.eci]) {
      if (stream.readBits(1) == 0) {
        chunks.add(Chunk(
          type: ChunkMode.eci,
          assignmentNumber: stream.readBits(7),
        ));
      } else if (stream.readBits(1) == 0) {
        chunks.add(Chunk(
          type: ChunkMode.eci,
          assignmentNumber: stream.readBits(14),
        ));
      } else if (stream.readBits(1) == 0) {
        chunks.add(Chunk(
          type: ChunkMode.eci,
          assignmentNumber: stream.readBits(21),
        ));
      } else {
        // ECI data seems corrupted
        chunks.add(Chunk(
          type: ChunkMode.eci,
          assignmentNumber: -1,
        ));
      }
    } else if (mode == _modeByteIndex[_ModeByte.numeric]) {
      final numericResult = decodeNumeric(stream, size);
      text += numericResult.text;
      bytes.addAll(numericResult.bytes);
      chunks.add(Chunk(
        type: ChunkMode.numeric,
        text: numericResult.text,
      ));
    } else if (mode == _modeByteIndex[_ModeByte.alphanumeric]) {
      final alphanumericResult = _decodeAlphanumeric(stream, size);
      text += alphanumericResult.text;
      bytes.addAll(alphanumericResult.bytes);
      chunks.add(Chunk(
        type: ChunkMode.alphanumeric,
        text: alphanumericResult.text,
      ));
    } else if (mode == _modeByteIndex[_ModeByte.byte]) {
      final byteResult = _decodeByte(stream, size);
      text += byteResult.text;
      bytes.addAll(byteResult.bytes);
      chunks.add(
        Chunk(
          type: ChunkMode.byte,
          bytes: byteResult.bytes,
          text: byteResult.text,
        ),
      );
    } else if (mode == _modeByteIndex[_ModeByte.kanji]) {
      final kanjiResult = _decodeKanji(stream, size);
      text += kanjiResult.text;
      bytes.addAll(kanjiResult.bytes);
      chunks.add(Chunk(
        type: ChunkMode.kanji,
        bytes: kanjiResult.bytes,
        text: kanjiResult.text,
      ));
    }
  }

  // If there is no data left, or the remaining bits are all 0, then that counts as a termination marker
  if (stream.available() == 0 || stream.readBits(stream.available()) == 0) {
    return QrContent(
      text: text,
      bytes: bytes,
      chunks: chunks,
      version: version,
    );
  }
  return null;
}

/// The content of a QR code, that may consist of binary or text content,
/// divided up into one or more chunks.
class QrContent extends Equatable {
  final String text;
  final List<int> bytes;
  final List<Chunk> chunks;
  final int version;

  QrContent(
      {required this.text,
      required this.bytes,
      required this.chunks,
      required this.version});

  @override
  List<Object> get props => [text, bytes, chunks, version];
}

/// A chunk of data inside a QR code
class Chunk {
  final ChunkMode type;
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

/// The type of Chunk
enum ChunkMode {
  numeric,
  alphanumeric,
  byte,
  kanji,
  eci,
}

enum _ModeByte {
  terminator,
  numeric,
  alphanumeric,
  byte,
  kanji,
  eci,
}

const _modeByteIndex = {
  _ModeByte.terminator: 0,
  _ModeByte.numeric: 1,
  _ModeByte.alphanumeric: 2,
  _ModeByte.byte: 4,
  _ModeByte.kanji: 8,
  _ModeByte.eci: 7,
};

class _ChunkContent {
  final String text;
  final List<int> bytes;

  _ChunkContent({required this.text, required this.bytes});
}

_ChunkContent decodeNumeric(_BitStream stream, int size) {
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

  return _ChunkContent(text: text, bytes: bytes);
}

final _alphanumericCharacterCodes = [
  "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", //
  "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", //
  "U", "V", "W", "X", "Y", "Z", " ", r"$", "%", "*", "+", "-", ".", "/", ":"
];

_ChunkContent _decodeAlphanumeric(_BitStream stream, int size) {
  final List<int> bytes = [];
  String text = "";

  final characterCountSize = [9, 11, 13][size];
  int length = stream.readBits(characterCountSize);
  while (length >= 2) {
    final v = stream.readBits(11);

    final a = (v / 45).floor();
    final b = v % 45;

    bytes.addAll([
      _alphanumericCharacterCodes[a].codeUnitAt(0),
      _alphanumericCharacterCodes[b].codeUnitAt(0),
    ]);
    text += _alphanumericCharacterCodes[a] + _alphanumericCharacterCodes[b];
    length -= 2;
  }

  if (length == 1) {
    final a = stream.readBits(6);
    bytes.add(_alphanumericCharacterCodes[a].codeUnitAt(0));
    text += _alphanumericCharacterCodes[a];
  }

  return _ChunkContent(text: text, bytes: bytes);
}

_ChunkContent _decodeByte(_BitStream stream, int size) {
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
  } catch (e) {
    // failed to decode
  }

  return _ChunkContent(text: text, bytes: bytes);
}

_ChunkContent _decodeKanji(_BitStream stream, int size) {
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

  return _ChunkContent(text: text, bytes: bytes);
}

class _BitStream {
  Uint8ClampedList bytes;
  int byteOffset = 0;
  int bitOffset = 0;

  _BitStream(this.bytes);

  int readBits(int numBits) {
    if (numBits < 1 || numBits > 32 || numBits > available()) {
      throw Exception("Cannot read $numBits bits");
    }

    int result = 0;
    // First, read remainder from current byte
    if (bitOffset > 0) {
      final bitsLeft = 8 - bitOffset;
      final toRead = numBits < bitsLeft ? numBits : bitsLeft;
      final bitsToNotRead = bitsLeft - toRead;
      final mask = (0xFF >> (8 - toRead)) << bitsToNotRead;
      result = (bytes[byteOffset] & mask) >> bitsToNotRead;
      numBits -= toRead;
      bitOffset += toRead;
      if (bitOffset == 8) {
        bitOffset = 0;
        byteOffset++;
      }
    }

    // Next read whole bytes
    if (numBits > 0) {
      while (numBits >= 8) {
        result = (result << 8) | (bytes[byteOffset] & 0xFF);
        byteOffset++;
        numBits -= 8;
      }

      // Finally read a partial byte
      if (numBits > 0) {
        final bitsToNotRead = 8 - numBits;
        final mask = (0xFF >> bitsToNotRead) << bitsToNotRead;
        result =
            (result << numBits) | ((bytes[byteOffset] & mask) >> bitsToNotRead);
        bitOffset += numBits;
      }
    }
    return result;
  }

  int available() {
    return 8 * (bytes.length - byteOffset) - bitOffset;
  }
}
