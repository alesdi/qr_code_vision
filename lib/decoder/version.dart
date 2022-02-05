class Version {
  final int? infoBits;
  final int versionNumber;
  final List<int> alignmentPatternCenters;
  final List<ErrorCorrectionLevel> errorCorrectionLevels;

  const Version({
    this.infoBits,
    required this.versionNumber,
    required this.alignmentPatternCenters,
    required this.errorCorrectionLevels,
  });
}

class ErrorCorrectionLevel {
  final int ecCodewordsPerBlock;
  final List<ErrorCorrectionBlock> ecBlocks;

  const ErrorCorrectionLevel({
    required this.ecCodewordsPerBlock,
    required this.ecBlocks,
  });
}

class ErrorCorrectionBlock {
  final int numBlocks;
  final int dataCodewordsPerBlock;

  const ErrorCorrectionBlock({
    required this.numBlocks,
    required this.dataCodewordsPerBlock,
  });
}

const versions = [
  Version(
    versionNumber: 1,
    alignmentPatternCenters: [],
    errorCorrectionLevels: [
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 7,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 1, dataCodewordsPerBlock: 19)
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 10,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 1, dataCodewordsPerBlock: 16),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 13,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 1, dataCodewordsPerBlock: 13),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 17,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 1, dataCodewordsPerBlock: 9),
        ],
      ),
    ],
  ),
  Version(
    versionNumber: 2,
    alignmentPatternCenters: [6, 18],
    errorCorrectionLevels: [
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 10,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 1, dataCodewordsPerBlock: 34),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 16,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 1, dataCodewordsPerBlock: 28),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 22,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 1, dataCodewordsPerBlock: 22),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 28,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 1, dataCodewordsPerBlock: 16),
        ],
      ),
    ],
  ),
  Version(
    versionNumber: 3,
    alignmentPatternCenters: [6, 22],
    errorCorrectionLevels: [
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 15,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 1, dataCodewordsPerBlock: 55),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 26,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 1, dataCodewordsPerBlock: 44),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 18,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 2, dataCodewordsPerBlock: 17),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 22,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 2, dataCodewordsPerBlock: 13),
        ],
      ),
    ],
  ),
  Version(
    versionNumber: 4,
    alignmentPatternCenters: [6, 26],
    errorCorrectionLevels: [
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 20,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 1, dataCodewordsPerBlock: 80),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 18,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 2, dataCodewordsPerBlock: 32),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 26,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 2, dataCodewordsPerBlock: 24),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 16,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 4, dataCodewordsPerBlock: 9),
        ],
      ),
    ],
  ),
  Version(
    versionNumber: 5,
    alignmentPatternCenters: [6, 30],
    errorCorrectionLevels: [
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 26,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 1, dataCodewordsPerBlock: 108),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 24,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 2, dataCodewordsPerBlock: 43),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 18,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 2, dataCodewordsPerBlock: 15),
          ErrorCorrectionBlock(numBlocks: 2, dataCodewordsPerBlock: 16),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 22,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 2, dataCodewordsPerBlock: 11),
          ErrorCorrectionBlock(numBlocks: 2, dataCodewordsPerBlock: 12),
        ],
      ),
    ],
  ),
  Version(
    versionNumber: 6,
    alignmentPatternCenters: [6, 34],
    errorCorrectionLevels: [
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 18,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 3, dataCodewordsPerBlock: 36),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 26,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 3, dataCodewordsPerBlock: 26),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 24,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 3, dataCodewordsPerBlock: 18),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 22,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 3, dataCodewordsPerBlock: 15),
        ],
      ),
    ],
  ),
  Version(
    infoBits: 0x07C94,
    versionNumber: 7,
    alignmentPatternCenters: [6, 22, 38],
    errorCorrectionLevels: [
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 20,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 2, dataCodewordsPerBlock: 31),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 18,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 2, dataCodewordsPerBlock: 14),
          ErrorCorrectionBlock(numBlocks: 4, dataCodewordsPerBlock: 15),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 26,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 4, dataCodewordsPerBlock: 13),
          ErrorCorrectionBlock(numBlocks: 1, dataCodewordsPerBlock: 14),
        ],
      ),
    ],
  ),
  Version(
    infoBits: 0x085BC,
    versionNumber: 8,
    alignmentPatternCenters: [6, 24, 42],
    errorCorrectionLevels: [
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 24,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 2, dataCodewordsPerBlock: 97),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 22,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 2, dataCodewordsPerBlock: 38),
          ErrorCorrectionBlock(numBlocks: 2, dataCodewordsPerBlock: 39),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 22,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 4, dataCodewordsPerBlock: 18),
          ErrorCorrectionBlock(numBlocks: 2, dataCodewordsPerBlock: 19),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 26,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 4, dataCodewordsPerBlock: 14),
          ErrorCorrectionBlock(numBlocks: 2, dataCodewordsPerBlock: 15),
        ],
      ),
    ],
  ),
  Version(
    infoBits: 0x09A99,
    versionNumber: 9,
    alignmentPatternCenters: [6, 26, 46],
    errorCorrectionLevels: [
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 2, dataCodewordsPerBlock: 116),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 22,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 3, dataCodewordsPerBlock: 36),
          ErrorCorrectionBlock(numBlocks: 2, dataCodewordsPerBlock: 37),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 20,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 4, dataCodewordsPerBlock: 16),
          ErrorCorrectionBlock(numBlocks: 4, dataCodewordsPerBlock: 17),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 24,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 4, dataCodewordsPerBlock: 12),
          ErrorCorrectionBlock(numBlocks: 4, dataCodewordsPerBlock: 13),
        ],
      ),
    ],
  ),
  Version(
    infoBits: 0x0A4D3,
    versionNumber: 10,
    alignmentPatternCenters: [6, 28, 50],
    errorCorrectionLevels: [
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 18,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 2, dataCodewordsPerBlock: 68),
          ErrorCorrectionBlock(numBlocks: 2, dataCodewordsPerBlock: 69),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 26,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 4, dataCodewordsPerBlock: 43),
          ErrorCorrectionBlock(numBlocks: 1, dataCodewordsPerBlock: 44),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 24,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 6, dataCodewordsPerBlock: 19),
          ErrorCorrectionBlock(numBlocks: 2, dataCodewordsPerBlock: 20),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 28,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 6, dataCodewordsPerBlock: 15),
          ErrorCorrectionBlock(numBlocks: 2, dataCodewordsPerBlock: 16),
        ],
      ),
    ],
  ),
  Version(
    infoBits: 0x0BBF6,
    versionNumber: 11,
    alignmentPatternCenters: [6, 30, 54],
    errorCorrectionLevels: [
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 20,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 4, dataCodewordsPerBlock: 81),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 1, dataCodewordsPerBlock: 50),
          ErrorCorrectionBlock(numBlocks: 4, dataCodewordsPerBlock: 51),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 28,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 4, dataCodewordsPerBlock: 22),
          ErrorCorrectionBlock(numBlocks: 4, dataCodewordsPerBlock: 23),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 24,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 3, dataCodewordsPerBlock: 12),
          ErrorCorrectionBlock(numBlocks: 8, dataCodewordsPerBlock: 13),
        ],
      ),
    ],
  ),
  Version(
    infoBits: 0x0C762,
    versionNumber: 12,
    alignmentPatternCenters: [6, 32, 58],
    errorCorrectionLevels: [
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 24,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 2, dataCodewordsPerBlock: 92),
          ErrorCorrectionBlock(numBlocks: 2, dataCodewordsPerBlock: 93),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 22,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 6, dataCodewordsPerBlock: 36),
          ErrorCorrectionBlock(numBlocks: 2, dataCodewordsPerBlock: 37),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 26,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 4, dataCodewordsPerBlock: 20),
          ErrorCorrectionBlock(numBlocks: 6, dataCodewordsPerBlock: 21),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 28,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 7, dataCodewordsPerBlock: 14),
          ErrorCorrectionBlock(numBlocks: 4, dataCodewordsPerBlock: 15),
        ],
      ),
    ],
  ),
  Version(
    infoBits: 0x0D847,
    versionNumber: 13,
    alignmentPatternCenters: [6, 34, 62],
    errorCorrectionLevels: [
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 26,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 4, dataCodewordsPerBlock: 107),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 22,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 8, dataCodewordsPerBlock: 37),
          ErrorCorrectionBlock(numBlocks: 1, dataCodewordsPerBlock: 38),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 24,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 8, dataCodewordsPerBlock: 20),
          ErrorCorrectionBlock(numBlocks: 4, dataCodewordsPerBlock: 21),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 22,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 12, dataCodewordsPerBlock: 11),
          ErrorCorrectionBlock(numBlocks: 4, dataCodewordsPerBlock: 12),
        ],
      ),
    ],
  ),
  Version(
    infoBits: 0x0E60D,
    versionNumber: 14,
    alignmentPatternCenters: [6, 26, 46, 66],
    errorCorrectionLevels: [
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 3, dataCodewordsPerBlock: 115),
          ErrorCorrectionBlock(numBlocks: 1, dataCodewordsPerBlock: 116),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 24,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 4, dataCodewordsPerBlock: 40),
          ErrorCorrectionBlock(numBlocks: 5, dataCodewordsPerBlock: 41),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 20,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 11, dataCodewordsPerBlock: 16),
          ErrorCorrectionBlock(numBlocks: 5, dataCodewordsPerBlock: 17),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 24,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 11, dataCodewordsPerBlock: 12),
          ErrorCorrectionBlock(numBlocks: 5, dataCodewordsPerBlock: 13),
        ],
      ),
    ],
  ),
  Version(
    infoBits: 0x0F928,
    versionNumber: 15,
    alignmentPatternCenters: [6, 26, 48, 70],
    errorCorrectionLevels: [
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 22,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 5, dataCodewordsPerBlock: 87),
          ErrorCorrectionBlock(numBlocks: 1, dataCodewordsPerBlock: 88),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 24,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 5, dataCodewordsPerBlock: 41),
          ErrorCorrectionBlock(numBlocks: 5, dataCodewordsPerBlock: 42),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 5, dataCodewordsPerBlock: 24),
          ErrorCorrectionBlock(numBlocks: 7, dataCodewordsPerBlock: 25),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 24,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 11, dataCodewordsPerBlock: 12),
          ErrorCorrectionBlock(numBlocks: 7, dataCodewordsPerBlock: 13),
        ],
      ),
    ],
  ),
  Version(
    infoBits: 0x10B78,
    versionNumber: 16,
    alignmentPatternCenters: [6, 26, 50, 74],
    errorCorrectionLevels: [
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 24,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 5, dataCodewordsPerBlock: 98),
          ErrorCorrectionBlock(numBlocks: 1, dataCodewordsPerBlock: 99),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 28,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 7, dataCodewordsPerBlock: 45),
          ErrorCorrectionBlock(numBlocks: 3, dataCodewordsPerBlock: 46),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 24,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 15, dataCodewordsPerBlock: 19),
          ErrorCorrectionBlock(numBlocks: 2, dataCodewordsPerBlock: 20),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 3, dataCodewordsPerBlock: 15),
          ErrorCorrectionBlock(numBlocks: 13, dataCodewordsPerBlock: 16),
        ],
      ),
    ],
  ),
  Version(
    infoBits: 0x1145D,
    versionNumber: 17,
    alignmentPatternCenters: [6, 30, 54, 78],
    errorCorrectionLevels: [
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 28,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 1, dataCodewordsPerBlock: 107),
          ErrorCorrectionBlock(numBlocks: 5, dataCodewordsPerBlock: 108),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 28,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 10, dataCodewordsPerBlock: 46),
          ErrorCorrectionBlock(numBlocks: 1, dataCodewordsPerBlock: 47),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 28,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 1, dataCodewordsPerBlock: 22),
          ErrorCorrectionBlock(numBlocks: 15, dataCodewordsPerBlock: 23),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 28,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 2, dataCodewordsPerBlock: 14),
          ErrorCorrectionBlock(numBlocks: 17, dataCodewordsPerBlock: 15),
        ],
      ),
    ],
  ),
  Version(
    infoBits: 0x12A17,
    versionNumber: 18,
    alignmentPatternCenters: [6, 30, 56, 82],
    errorCorrectionLevels: [
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 5, dataCodewordsPerBlock: 120),
          ErrorCorrectionBlock(numBlocks: 1, dataCodewordsPerBlock: 121),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 26,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 9, dataCodewordsPerBlock: 43),
          ErrorCorrectionBlock(numBlocks: 4, dataCodewordsPerBlock: 44),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 28,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 17, dataCodewordsPerBlock: 22),
          ErrorCorrectionBlock(numBlocks: 1, dataCodewordsPerBlock: 23),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 28,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 2, dataCodewordsPerBlock: 14),
          ErrorCorrectionBlock(numBlocks: 19, dataCodewordsPerBlock: 15),
        ],
      ),
    ],
  ),
  Version(
    infoBits: 0x13532,
    versionNumber: 19,
    alignmentPatternCenters: [6, 30, 58, 86],
    errorCorrectionLevels: [
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 28,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 3, dataCodewordsPerBlock: 113),
          ErrorCorrectionBlock(numBlocks: 4, dataCodewordsPerBlock: 114),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 26,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 3, dataCodewordsPerBlock: 44),
          ErrorCorrectionBlock(numBlocks: 11, dataCodewordsPerBlock: 45),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 26,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 17, dataCodewordsPerBlock: 21),
          ErrorCorrectionBlock(numBlocks: 4, dataCodewordsPerBlock: 22),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 26,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 9, dataCodewordsPerBlock: 13),
          ErrorCorrectionBlock(numBlocks: 16, dataCodewordsPerBlock: 14),
        ],
      ),
    ],
  ),
  Version(
    infoBits: 0x149A6,
    versionNumber: 20,
    alignmentPatternCenters: [6, 34, 62, 90],
    errorCorrectionLevels: [
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 28,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 3, dataCodewordsPerBlock: 107),
          ErrorCorrectionBlock(numBlocks: 5, dataCodewordsPerBlock: 108),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 26,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 3, dataCodewordsPerBlock: 41),
          ErrorCorrectionBlock(numBlocks: 13, dataCodewordsPerBlock: 42),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 15, dataCodewordsPerBlock: 24),
          ErrorCorrectionBlock(numBlocks: 5, dataCodewordsPerBlock: 25),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 28,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 15, dataCodewordsPerBlock: 15),
          ErrorCorrectionBlock(numBlocks: 10, dataCodewordsPerBlock: 16),
        ],
      ),
    ],
  ),
  Version(
    infoBits: 0x15683,
    versionNumber: 21,
    alignmentPatternCenters: [6, 28, 50, 72, 94],
    errorCorrectionLevels: [
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 28,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 4, dataCodewordsPerBlock: 116),
          ErrorCorrectionBlock(numBlocks: 4, dataCodewordsPerBlock: 117),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 26,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 17, dataCodewordsPerBlock: 42),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 28,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 17, dataCodewordsPerBlock: 22),
          ErrorCorrectionBlock(numBlocks: 6, dataCodewordsPerBlock: 23),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 19, dataCodewordsPerBlock: 16),
          ErrorCorrectionBlock(numBlocks: 6, dataCodewordsPerBlock: 17),
        ],
      ),
    ],
  ),
  Version(
    infoBits: 0x168C9,
    versionNumber: 22,
    alignmentPatternCenters: [6, 26, 50, 74, 98],
    errorCorrectionLevels: [
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 28,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 2, dataCodewordsPerBlock: 111),
          ErrorCorrectionBlock(numBlocks: 7, dataCodewordsPerBlock: 112),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 28,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 17, dataCodewordsPerBlock: 46),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 7, dataCodewordsPerBlock: 24),
          ErrorCorrectionBlock(numBlocks: 16, dataCodewordsPerBlock: 25),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 24,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 34, dataCodewordsPerBlock: 13),
        ],
      ),
    ],
  ),
  Version(
    infoBits: 0x177EC,
    versionNumber: 23,
    alignmentPatternCenters: [6, 30, 54, 74, 102],
    errorCorrectionLevels: [
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 4, dataCodewordsPerBlock: 121),
          ErrorCorrectionBlock(numBlocks: 5, dataCodewordsPerBlock: 122),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 28,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 4, dataCodewordsPerBlock: 47),
          ErrorCorrectionBlock(numBlocks: 14, dataCodewordsPerBlock: 48),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 11, dataCodewordsPerBlock: 24),
          ErrorCorrectionBlock(numBlocks: 14, dataCodewordsPerBlock: 25),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 16, dataCodewordsPerBlock: 15),
          ErrorCorrectionBlock(numBlocks: 14, dataCodewordsPerBlock: 16),
        ],
      ),
    ],
  ),
  Version(
    infoBits: 0x18EC4,
    versionNumber: 24,
    alignmentPatternCenters: [6, 28, 54, 80, 106],
    errorCorrectionLevels: [
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 6, dataCodewordsPerBlock: 117),
          ErrorCorrectionBlock(numBlocks: 4, dataCodewordsPerBlock: 118),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 28,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 6, dataCodewordsPerBlock: 45),
          ErrorCorrectionBlock(numBlocks: 14, dataCodewordsPerBlock: 46),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 11, dataCodewordsPerBlock: 24),
          ErrorCorrectionBlock(numBlocks: 16, dataCodewordsPerBlock: 25),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 30, dataCodewordsPerBlock: 16),
          ErrorCorrectionBlock(numBlocks: 2, dataCodewordsPerBlock: 17),
        ],
      ),
    ],
  ),
  Version(
    infoBits: 0x191E1,
    versionNumber: 25,
    alignmentPatternCenters: [6, 32, 58, 84, 110],
    errorCorrectionLevels: [
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 26,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 8, dataCodewordsPerBlock: 106),
          ErrorCorrectionBlock(numBlocks: 4, dataCodewordsPerBlock: 107),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 28,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 8, dataCodewordsPerBlock: 47),
          ErrorCorrectionBlock(numBlocks: 13, dataCodewordsPerBlock: 48),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 7, dataCodewordsPerBlock: 24),
          ErrorCorrectionBlock(numBlocks: 22, dataCodewordsPerBlock: 25),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 22, dataCodewordsPerBlock: 15),
          ErrorCorrectionBlock(numBlocks: 13, dataCodewordsPerBlock: 16),
        ],
      ),
    ],
  ),
  Version(
    infoBits: 0x1AFAB,
    versionNumber: 26,
    alignmentPatternCenters: [6, 30, 58, 86, 114],
    errorCorrectionLevels: [
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 28,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 10, dataCodewordsPerBlock: 114),
          ErrorCorrectionBlock(numBlocks: 2, dataCodewordsPerBlock: 115),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 28,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 19, dataCodewordsPerBlock: 46),
          ErrorCorrectionBlock(numBlocks: 4, dataCodewordsPerBlock: 47),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 28,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 28, dataCodewordsPerBlock: 22),
          ErrorCorrectionBlock(numBlocks: 6, dataCodewordsPerBlock: 23),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 33, dataCodewordsPerBlock: 16),
          ErrorCorrectionBlock(numBlocks: 4, dataCodewordsPerBlock: 17),
        ],
      ),
    ],
  ),
  Version(
    infoBits: 0x1B08E,
    versionNumber: 27,
    alignmentPatternCenters: [6, 34, 62, 90, 118],
    errorCorrectionLevels: [
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 8, dataCodewordsPerBlock: 122),
          ErrorCorrectionBlock(numBlocks: 4, dataCodewordsPerBlock: 123),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 28,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 22, dataCodewordsPerBlock: 45),
          ErrorCorrectionBlock(numBlocks: 3, dataCodewordsPerBlock: 46),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 8, dataCodewordsPerBlock: 23),
          ErrorCorrectionBlock(numBlocks: 26, dataCodewordsPerBlock: 24),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 12, dataCodewordsPerBlock: 15),
          ErrorCorrectionBlock(numBlocks: 28, dataCodewordsPerBlock: 16),
        ],
      ),
    ],
  ),
  Version(
    infoBits: 0x1CC1A,
    versionNumber: 28,
    alignmentPatternCenters: [6, 26, 50, 74, 98, 122],
    errorCorrectionLevels: [
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 3, dataCodewordsPerBlock: 117),
          ErrorCorrectionBlock(numBlocks: 10, dataCodewordsPerBlock: 118),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 28,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 3, dataCodewordsPerBlock: 45),
          ErrorCorrectionBlock(numBlocks: 23, dataCodewordsPerBlock: 46),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 4, dataCodewordsPerBlock: 24),
          ErrorCorrectionBlock(numBlocks: 31, dataCodewordsPerBlock: 25),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 11, dataCodewordsPerBlock: 15),
          ErrorCorrectionBlock(numBlocks: 31, dataCodewordsPerBlock: 16),
        ],
      ),
    ],
  ),
  Version(
    infoBits: 0x1D33F,
    versionNumber: 29,
    alignmentPatternCenters: [6, 30, 54, 78, 102, 126],
    errorCorrectionLevels: [
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 7, dataCodewordsPerBlock: 116),
          ErrorCorrectionBlock(numBlocks: 7, dataCodewordsPerBlock: 117),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 28,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 21, dataCodewordsPerBlock: 45),
          ErrorCorrectionBlock(numBlocks: 7, dataCodewordsPerBlock: 46),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 1, dataCodewordsPerBlock: 23),
          ErrorCorrectionBlock(numBlocks: 37, dataCodewordsPerBlock: 24),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 19, dataCodewordsPerBlock: 15),
          ErrorCorrectionBlock(numBlocks: 26, dataCodewordsPerBlock: 16),
        ],
      ),
    ],
  ),
  Version(
    infoBits: 0x1ED75,
    versionNumber: 30,
    alignmentPatternCenters: [6, 26, 52, 78, 104, 130],
    errorCorrectionLevels: [
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 5, dataCodewordsPerBlock: 115),
          ErrorCorrectionBlock(numBlocks: 10, dataCodewordsPerBlock: 116),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 28,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 19, dataCodewordsPerBlock: 47),
          ErrorCorrectionBlock(numBlocks: 10, dataCodewordsPerBlock: 48),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 15, dataCodewordsPerBlock: 24),
          ErrorCorrectionBlock(numBlocks: 25, dataCodewordsPerBlock: 25),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 23, dataCodewordsPerBlock: 15),
          ErrorCorrectionBlock(numBlocks: 25, dataCodewordsPerBlock: 16),
        ],
      ),
    ],
  ),
  Version(
    infoBits: 0x1F250,
    versionNumber: 31,
    alignmentPatternCenters: [6, 30, 56, 82, 108, 134],
    errorCorrectionLevels: [
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 13, dataCodewordsPerBlock: 115),
          ErrorCorrectionBlock(numBlocks: 3, dataCodewordsPerBlock: 116),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 28,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 2, dataCodewordsPerBlock: 46),
          ErrorCorrectionBlock(numBlocks: 29, dataCodewordsPerBlock: 47),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 42, dataCodewordsPerBlock: 24),
          ErrorCorrectionBlock(numBlocks: 1, dataCodewordsPerBlock: 25),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 23, dataCodewordsPerBlock: 15),
          ErrorCorrectionBlock(numBlocks: 28, dataCodewordsPerBlock: 16),
        ],
      ),
    ],
  ),
  Version(
    infoBits: 0x209D7,
    versionNumber: 32,
    alignmentPatternCenters: [6, 34, 60, 86, 112, 138],
    errorCorrectionLevels: [
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 17, dataCodewordsPerBlock: 115),
          ErrorCorrectionBlock(numBlocks: 2, dataCodewordsPerBlock: 116),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 28,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 10, dataCodewordsPerBlock: 46),
          ErrorCorrectionBlock(numBlocks: 23, dataCodewordsPerBlock: 47),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 35, dataCodewordsPerBlock: 24),
          ErrorCorrectionBlock(numBlocks: 15, dataCodewordsPerBlock: 25),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 19, dataCodewordsPerBlock: 15),
          ErrorCorrectionBlock(numBlocks: 35, dataCodewordsPerBlock: 16),
        ],
      ),
    ],
  ),
  Version(
    infoBits: 0x216F0,
    versionNumber: 33,
    alignmentPatternCenters: [6, 30, 58, 86, 114, 142],
    errorCorrectionLevels: [
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 17, dataCodewordsPerBlock: 115),
          ErrorCorrectionBlock(numBlocks: 1, dataCodewordsPerBlock: 116),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 28,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 14, dataCodewordsPerBlock: 46),
          ErrorCorrectionBlock(numBlocks: 21, dataCodewordsPerBlock: 47),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 29, dataCodewordsPerBlock: 24),
          ErrorCorrectionBlock(numBlocks: 19, dataCodewordsPerBlock: 25),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 11, dataCodewordsPerBlock: 15),
          ErrorCorrectionBlock(numBlocks: 46, dataCodewordsPerBlock: 16),
        ],
      ),
    ],
  ),
  Version(
    infoBits: 0x228BA,
    versionNumber: 34,
    alignmentPatternCenters: [6, 34, 62, 90, 118, 146],
    errorCorrectionLevels: [
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 13, dataCodewordsPerBlock: 115),
          ErrorCorrectionBlock(numBlocks: 6, dataCodewordsPerBlock: 116),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 28,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 14, dataCodewordsPerBlock: 46),
          ErrorCorrectionBlock(numBlocks: 23, dataCodewordsPerBlock: 47),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 44, dataCodewordsPerBlock: 24),
          ErrorCorrectionBlock(numBlocks: 7, dataCodewordsPerBlock: 25),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 59, dataCodewordsPerBlock: 16),
          ErrorCorrectionBlock(numBlocks: 1, dataCodewordsPerBlock: 17),
        ],
      ),
    ],
  ),
  Version(
    infoBits: 0x2379F,
    versionNumber: 35,
    alignmentPatternCenters: [6, 30, 54, 78, 102, 126, 150],
    errorCorrectionLevels: [
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 12, dataCodewordsPerBlock: 121),
          ErrorCorrectionBlock(numBlocks: 7, dataCodewordsPerBlock: 122),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 28,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 12, dataCodewordsPerBlock: 47),
          ErrorCorrectionBlock(numBlocks: 26, dataCodewordsPerBlock: 48),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 39, dataCodewordsPerBlock: 24),
          ErrorCorrectionBlock(numBlocks: 14, dataCodewordsPerBlock: 25),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 22, dataCodewordsPerBlock: 15),
          ErrorCorrectionBlock(numBlocks: 41, dataCodewordsPerBlock: 16),
        ],
      ),
    ],
  ),
  Version(
    infoBits: 0x24B0B,
    versionNumber: 36,
    alignmentPatternCenters: [6, 24, 50, 76, 102, 128, 154],
    errorCorrectionLevels: [
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 6, dataCodewordsPerBlock: 121),
          ErrorCorrectionBlock(numBlocks: 14, dataCodewordsPerBlock: 122),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 28,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 6, dataCodewordsPerBlock: 47),
          ErrorCorrectionBlock(numBlocks: 34, dataCodewordsPerBlock: 48),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 46, dataCodewordsPerBlock: 24),
          ErrorCorrectionBlock(numBlocks: 10, dataCodewordsPerBlock: 25),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 2, dataCodewordsPerBlock: 15),
          ErrorCorrectionBlock(numBlocks: 64, dataCodewordsPerBlock: 16),
        ],
      ),
    ],
  ),
  Version(
    infoBits: 0x2542E,
    versionNumber: 37,
    alignmentPatternCenters: [6, 28, 54, 80, 106, 132, 158],
    errorCorrectionLevels: [
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 17, dataCodewordsPerBlock: 122),
          ErrorCorrectionBlock(numBlocks: 4, dataCodewordsPerBlock: 123),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 28,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 29, dataCodewordsPerBlock: 46),
          ErrorCorrectionBlock(numBlocks: 14, dataCodewordsPerBlock: 47),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 49, dataCodewordsPerBlock: 24),
          ErrorCorrectionBlock(numBlocks: 10, dataCodewordsPerBlock: 25),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 24, dataCodewordsPerBlock: 15),
          ErrorCorrectionBlock(numBlocks: 46, dataCodewordsPerBlock: 16),
        ],
      ),
    ],
  ),
  Version(
    infoBits: 0x26A64,
    versionNumber: 38,
    alignmentPatternCenters: [6, 32, 58, 84, 110, 136, 162],
    errorCorrectionLevels: [
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 4, dataCodewordsPerBlock: 122),
          ErrorCorrectionBlock(numBlocks: 18, dataCodewordsPerBlock: 123),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 28,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 13, dataCodewordsPerBlock: 46),
          ErrorCorrectionBlock(numBlocks: 32, dataCodewordsPerBlock: 47),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 48, dataCodewordsPerBlock: 24),
          ErrorCorrectionBlock(numBlocks: 14, dataCodewordsPerBlock: 25),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 42, dataCodewordsPerBlock: 15),
          ErrorCorrectionBlock(numBlocks: 32, dataCodewordsPerBlock: 16),
        ],
      ),
    ],
  ),
  Version(
    infoBits: 0x27541,
    versionNumber: 39,
    alignmentPatternCenters: [6, 26, 54, 82, 110, 138, 166],
    errorCorrectionLevels: [
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 20, dataCodewordsPerBlock: 117),
          ErrorCorrectionBlock(numBlocks: 4, dataCodewordsPerBlock: 118),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 28,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 40, dataCodewordsPerBlock: 47),
          ErrorCorrectionBlock(numBlocks: 7, dataCodewordsPerBlock: 48),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 43, dataCodewordsPerBlock: 24),
          ErrorCorrectionBlock(numBlocks: 22, dataCodewordsPerBlock: 25),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 10, dataCodewordsPerBlock: 15),
          ErrorCorrectionBlock(numBlocks: 67, dataCodewordsPerBlock: 16),
        ],
      ),
    ],
  ),
  Version(
    infoBits: 0x28C69,
    versionNumber: 40,
    alignmentPatternCenters: [6, 30, 58, 86, 114, 142, 170],
    errorCorrectionLevels: [
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 19, dataCodewordsPerBlock: 118),
          ErrorCorrectionBlock(numBlocks: 6, dataCodewordsPerBlock: 119),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 28,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 18, dataCodewordsPerBlock: 47),
          ErrorCorrectionBlock(numBlocks: 31, dataCodewordsPerBlock: 48),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 34, dataCodewordsPerBlock: 24),
          ErrorCorrectionBlock(numBlocks: 34, dataCodewordsPerBlock: 25),
        ],
      ),
      ErrorCorrectionLevel(
        ecCodewordsPerBlock: 30,
        ecBlocks: [
          ErrorCorrectionBlock(numBlocks: 20, dataCodewordsPerBlock: 15),
          ErrorCorrectionBlock(numBlocks: 61, dataCodewordsPerBlock: 16),
        ],
      ),
    ],
  )
];
