import 'package:equatable/equatable.dart';

/// QR code format information table
const formatInfoTable = {
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

/// A description of the format information of a Qr code
class FormatInfo extends Equatable {
  final int errorCorrectionLevel;
  final int dataMask;

  const FormatInfo({
    required this.errorCorrectionLevel,
    required this.dataMask,
  });

  @override
  List<Object> get props => [errorCorrectionLevel, dataMask];
}
