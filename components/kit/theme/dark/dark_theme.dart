import 'dart:math';

import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/theme/theme.dart';

class DarkTheme implements AppTheme {
  /*
   *
   * BASE
   */

  @override
  Color background() => const Color(0xFF0F3443);

  @override
  Color surface() => secondary20();

  @override
  Color onSurface() => secondary120();

  @override
  Color black() => const Color(0xFF0B2732);

  @override
  Color white() => const Color(0xFFFFFFFF);

  /*
   * ERROR
   */

  @override
  Color error10() => const Color(0xFFF1E5E5);

  @override
  Color error100() => const Color(0xFFE36B6B);

  @override
  Color error120() => const Color(0xFFB65656);

  /*
   * NEUTRAL
   */

  @override
  Color neutral10() => const Color(0xFFCFD6D9);

  @override
  Color neutral20() => const Color(0xFF9FAEB4);

  @override
  Color neutral40() => const Color(0xFF6F858E);

  @override
  Color neutral60() => const Color(0xFF3F5D69);

  @override
  Color neutral80() => const Color(0xFF274855);

  @override
  Color neural100() => const Color(0xFFCFD6D9);



  /*
   * PRIMARY
   */

  @override
  Color primary10() => const Color(0xFF13464C);

  @override
  Color primary20() => const Color(0xFF165856);

  @override
  Color primary40() => const Color(0xFF1E7C67);

  @override
  Color primary60() => const Color(0xFF25A07A);

  @override
  Color primary120() => const Color(0xFF5DEDB1);

  @override
  Gradient primaryGradient() => const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      transform: GradientRotation(3 * pi / 8),
      colors: [Color(0xFF34E89E), Color(0xFF2E85A7)]);

  @override
  String primaryDecorationAssetPath() {
    return "assets/graphics/primary_decoration.png";
  }

  /*
   * SECONDARY
   */

  @override
  Color secondary10() => const Color(0xFF0E4455);

  @override
  Color secondary20() => const Color(0xFF0C5469);

  @override
  Color secondary40() => const Color(0xFF09738E);

  @override
  Color secondary60() => const Color(0xFF0692B4);

  @override
  Color secondary100() => const Color(0xFF00D1FF);

  @override
  Color secondary120() => const Color(0xFF33DAFF);

  @override
  Color secondary140() => const Color(0xFF0B2732);

  /*
   * SUCCESS
   */

  @override
  Color success() => const Color(0xFF6DE36B);

  @override
  Color success10() => const Color(0xFFE5F1E5);

  @override
  Color success120() => const Color(0xFF57B656);

  /*
   * WARNING
   */

  @override
  Color warning() => const Color(0xFFE3B36B);

  @override
  Color warning10() => const Color(0xFFF1ECE5);

  @override
  Color warning100() => const Color(0xFFB68F56);


}
