import 'dart:typed_data';

import 'package:dart_reed_solomon_nullsafety/dart_reed_solomon_nullsafety.dart';

import '../entities/position.dart';
import '../helpers/bit_matrix.dart';
import 'decode_data.dart';
import 'format_info_table.dart';
import 'version.dart';

/// Decodes a Qr code given the matrix of its raw bits.
QrContent? decode(BitMatrix matrix) {
  var result = _readContent(matrix);
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
  return _readContent(matrix);
}

int _numBitsDiffering(int x, int y) {
  var z = x ^ y;
  var bitCount = 0;
  while (z != 0x0) {
    bitCount++;
    z &= z - 1;
  }
  return bitCount;
}

int _pushBit(bool bit, int byte) {
  return (byte << 1) | (bit ? 1 : 0);
}

final _dataMasks = [
  (Position<int> p) => ((p.y + p.x) % 2) == 0,
  (Position<int> p) => (p.y % 2) == 0,
  (Position<int> p) => p.x % 3 == 0,
  (Position<int> p) => (p.y + p.x) % 3 == 0,
  (Position<int> p) => ((p.y / 2).floor() + (p.x / 3).floor()) % 2 == 0,
  (Position<int> p) => ((p.x * p.y) % 2) + ((p.x * p.y) % 3) == 0,
  (Position<int> p) => ((((p.y * p.x) % 2) + (p.y * p.x) % 3) % 2) == 0,
  (Position<int> p) => ((((p.y + p.x) % 2) + (p.y * p.x) % 3) % 2) == 0,
];

BitMatrix _buildFunctionPatternMask(Version version) {
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

List<int> _readCodewords(
    BitMatrix matrix, Version version, FormatInfo formatInfo) {
  final dataMask = _dataMasks[formatInfo.dataMask];
  final dimension = matrix.height;
  final functionPatternMask = _buildFunctionPatternMask(version);
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
          if (dataMask(Position<int>(x, y))) {
            bit = !bit;
          }
          currentByte = _pushBit(bit, currentByte);
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

Version? _readVersion(BitMatrix matrix) {
  int dimension = matrix.height;
  int provisionalVersion = ((dimension - 17) / 4).floor();
  if (provisionalVersion > 0 && provisionalVersion <= 6) {
    // 6 and under don't have version info in the QR code
    return versions[provisionalVersion - 1];
  }
  var topRightVersionBits = 0;
  for (var y = 5; y >= 0; y--) {
    for (var x = dimension - 9; x >= dimension - 11; x--) {
      topRightVersionBits = _pushBit(matrix.get(x, y), topRightVersionBits);
    }
  }
  var bottomLeftVersionBits = 0;
  for (var x = 5; x >= 0; x--) {
    for (var y = dimension - 9; y >= dimension - 11; y--) {
      bottomLeftVersionBits = _pushBit(matrix.get(x, y), bottomLeftVersionBits);
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
        _numBitsDiffering(topRightVersionBits, version.infoBits ?? 0);
    if (difference < bestDifference) {
      bestVersion = version;
      bestDifference = difference.toDouble();
    }
    difference =
        _numBitsDiffering(bottomLeftVersionBits, version.infoBits ?? 0);
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
  return null;
}

FormatInfo? _readFormatInformation(BitMatrix matrix) {
  int topLeftFormatInfoBits = 0;
  for (int x = 0; x <= 8; x++) {
    if (x != 6) {
      // Skip timing pattern bit
      topLeftFormatInfoBits = _pushBit(matrix.get(x, 8), topLeftFormatInfoBits);
    }
  }
  for (int y = 7; y >= 0; y--) {
    if (y != 6) {
      // Skip timing pattern bit
      topLeftFormatInfoBits = _pushBit(matrix.get(8, y), topLeftFormatInfoBits);
    }
  }
  int dimension = matrix.height;
  int topRightBottomRightFormatInfoBits = 0;
  for (int y = dimension - 1; y >= dimension - 7; y--) {
    // bottom left
    topRightBottomRightFormatInfoBits =
        _pushBit(matrix.get(8, y), topRightBottomRightFormatInfoBits);
  }
  for (int x = dimension - 8; x < dimension; x++) {
    // top right
    topRightBottomRightFormatInfoBits =
        _pushBit(matrix.get(x, 8), topRightBottomRightFormatInfoBits);
  }
  double bestDifference = double.infinity;
  FormatInfo? bestFormatInfo;
  for (var _a in formatInfoTable.entries) {
    var bits = _a.key, formatInfo = _a.value;
    if (bits == topLeftFormatInfoBits ||
        bits == topRightBottomRightFormatInfoBits) {
      return formatInfo;
    }
    var difference = _numBitsDiffering(topLeftFormatInfoBits, bits);
    if (difference < bestDifference) {
      bestFormatInfo = formatInfo;
      bestDifference = difference.toDouble();
    }
    if (topLeftFormatInfoBits != topRightBottomRightFormatInfoBits) {
      // also try the other option
      difference = _numBitsDiffering(topRightBottomRightFormatInfoBits, bits);
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

class _DataBlock {
  final int numDataCodewords;
  final List<int> codewords;

  const _DataBlock({required this.numDataCodewords, required this.codewords});
}

List<_DataBlock>? _getDataBlocks(
    List<int> codewords, Version version, int ecLevel) {
  ErrorCorrectionLevel ecInfo = version.errorCorrectionLevels[ecLevel];
  List<_DataBlock> dataBlocks = [];
  var totalCodewords = 0;
  for (var block in ecInfo.ecBlocks) {
    for (var i = 0; i < block.numBlocks; i++) {
      dataBlocks.add(_DataBlock(
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

QrContent? _readContent(matrix) {
  var version = _readVersion(matrix);
  if (version == null) {
    return null;
  }
  var formatInfo = _readFormatInformation(matrix);
  if (formatInfo == null) {
    return null;
  }
  var codewords = _readCodewords(matrix, version, formatInfo);
  var dataBlocks =
      _getDataBlocks(codewords, version, formatInfo.errorCorrectionLevel);
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
      return null;
    }
  }
  try {
    return readData(resultBytes, version.versionNumber);
  } catch (_a) {
    return null;
  }
}
