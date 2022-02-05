import 'dart:typed_data';

class BitStream {
  Uint8ClampedList bytes;
  int byteOffset = 0;
  int bitOffset = 0;

  BitStream(this.bytes);

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
