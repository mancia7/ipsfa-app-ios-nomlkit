//import 'dart:math';

import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  int _themeSelector = 0;
  final List<Color> _iconColor = [
    Colors.blue,
    Colors.black,
    Colors.green,
    Colors.red,
    Colors.black,
    Colors.black,
    Colors.orange,
  ];

  int get themeSelector => _themeSelector;

  Color get iconColor => _iconColor[_themeSelector];

  void selectTheme() {
    //int max = 8, min = 0;

    //_themeSelector = min + Random().nextInt(max - min);
    //print(_themeSelector);
    _themeSelector = _themeSelector==6?0:++_themeSelector;
    putIconColor(_themeSelector);
    notifyListeners();
  }

  void putIconColor(index) {
    _iconColor[index];
    notifyListeners();
  }
}
