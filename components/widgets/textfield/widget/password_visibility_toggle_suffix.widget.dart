import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kwotmusic/components/kit/kit.dart';

class PasswordVisibilityToggleSuffix extends StatelessWidget {
  const PasswordVisibilityToggleSuffix({
    Key? key,
    this.disableTinting = false,
    this.enabled = true,
    this.hasError = false,
    required this.isPasswordVisible,
    required this.onPressed,
    this.size,
  }) : super(key: key);

  final bool disableTinting;
  final bool enabled;
  final bool hasError;
  final bool isPasswordVisible;
  final VoidCallback onPressed;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final width = ComponentSize.normal.w;
    final iconSize = ComponentSize.smaller.r;
    return ScaleTap(
        onPressed: onPressed,
        child: Container(
            width: width,
            color: Colors.transparent,
            child: Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: iconSize,
                height: iconSize,
                child: SvgPicture.asset(
                    isPasswordVisible ? Assets.iconViewHide : Assets.iconView,
                    color: _obtainTintColor(context)),
              ),
            )));
  }

  Color _obtainTintColor(BuildContext context) {
    if (hasError) {
      return DynamicTheme.get(context).white();
    }

    return enabled
        ? DynamicTheme.get(context).neutral20()
        : DynamicTheme.get(context).neutral60();
  }
}
