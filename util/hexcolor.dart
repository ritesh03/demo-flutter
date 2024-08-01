import 'dart:ui';

class HexColorUtil {
  static final _colorCodeCharacters = [
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
    "a",
    "b",
    "c",
    "d",
    "e",
    "f",
  ];

  static Color? hexToColor(String hexStr) {
    if (!hexStr.startsWith("#")) return null;

    String colorCodeStr = hexStr.substring(1);
    if (colorCodeStr.length == 6) {
      colorCodeStr = "ff$colorCodeStr";
    }

    if (colorCodeStr.length != 8) return null;

    for (final character in colorCodeStr.split('')) {
      if (!_colorCodeCharacters.contains(character)) return null;
    }

    colorCodeStr = "0x$colorCodeStr";
    return Color(int.parse(colorCodeStr));
  }
}
