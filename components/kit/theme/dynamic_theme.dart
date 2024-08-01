import 'package:flutter/material.dart'  hide SearchBar;

import 'dark/dark_theme.dart';
import 'theme.dart';

class DynamicTheme {
  static const defaultTextColor = Colors.white;
  static const displayBlack = Colors.black;
  static const notificationRed = Colors.red;

  static final AppTheme _darkTheme = DarkTheme();

  static AppTheme get(BuildContext context) {
    return _darkTheme;

    // TODO: add a description about when to use WidgetsBinding or SchedulersBinding
    // https://stackoverflow.com/a/56307575/3682535
    // final isLightBrightness =
    //     (SchedulerBinding.instance!.window.platformBrightness ==
    //         Brightness.light);
    //
    // return isLightBrightness ? _lightTheme : _darkTheme;
  }
}
