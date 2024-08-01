import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/features/profile/widget/account_option.widget.dart';

class AccountOptionHorizontalItem extends StatelessWidget {
  const AccountOptionHorizontalItem({
    Key? key,
    this.width,
    required this.height,
    required this.margin,
    required this.iconPath,
    required this.text,
    required this.onTap,
  }) : super(key: key);

  final double? width;
  final double height;
  final EdgeInsets margin;
  final String iconPath;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
      onPressed: onTap,
      child: AccountOption(
          width: width,
          height: height,
          margin: margin,
          child: Row(children: [
            Container(
                width: height,
                height: height,
                alignment: Alignment.center,
                child: SvgPicture.asset(iconPath,
                    width: ComponentSize.small.r,
                    height: ComponentSize.small.r,
                    color: DynamicTheme.get(context).white())),
            // SizedBox(width: ComponentInset.small.w),
            Container(
                height: ComponentSize.smaller.h,
                alignment: Alignment.centerLeft,
                child: Text(text, style: TextStyles.body))
          ])),
    );
  }
}
