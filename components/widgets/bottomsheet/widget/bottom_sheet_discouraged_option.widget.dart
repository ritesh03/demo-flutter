import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kwotmusic/components/kit/kit.dart';

class BottomSheetDiscouragedOption extends StatelessWidget {
  const BottomSheetDiscouragedOption({
    Key? key,
    required this.iconPath,
    this.iconColor,
    required this.text,
    this.textColor,
    this.trailing,
    this.margin,
    this.onTap,
  }) : super(key: key);

  final String iconPath;
  final Color? iconColor;
  final String text;
  final Color? textColor;
  final Widget? trailing;
  final EdgeInsets? margin;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final itemHeight = ComponentSize.large.h;
    final iconSize = ComponentSize.large.h;

    final iconColor = this.iconColor ?? DynamicTheme.get(context).neutral20();
    final textColor = this.textColor ?? DynamicTheme.get(context).neutral10();

    return ScaleTap(
      onPressed: onTap,
      scaleMinValue: 0.98,
      child: Container(
          height: itemHeight,
          margin: margin,
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            // OPTION ICON
            Container(
                width: iconSize,
                height: iconSize,
                alignment: Alignment.center,
                child: SvgPicture.asset(iconPath,
                    width: ComponentSize.small.r,
                    height: ComponentSize.small.r,
                    color: iconColor)),

            // OPTION TEXT
            Expanded(
              child: Text(text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.body.copyWith(color: textColor)),
            ),

            // TRAILING TEXT
            if (trailing != null) trailing!,
          ])),
    );
  }
}
