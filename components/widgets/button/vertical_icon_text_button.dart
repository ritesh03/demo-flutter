import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kwotmusic/components/kit/kit.dart';

class VerticalIconTextButton extends StatelessWidget {
  const VerticalIconTextButton({
    Key? key,
    required this.height,
    this.borderRadius,
    required this.color,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.fit = BoxFit.cover,
    required this.iconPath,
    this.iconSize,
    this.iconTextSpacing,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.margin = EdgeInsets.zero,
    this.onIconTap,
    this.onTap,
    this.onTextTap,
    this.padding = EdgeInsets.zero,
    required this.text,
    this.textStyle,
  }) : super(key: key);

  final double height;
  final BorderRadius? borderRadius;
  final Color color;
  final CrossAxisAlignment crossAxisAlignment;
  final BoxFit fit;
  final String iconPath;
  final double? iconSize;
  final double? iconTextSpacing;
  final MainAxisAlignment mainAxisAlignment;
  final EdgeInsets margin;
  final VoidCallback? onIconTap;
  final VoidCallback? onTap;
  final VoidCallback? onTextTap;
  final EdgeInsets padding;
  final String text;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final widget = Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
            borderRadius: borderRadius, color: Colors.transparent),
        margin: margin,
        padding: padding,
        child: Column(
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            mainAxisSize: MainAxisSize.min,
            children: [_buildIcon(context), _buildText(context)]));

    if (onTap == null) {
      return widget;
    }

    return ScaleTap(onPressed: onTap, child: widget);
  }

  Widget _buildIcon(BuildContext context) {
    final iconSize = 32.r;
    final widget = SizedBox(
        width: iconSize,
        height: iconSize,
        child: SvgPicture.asset(
          iconPath,
          width: iconSize,
          height: iconSize,
          color: color,
          fit: fit,
        ));

    if (onIconTap == null) {
      return widget;
    }

    return ScaleTap(onPressed: onIconTap, child: widget);
  }

  Widget _buildText(BuildContext context) {
    final widget = Text(text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: (textStyle ?? TextStyles.heading6).copyWith(color: color));

    if (onTextTap == null) {
      return widget;
    }

    return ScaleTap(onPressed: onTextTap, child: widget);
  }
}
