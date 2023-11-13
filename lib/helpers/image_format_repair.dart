import 'dart:typed_data';

import 'package:image/image.dart';

/// Whether bytes is a BMP image of a perfect QR code with hidden transparency
///
/// When a PNG with transparency is copied to the Windows clipboard, it is
/// converted to a Device Independent Bitmap with a BITMAPINFOHEADER and 32 bits per pixel.
/// According to the spec a bitmap (BMP) with that header does not support
/// transparency. However, since each pixel has 32 bits but only 8 bits per color
/// there are 8 free bits in which windows writes the alpha value.
/// BmpDecoder ignores that value therefore the decoded image has only black pixels.
/// See: https://stackoverflow.com/questions/44287407/text-erased-from-screenshot-after-using-clipboard-getimage-on-windows-10/46400011#46400011
bool couldBeQRCodeBMPWithHiddenTransparency(Uint8List bytes) {
  final bmpDecoder = BmpDecoder();
  if (!bmpDecoder.isValidFile(bytes)) {
    return false;
  }
  Image? img = bmpDecoder.decode(bytes);
  if (img == null) {
    return false;
  }
  return img.every((pixel) => pixel.r == 0 && pixel.g == 0 && pixel.b == 0);
}

/// Rewrites the BMP so that BmpDecoder does not ignore the alpha value
Image? fixQRCodeBMPWithHiddenTransparency(Uint8List bytes) {
  // BmpDecoder treats the 4th byte of each pixel as alpha value
  // if the BMP header has more than 40 bytes (see BmpInfo::ignoreAlphaChannel).
  // Therefore we turn the 40 byte BITMAPINFOHEADER into a 52 byte BITMAPV2INFOHEADER.
  // See: https://en.wikipedia.org/wiki/BMP_file_format

  final buffer = InputBuffer(bytes);
  buffer.skip(0x0A);
  final oldDataOffset = buffer.readUint32();
  final oldHeaderSize = buffer.readUint32();
  if (oldHeaderSize != 40) {
    return null;
  }

  final growableBytes = bytes.toList();
  // Set header size to 54 bytes
  growableBytes[0x0E] = 54;
  // Insert 14 zero bytes before the BMP data starts
  growableBytes.insertAll(oldDataOffset, List.filled(14, 0));
  // Adjust the BMP data offset
  final newOffsetBytes = OutputBuffer(bigEndian: false, size: 4)..writeUint32(oldDataOffset + 14);
  growableBytes.replaceRange(0x0A, 0x0E, newOffsetBytes.getBytes().toList());
  return BmpDecoder().decode(Uint8List.fromList(growableBytes));
}
