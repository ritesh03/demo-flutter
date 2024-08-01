import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:kwotmusic/components/kit/kit.dart';

class FullScreenControlButton extends StatelessWidget {
  const FullScreenControlButton({
    Key? key,
    this.width,
    this.height,
    this.margin,
    required this.child,
    required this.onTap,
  }) : super(key: key);

  final double? width;
  final double? height;
  final EdgeInsets? margin;
  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
        onPressed: onTap,
        child: Container(
            width: width,
            height: height,
            margin: margin,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: DynamicTheme.get(context).black().withOpacity(0.8),
                borderRadius: BorderRadius.circular(ComponentRadius.normal.r)),
            child: child));
  }
}
