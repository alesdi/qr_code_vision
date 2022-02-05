import 'dart:typed_data';

import 'package:dart_reed_solomon/dart_reed_solomon.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_vision/decoder/version.dart';
import 'package:qr_code_vision/qr_code_vision.dart';

import 'decode_data.dart';

int numBitsDiffering(int x, int y) {
  var z = x ^ y;
  var bitCount = 0;
  while (z != 0x0) {
    bitCount++;
    z &= z - 1;
  }
  return bitCount;
}

int pushBit(bool bit, int byte) {
  return (byte << 1) | (bit ? 1 : 0);
}

class FormatInfo {
  final int errorCorrectionLevel;
  final int dataMask;

  const FormatInfo({
    required this.errorCorrectionLevel,
    required this.dataMask,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FormatInfo &&
          runtimeType == other.runtimeType &&
          errorCorrectionLevel == other.errorCorrectionLevel &&
          dataMask == other.dataMask;

  @override
  int get hashCode => hashValues(errorCorrectionLevel, dataMask);
}

const FORMAT_INFO_TABLE = {
  0x5412: FormatInfo(errorCorrectionLevel: 1, dataMask: 0),
  0x5125: FormatInfo(errorCorrectionLevel: 1, dataMask: 1),
  0x5E7C: FormatInfo(errorCorrectionLevel: 1, dataMask: 2),
  0x5B4B: FormatInfo(errorCorrectionLevel: 1, dataMask: 3),
  0x45F9: FormatInfo(errorCorrectionLevel: 1, dataMask: 4),
  0x40CE: FormatInfo(errorCorrectionLevel: 1, dataMask: 5),
  0x4F97: FormatInfo(errorCorrectionLevel: 1, dataMask: 6),
  0x4AA0: FormatInfo(errorCorrectionLevel: 1, dataMask: 7),
  0x77C4: FormatInfo(errorCorrectionLevel: 0, dataMask: 0),
  0x72F3: FormatInfo(errorCorrectionLevel: 0, dataMask: 1),
  0x7DAA: FormatInfo(errorCorrectionLevel: 0, dataMask: 2),
  0x789D: FormatInfo(errorCorrectionLevel: 0, dataMask: 3),
  0x662F: FormatInfo(errorCorrectionLevel: 0, dataMask: 4),
  0x6318: FormatInfo(errorCorrectionLevel: 0, dataMask: 5),
  0x6C41: FormatInfo(errorCorrectionLevel: 0, dataMask: 6),
  0x6976: FormatInfo(errorCorrectionLevel: 0, dataMask: 7),
  0x1689: FormatInfo(errorCorrectionLevel: 3, dataMask: 0),
  0x13BE: FormatInfo(errorCorrectionLevel: 3, dataMask: 1),
  0x1CE7: FormatInfo(errorCorrectionLevel: 3, dataMask: 2),
  0x19D0: FormatInfo(errorCorrectionLevel: 3, dataMask: 3),
  0x0762: FormatInfo(errorCorrectionLevel: 3, dataMask: 4),
  0x0255: FormatInfo(errorCorrectionLevel: 3, dataMask: 5),
  0x0D0C: FormatInfo(errorCorrectionLevel: 3, dataMask: 6),
  0x083B: FormatInfo(errorCorrectionLevel: 3, dataMask: 7),
  0x355F: FormatInfo(errorCorrectionLevel: 2, dataMask: 0),
  0x3068: FormatInfo(errorCorrectionLevel: 2, dataMask: 1),
  0x3F31: FormatInfo(errorCorrectionLevel: 2, dataMask: 2),
  0x3A06: FormatInfo(errorCorrectionLevel: 2, dataMask: 3),
  0x24B4: FormatInfo(errorCorrectionLevel: 2, dataMask: 4),
  0x2183: FormatInfo(errorCorrectionLevel: 2, dataMask: 5),
  0x2EDA: FormatInfo(errorCorrectionLevel: 2, dataMask: 6),
  0x2BED: FormatInfo(errorCorrectionLevel: 2, dataMask: 7),
};

class IntPosition {
  final int x;
  final int y;

  IntPosition(this.x, this.y);
}

final dataMasks = [
  (IntPosition p) => ((p.y + p.x) % 2) == 0,
  (IntPosition p) => (p.y % 2) == 0,
  (IntPosition p) => p.x % 3 == 0,
  (IntPosition p) => (p.y + p.x) % 3 == 0,
  (IntPosition p) => ((p.y / 2).floor() + (p.x / 3).floor()) % 2 == 0,
  (IntPosition p) => ((p.x * p.y) % 2) + ((p.x * p.y) % 3) == 0,
  (IntPosition p) => ((((p.y * p.x) % 2) + (p.y * p.x) % 3) % 2) == 0,
  (IntPosition p) => ((((p.y + p.x) % 2) + (p.y * p.x) % 3) % 2) == 0,
];

BitMatrix buildFunctionPatternMask(Version version) {
  var dimension = 17 + 4 * version.versionNumber;
  var matrix = BitMatrix.createEmpty(dimension, dimension);
  matrix.setRegion(
      0, 0, 9, 9, true); // Top left finder pattern + separator + format
  matrix.setRegion(dimension - 8, 0, 8, 9,
      true); // Top right finder pattern + separator + format
  matrix.setRegion(0, dimension - 8, 9, 8,
      true); // Bottom left finder pattern + separator + format
  // Alignment patterns
  for (var _i = 0, _a = version.alignmentPatternCenters; _i < _a.length; _i++) {
    var x = _a[_i];
    for (var _b = 0, _c = version.alignmentPatternCenters;
        _b < _c.length;
        _b++) {
      var y = _c[_b];
      if (!(x == 6 && y == 6 ||
          x == 6 && y == dimension - 7 ||
          x == dimension - 7 && y == 6)) {
        matrix.setRegion(x - 2, y - 2, 5, 5, true);
      }
    }
  }
  matrix.setRegion(6, 9, 1, dimension - 17, true); // Vertical timing pattern
  matrix.setRegion(9, 6, dimension - 17, 1, true); // Horizontal timing pattern
  if (version.versionNumber > 6) {
    matrix.setRegion(dimension - 11, 0, 3, 6, true); // Version info, top right
    matrix.setRegion(
        0, dimension - 11, 6, 3, true); // Version info, bottom left
  }
  return matrix;
}

List<int> readCodewords(
    BitMatrix matrix, Version version, FormatInfo formatInfo) {
  final dataMask = dataMasks[formatInfo.dataMask];
  final dimension = matrix.height;
  final functionPatternMask = buildFunctionPatternMask(version);
  final codewords = <int>[];
  int currentByte = 0;
  int bitsRead = 0;
  // Read columns in pairs, from right to left
  var readingUp = true;
  for (var columnIndex = dimension - 1; columnIndex > 0; columnIndex -= 2) {
    if (columnIndex == 6) {
      // Skip whole column with vertical alignment pattern;
      columnIndex--;
    }
    for (var i = 0; i < dimension; i++) {
      var y = readingUp ? dimension - 1 - i : i;
      for (var columnOffset = 0; columnOffset < 2; columnOffset++) {
        var x = columnIndex - columnOffset;
        if (!functionPatternMask.get(x, y)) {
          bitsRead++;
          var bit = matrix.get(x, y);
          if (dataMask(IntPosition(x, y))) {
            bit = !bit;
          }
          currentByte = pushBit(bit, currentByte);
          if (bitsRead == 8) {
            // Whole bytes
            codewords.add(currentByte);
            bitsRead = 0;
            currentByte = 0;
          }
        }
      }
    }
    readingUp = !readingUp;
  }
  return codewords;
}

Version? readVersion(BitMatrix matrix) {
  int dimension = matrix.height;
  int provisionalVersion = ((dimension - 17) / 4).floor();
  if (provisionalVersion <= 6) {
    // 6 and under don't have version info in the QR code
    return versions[provisionalVersion - 1];
  }
  var topRightVersionBits = 0;
  for (var y = 5; y >= 0; y--) {
    for (var x = dimension - 9; x >= dimension - 11; x--) {
      topRightVersionBits = pushBit(matrix.get(x, y), topRightVersionBits);
    }
  }
  var bottomLeftVersionBits = 0;
  for (var x = 5; x >= 0; x--) {
    for (var y = dimension - 9; y >= dimension - 11; y--) {
      bottomLeftVersionBits = pushBit(matrix.get(x, y), bottomLeftVersionBits);
    }
  }
  double bestDifference = double.infinity;
  Version? bestVersion;
  for (var _i = 0; _i < versions.length; _i++) {
    var version = versions[_i];
    if (version.infoBits == topRightVersionBits ||
        version.infoBits == bottomLeftVersionBits) {
      return version;
    }
    var difference =
        numBitsDiffering(topRightVersionBits, version.infoBits ?? 0);
    if (difference < bestDifference) {
      bestVersion = version;
      bestDifference = difference.toDouble();
    }
    difference = numBitsDiffering(bottomLeftVersionBits, version.infoBits ?? 0);
    if (difference < bestDifference) {
      bestVersion = version;
      bestDifference = difference.toDouble();
    }
  }
  // We can tolerate up to 3 bits of error since no two version info codewords will
  // differ in less than 8 bits.
  if (bestDifference <= 3) {
    return bestVersion;
  }
}

FormatInfo? readFormatInformation(BitMatrix matrix) {
  int topLeftFormatInfoBits = 0;
  for (int x = 0; x <= 8; x++) {
    if (x != 6) {
      // Skip timing pattern bit
      topLeftFormatInfoBits = pushBit(matrix.get(x, 8), topLeftFormatInfoBits);
    }
  }
  for (int y = 7; y >= 0; y--) {
    if (y != 6) {
      // Skip timing pattern bit
      topLeftFormatInfoBits = pushBit(matrix.get(8, y), topLeftFormatInfoBits);
    }
  }
  int dimension = matrix.height;
  int topRightBottomRightFormatInfoBits = 0;
  for (int y = dimension - 1; y >= dimension - 7; y--) {
    // bottom left
    topRightBottomRightFormatInfoBits =
        pushBit(matrix.get(8, y), topRightBottomRightFormatInfoBits);
  }
  for (int x = dimension - 8; x < dimension; x++) {
    // top right
    topRightBottomRightFormatInfoBits =
        pushBit(matrix.get(x, 8), topRightBottomRightFormatInfoBits);
  }
  double bestDifference = double.infinity;
  FormatInfo? bestFormatInfo;
  for (var _a in FORMAT_INFO_TABLE.entries) {
    var bits = _a.key, formatInfo = _a.value;
    if (bits == topLeftFormatInfoBits ||
        bits == topRightBottomRightFormatInfoBits) {
      return formatInfo;
    }
    var difference = numBitsDiffering(topLeftFormatInfoBits, bits);
    if (difference < bestDifference) {
      bestFormatInfo = formatInfo;
      bestDifference = difference.toDouble();
    }
    if (topLeftFormatInfoBits != topRightBottomRightFormatInfoBits) {
      // also try the other option
      difference = numBitsDiffering(topRightBottomRightFormatInfoBits, bits);
      if (difference < bestDifference) {
        bestFormatInfo = formatInfo;
        bestDifference = difference.toDouble();
      }
    }
  }
  // Hamming distance of the 32 masked codes is 7, by construction, so <= 3 bits differing means we found a match
  if (bestDifference <= 3) {
    return bestFormatInfo;
  }
  return null;
}

class DataBlock {
  final int numDataCodewords;
  final List<int> codewords;

  const DataBlock({required this.numDataCodewords, required this.codewords});
}

List<DataBlock>? getDataBlocks(
    List<int> codewords, Version version, int ecLevel) {
  ErrorCorrectionLevel ecInfo = version.errorCorrectionLevels[ecLevel];
  List<DataBlock> dataBlocks = [];
  var totalCodewords = 0;
  for (var block in ecInfo.ecBlocks) {
    for (var i = 0; i < block.numBlocks; i++) {
      dataBlocks.add(DataBlock(
          numDataCodewords: block.dataCodewordsPerBlock, codewords: []));
      totalCodewords +=
          block.dataCodewordsPerBlock + ecInfo.ecCodewordsPerBlock;
    }
  }
  // In some cases the QR code will be malformed enough that we pull off more or less than we should.
  // If we pull off less there's nothing we can do.
  // If we pull off more we can safely truncate
  if (codewords.length < totalCodewords) {
    return null;
  }
  codewords = codewords.sublist(0, totalCodewords);
  var shortBlockSize = ecInfo.ecBlocks.first.dataCodewordsPerBlock;
  // Pull codewords to fill the blocks up to the minimum size
  for (var i = 0; i < shortBlockSize; i++) {
    for (var _i = 0, dataBlocks_1 = dataBlocks;
        _i < dataBlocks_1.length;
        _i++) {
      var dataBlock = dataBlocks_1[_i];
      dataBlock.codewords.add(codewords.removeAt(0));
    }
  }
  // If there are any large blocks, pull codewords to fill the last element of those
  if (ecInfo.ecBlocks.length > 1) {
    var smallBlockCount = ecInfo.ecBlocks[0].numBlocks;
    var largeBlockCount = ecInfo.ecBlocks[1].numBlocks;
    for (var i = 0; i < largeBlockCount; i++) {
      dataBlocks[smallBlockCount + i].codewords.add(codewords.removeAt(0));
    }
  }
  // Add the rest of the codewords to the blocks. These are the error correction codewords.
  while (codewords.isNotEmpty) {
    for (var _a = 0, dataBlocks_2 = dataBlocks;
        _a < dataBlocks_2.length;
        _a++) {
      var dataBlock = dataBlocks_2[_a];
      dataBlock.codewords.add(codewords.removeAt(0));
    }
  }
  return dataBlocks;
}

DecodedQr? decodeMatrix(matrix) {
  var version = readVersion(matrix);
  if (version == null) {
    return null;
  }
  var formatInfo = readFormatInformation(matrix);
  if (formatInfo == null) {
    return null;
  }
  var codewords = readCodewords(matrix, version, formatInfo);
  var dataBlocks =
      getDataBlocks(codewords, version, formatInfo.errorCorrectionLevel);
  if (dataBlocks == null) {
    return null;
  }
  // Count total number of data bytes
  var totalBytes = dataBlocks.fold<int>(0, (a, b) => a + b.numDataCodewords);
  var resultBytes = Uint8ClampedList(totalBytes);
  var resultIndex = 0;
  for (final dataBlock in dataBlocks) {
    final reedSolomon = ReedSolomon(
      symbolSizeInBits: 8,
      numberOfCorrectableSymbols:
          (dataBlock.codewords.length - dataBlock.numDataCodewords) ~/ 2,
      primitivePolynomial: 0x011D,
      initialRoot: 0,
    );

    try {
      var correctedBytes = reedSolomon.decode(dataBlock.codewords);
      for (var i = 0; i < dataBlock.numDataCodewords; i++) {
        resultBytes[resultIndex++] = correctedBytes[i];
      }
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }
  try {
    return decodeData(resultBytes, version.versionNumber);
  } catch (_a) {
    return null;
  }
}

DecodedQr? decode(BitMatrix matrix) {
  var result = decodeMatrix(matrix);
  if (result != null) {
    return result;
  }
  // Decoding didn't work, try mirroring the QR across the topLeft -> bottomRight line.
  for (var x = 0; x < matrix.width; x++) {
    for (var y = x + 1; y < matrix.height; y++) {
      if (matrix.get(x, y) != matrix.get(y, x)) {
        matrix.set(x, y, !matrix.get(x, y));
        matrix.set(y, x, !matrix.get(y, x));
      }
    }
  }
  return decodeMatrix(matrix);
}