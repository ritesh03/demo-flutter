import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';

class TappableButton extends StatelessWidget {
  const TappableButton({
    Key? key,
    this.borderRadius,
    this.backgroundColor,
    required this.child,
    required this.onTap,
    this.overlayColor,
    this.padding = EdgeInsets.zero,
    this.withNoMinimumSize = false,
  }) : super(key: key);

  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Widget child;
  final VoidCallback? onTap;
  final Color? overlayColor;
  final EdgeInsets padding;
  final bool withNoMinimumSize;

  @override
  Widget build(BuildContext context) {
    final borderRadius =
        this.borderRadius ?? BorderRadius.circular(ComponentRadius.normal.r);

    final backgroundColor = this.backgroundColor ?? Colors.transparent;

    final overlayColor =
        this.overlayColor ?? DynamicTheme.get(context).secondary10();

    return TextButton(
        onPressed: onTap,
        style: ButtonStyle(
            tapTargetSize:
                withNoMinimumSize ? MaterialTapTargetSize.shrinkWrap : null,
            minimumSize:
                withNoMinimumSize ? MaterialStateProperty.all(Size.zero) : null,
            backgroundColor: MaterialStateProperty.all(backgroundColor),
            padding: MaterialStateProperty.all(padding),
            overlayColor: MaterialStateProperty.all(overlayColor),
            shape: MaterialStateProperty.all(
                RoundedRectangleBorder(borderRadius: borderRadius))),
        child: child);
  }
}
