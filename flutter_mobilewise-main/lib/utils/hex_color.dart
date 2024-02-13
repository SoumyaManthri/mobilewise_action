import 'package:flutter/material.dart';

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    try {
      hexColor = hexColor.toUpperCase().replaceAll("#", "");
      // if (hexColor.length == 6) {
      //   hexColor = "FF$hexColor";
      // }
      hexColor = hexColor.padLeft(8, 'F');
      return int.parse(hexColor, radix: 16);
    } catch (e) {
      return int.parse("FFFFFFFF", radix: 16);
    }
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
