import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kwotmusic/components/kit/kit.dart';

class FilterChipWidget extends StatelessWidget {
  const FilterChipWidget({
    Key? key,
    required this.title,
    required this.iconPath,
    this.margin = EdgeInsets.zero,
    this.backgroundColor,
    this.foregroundColor,
    this.onIconTap,
  }) : super(key: key);

  final String title;
  final String iconPath;
  final EdgeInsets margin;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final VoidCallback? onIconTap;

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        this.backgroundColor ?? DynamicTheme.get(context).secondary100();

    final foregroundColor =
        this.foregroundColor ?? DynamicTheme.get(context).black();

    return Container(
        decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(ComponentRadius.normal.r)),
        margin: margin,
        height: ComponentSize.small.h,
        child: Row(children: [
          SizedBox(width: ComponentInset.normal.r),
          Text(title,
              style: TextStyles.heading6.copyWith(color: foregroundColor)),
          _buildIconButton(color: foregroundColor),
        ]));
  }

  Widget _buildIconButton({required Color color}) {
    return ScaleTap(
        onPressed: onIconTap,
        child: Container(
            // width: ComponentSize.small.r,
            height: ComponentSize.small.r,
            color: Colors.transparent,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: ComponentInset.small.r),
            child: SvgPicture.asset(iconPath,
                color: color, width: 16.r, height: 16.r)));
  }
}
