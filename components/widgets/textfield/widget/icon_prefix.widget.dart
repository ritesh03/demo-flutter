import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kwotmusic/components/kit/kit.dart';

class IconPrefix extends StatelessWidget {
  const IconPrefix({
    Key? key,
    required this.iconPath,
    required this.iconColor,
  }) : super(key: key);

  final String iconPath;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: ComponentSize.normal.w,
        alignment: Alignment.center,
        child: SvgPicture.asset(
          iconPath,
          width: ComponentSize.smaller.r,
          height: ComponentSize.smaller.r,
          color: iconColor,
        ));
  }
}
