import 'dart:math';
import 'dart:ui';

enum FilterType { dark, light, undoDark, undoLight }
class ThemeFilter {
  static ColorFilter get dark => ColorFilter.matrix(filterMatrix(filterType: FilterType.dark));
  static ColorFilter get light => ColorFilter.matrix(filterMatrix(filterType: FilterType.light));
  static ColorFilter get undoDark => ColorFilter.matrix(filterMatrix(filterType: FilterType.undoDark));
  static ColorFilter get undoLight => ColorFilter.matrix(filterMatrix(filterType: FilterType.undoLight));

  static List<double> filterMatrix({required FilterType filterType}) {
    double darkDegrees = -35;
    double degrees = 0;
    switch (filterType) {
      case FilterType.dark:
        degrees = darkDegrees;
        break;
      case FilterType.light:
        degrees = 180 + darkDegrees;
        break;
      case FilterType.undoDark:
        degrees = - darkDegrees;
        break;
      case FilterType.undoLight:
        degrees = -(180 + darkDegrees);
        break;
    }
    final double angle = degrees * pi / 180;
    final double cosVal = cos(angle);
    final double sinVal = sin(angle);

    const lumR = 0.213;
    const lumG = 0.715;
    const lumB = 0.072;

    final List<double> hueRotateMatrix = [
      lumR + cosVal * (1 - lumR) + sinVal * (-lumR),
      lumG + cosVal * (-lumG) + sinVal * (-lumG),
      lumB + cosVal * (-lumB) + sinVal * (1 - lumB),
      0,
      0,

      lumR + cosVal * (-lumR) + sinVal * 0.143,
      lumG + cosVal * (1 - lumG) + sinVal * 0.14,
      lumB + cosVal * (-lumB) + sinVal * -0.283,
      0,
      0,

      lumR + cosVal * (-lumR) + sinVal * (-(1 - lumR)),
      lumG + cosVal * (-lumG) + sinVal * lumG,
      lumB + cosVal * (1 - lumB) + sinVal * lumB,
      0,
      0,

      0, 0, 0, 1, 0,
    ];

    final List<double> invertMatrix = [
      -1,  0,  0,  0, 255,
      0, -1,  0,  0, 255,
      0,  0, -1,  0, 255,
      0,  0,  0,  1,   0,
    ];

    // Combine matrices (invert first, then hue rotation)
    List<double> finalMatrix = List.filled(20, 0);
    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 5; col++) {
        double sum = 0;
        for (int i = 0; i < 4; i++) {
          sum += hueRotateMatrix[row * 5 + i] * invertMatrix[i * 5 + col];
        }
        if (col == 4) {
          sum += hueRotateMatrix[row * 5 + 4];
        }
        finalMatrix[row * 5 + col] = sum;
      }
    }

    // Add beige overlay to both matrices
    const double offsetR = 0.13 * 255;
    const double offsetG = 0.12 * 255;
    const double offsetB = 0.13 * 255;
    finalMatrix[4]  += offsetR;  // R offset
    finalMatrix[9]  += offsetG;  // G offset
    finalMatrix[14] += offsetB;  // B offset

    const double hueOffsetR = 0.01 * 255;  // R offset
    const double hueOffsetG = -0.01 * 255;  // G offset
    const double hueOffsetB = -0.02 * 255;  // B offset
    hueRotateMatrix[4]  += hueOffsetR;  // R offset
    hueRotateMatrix[9]  += hueOffsetG;  // G offset
    hueRotateMatrix[14] += hueOffsetB;  // B offset

    switch (filterType) {
      case FilterType.dark:
        return finalMatrix;
      case FilterType.light:
        return hueRotateMatrix;
      case FilterType.undoDark:
        finalMatrix[4]  -= offsetR;  // R offset
        finalMatrix[9]  -= offsetG;  // G offset
        finalMatrix[14] -= offsetB;  // B offset
        return finalMatrix;
      case FilterType.undoLight:
        hueRotateMatrix[4]  -= hueOffsetR;  // R offset
        hueRotateMatrix[9]  -= hueOffsetG;  // G offset
        hueRotateMatrix[14] -= hueOffsetB;  // B offset
        return hueRotateMatrix;
    }
  }
}