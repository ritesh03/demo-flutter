import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kwotmusic/components/kit/kit.dart';

import 'fullscreen_control_button.dart';

class FullScreenIconControlButton extends StatelessWidget {
  const FullScreenIconControlButton({
    Key? key,
    required this.assetPath,
    this.assetSize,
    this.color,
    this.margin,
    required this.onTap,
    this.size,
  }) : super(key: key);

  final String assetPath;
  final double? assetSize;
  final Color? color;
  final EdgeInsets? margin;
  final VoidCallback onTap;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final size = this.size ?? ComponentSize.large.r;
    final assetSize = this.assetSize ?? ComponentSize.small.r;
    return FullScreenControlButton(
        onTap: onTap,
        width: size,
        height: size,
        margin: margin,
        child: Center(
            child: SvgPicture.asset(assetPath,
                width: assetSize,
                height: assetSize,
                color: color ?? DynamicTheme.get(context).white())));
  }
}
