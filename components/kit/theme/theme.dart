import 'package:flutter/material.dart'  hide SearchBar;

abstract class AppTheme {
  /*
   *
   * BASE
   */

  Color background();

  Color surface();

  Color onSurface();

  Color black();

  Color white();

  /*
   * ERROR
   */

  Color error10();

  Color error100();

  Color error120();

  /*
   * NEUTRAL
   */

  Color neutral10();

  Color neutral20();

  Color neutral40();

  Color neutral60();

  Color neutral80();
  Color neural100();


  /*
   * PRIMARY
   */

  Color primary10();

  Color primary20();

  Color primary40();

  Color primary60();

  Color primary120();

  @Deprecated("Use [primaryDecorationImage()]")
  Gradient primaryGradient();

  String primaryDecorationAssetPath();

  /*
   * SECONDARY
   */

  Color secondary10();

  Color secondary20();

  Color secondary40();

  Color secondary60();

  Color secondary100();

  Color secondary120();
  Color secondary140();

  /*
   * SUCCESS
   */

  Color success();

  Color success10();

  Color success120();

  /*
   * WARNING
   */

  Color warning();

  Color warning10();

  Color warning100();
}
