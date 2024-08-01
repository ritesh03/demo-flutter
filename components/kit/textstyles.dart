import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';

// TODO: Should we use context to create these text-styles?
//  There's no typography defined in the app declaration.
class TextStyles {
  //=

  static const _base = TextStyle(
    fontWeight: FontWeight.w400,
    fontFamily: 'Poppins',
    color: DynamicTheme.defaultTextColor,
    leadingDistribution: TextLeadingDistribution.even,
  );

  // Note: Enable HERO style only if there's any use for it.
  // static const hero = TextStyle(fontSize: SizeConfig.valueOf(48), fontWeight: FontWeight.w400);

  static TextStyle get heading1 =>
      _base.copyWith(fontSize: 32.sp, height: 1.24);

  static TextStyle get heading2 =>
      _base.copyWith(fontSize: 24.sp, height: 1.32);

  static TextStyle get heading3 =>
      _base.copyWith(fontSize: 18.sp, height: 1.32);

  static TextStyle get heading4 => _base.copyWith(fontSize: 16.sp, height: 1.5);

  static TextStyle get heading5 => _base.copyWith(fontSize: 14.sp, height: 1.7);

  static TextStyle get heading6 => _base.copyWith(fontSize: 12.sp, height: 1.3);

  static TextStyle get body => _base.copyWith(fontSize: 14.sp, height: 1.7);

  static TextStyle get caption => _base.copyWith(fontSize: 8.sp, height: 2);

  /*
   * BOLD TEXT STYLES
   */

  static TextStyle get boldHeading1 =>
      heading1.copyWith(fontWeight: FontWeight.w600);

  static TextStyle get boldHeading2 =>
      heading2.copyWith(fontWeight: FontWeight.w600);

  static TextStyle get boldHeading3 =>
      heading3.copyWith(fontWeight: FontWeight.w600);


  static TextStyle get boldHeading4 =>
      heading4.copyWith(fontWeight: FontWeight.w600);

  static TextStyle get boldHeading5 =>
      heading5.copyWith(fontWeight: FontWeight.w600);

  static TextStyle get boldHeading6 =>
      heading6.copyWith(fontWeight: FontWeight.w600);
  static TextStyle get boldHeading7=>
      heading5.copyWith(fontWeight:FontWeight.w600 );
  static TextStyle get boldHeading8 =>
      heading3.copyWith(fontWeight:FontWeight.w600 );

  static TextStyle get boldBody => body.copyWith(fontWeight: FontWeight.w600);

  static TextStyle get boldCaption =>
      caption.copyWith(fontWeight: FontWeight.w600);

  /*
   * LIGHT TEXT STYLES
   */

  static TextStyle get lightHeading1 =>
      heading1.copyWith(fontWeight: FontWeight.w300);

  static TextStyle get lightHeading2 =>
      heading2.copyWith(fontWeight: FontWeight.w300);

  static TextStyle get lightHeading3 =>
      heading3.copyWith(fontWeight: FontWeight.w300);

  static TextStyle get lightHeading4 =>
      heading4.copyWith(fontWeight: FontWeight.w300);

  static TextStyle get lightHeading5 =>
      heading5.copyWith(fontWeight: FontWeight.w300);

  static TextStyle get lightHeading6 =>
      heading6.copyWith(fontWeight: FontWeight.w300);

  static TextStyle get lightBody => body.copyWith(fontWeight: FontWeight.w300);

  static TextStyle get lightCaption =>
      caption.copyWith(fontWeight: FontWeight.w300);

  /*
   * ROBOTO BOLD
   */

  static const _roboto = TextStyle(
    fontWeight: FontWeight.w400,
    fontFamily: 'Roboto',
    color: DynamicTheme.defaultTextColor,
    leadingDistribution: TextLeadingDistribution.even,
  );


  static TextStyle get robotoBoldHeading4 => _roboto.copyWith(
      fontWeight: FontWeight.w700, fontSize: 16.sp, height: 1.5);
  static TextStyle get robotoBoldHeading5 => _roboto.copyWith(
      fontSize: 14.sp, height: 1.5);
  static TextStyle get robotoBoldHeading6 => _roboto.copyWith(
      fontSize: 16.sp,fontWeight: FontWeight.w600, height: 1.5);
  static TextStyle get robotoBoldHeading7 => _roboto.copyWith(
      fontSize: 14.sp,fontWeight: FontWeight.w600, height: 1.5);
  static TextStyle get robotoBoldHeading8 => _roboto.copyWith(
      fontSize: 32.sp,fontWeight: FontWeight.w600, height: 1.5);
  static TextStyle get robotoBoldHeading9 => _roboto.copyWith(
      fontSize: 30.sp,fontWeight: FontWeight.w600, height: 1.5);

}
