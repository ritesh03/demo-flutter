import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_svg/flutter_svg.dart';

class SvgAssetPhoto extends StatelessWidget {
  const SvgAssetPhoto(
    this.path, {
    Key? key,
    required this.width,
    required this.height,
    this.color,
    this.fit = BoxFit.contain,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  final String path;
  final double width;
  final double height;
  final Color? color;
  final BoxFit fit;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: SvgPicture.asset(
        path,
        width: width,
        height: height,
        color: color,
        fit: fit,
      ),
    );
  }
}
