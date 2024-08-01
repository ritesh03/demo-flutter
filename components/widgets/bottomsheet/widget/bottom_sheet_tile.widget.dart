import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kwotmusic/components/kit/kit.dart';

class BottomSheetTile extends StatelessWidget {
  const BottomSheetTile({
    Key? key,
    this.width,
    this.height,
    this.backgroundColor,
    this.foregroundColor,
    this.iconPath,
    this.margin,
    required this.onTap,
    required this.text,
    this.trailing,
  }) : super(key: key);

  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? iconPath;
  final EdgeInsets? margin;
  final VoidCallback onTap;
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final foregroundColor =
        this.foregroundColor ?? DynamicTheme.get(context).white();
    final backgroundColor =
        this.backgroundColor ?? DynamicTheme.get(context).background();

    final height = this.height ?? ComponentSize.large.h;

    return ScaleTap(
      onPressed: onTap,
      scaleMinValue: 0.98,
      child: Container(
          height: height,
          margin: margin,
          decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(ComponentRadius.normal.r)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            if (iconPath != null)
              Container(
                  width: height,
                  height: height,
                  alignment: Alignment.center,
                  child: SvgPicture.asset(iconPath!,
                      width: ComponentSize.small.r,
                      height: ComponentSize.small.r,
                      color: foregroundColor)),
            if (iconPath == null) SizedBox(width: ComponentInset.normal.w),
            Expanded(
              child: Text(text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.body.copyWith(color: foregroundColor)),
            ),
            if (trailing != null) trailing!,
          ])),
    );
  }
}
