import 'package:flutter/material.dart';

//const Color _customColor = Color(0xFF441011);

const List<Color> _colorTheme = [
    Colors.blue,
    Colors.teal,
    Colors.green,
    Colors.red,
    Colors.brown,
    Colors.purple,
    Colors.orange,
];

class AppTheme {
  final int selectedColor;

  AppTheme(
      {required this.selectedColor}); //: assert(selectedColor >= 0 && selectedColor<=_colorTheme.length,'Colors must be beetween 0 and 9');
  ThemeData theme() {
    return ThemeData(
      colorSchemeSeed: _colorTheme[selectedColor],
    );
  }
}
