import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kwotmusic/components/kit/kit.dart';

enum ButtonType { primary, secondary, text, error ,disable}

class Button extends StatelessWidget {
  const Button({
    Key? key,
    this.width,
    this.height,
    this.alignment,
    this.type = ButtonType.primary,
    this.enabled = true,
    this.visuallyDisabled = false,
    this.margin = EdgeInsets.zero,
    this.overriddenForegroundColor,
    this.overriddenBackgroundColor,
    this.padding = EdgeInsets.zero,
    required this.onPressed,
    required this.text,
    this.textStyle,
  }) : super(key: key);

  final double? width;
  final double? height;
  final Alignment? alignment;
  final ButtonType type;
  final bool enabled;
  final bool visuallyDisabled;
  final EdgeInsets margin;
  final Color? overriddenForegroundColor;
  final Color? overriddenBackgroundColor;
  final EdgeInsets padding;
  final VoidCallback onPressed;
  final String text;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final boxShadow = obtainBoxShadow(context);
    final backgroundColor =
        overriddenBackgroundColor ?? obtainBackgroundColor(context);
    final backgroundDecorationImage = obtainBackgroundDecorationImage(context);
    final foregroundColor =
        overriddenForegroundColor ?? obtainForegroundColor(context);
    final minScale = obtainMinScale(context);

    final onPressed = enabled ? this.onPressed : null;

    return ScaleTap(
        scaleMinValue: minScale,
        onPressed: () => {},
        child: Container(
            decoration: BoxDecoration(
              boxShadow: boxShadow,
              image: backgroundDecorationImage,
              color: backgroundColor,
              borderRadius: BorderRadius.circular(ComponentRadius.normal.r),
            ),
            height: obtainHeight(),
            margin: margin,
            width: width,
            child: TextButton(
              onPressed: onPressed,
              style: ButtonStyle(
                tapTargetSize: (type == ButtonType.text)
                    ? MaterialTapTargetSize.shrinkWrap
                    : null,
                minimumSize: (type == ButtonType.text)
                    ? MaterialStateProperty.all(Size.zero)
                    : null,
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(ComponentRadius.normal.r))),
                padding: MaterialStateProperty.all(padding),
                overlayColor: MaterialStateProperty.resolveWith(
                    (states) => obtainOverlayColor(context, states)),
              ),
              child: Container(
                  alignment: alignment,
                  child: Text(text,
                      style: textStyle?.copyWith(color: foregroundColor) ??
                          TextStyles.boldHeading5
                              .copyWith(color: foregroundColor),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textAlign: TextAlign.center)),
            )));
  }

  List<BoxShadow>? obtainBoxShadow(BuildContext context) {
    if (enabled && !visuallyDisabled && type != ButtonType.text) {
      return [
        BoxShadow(
            // TODO: Perhaps use a neutral color for shadow
            color: Colors.black26,
            offset: Offset(0, 4.r),
            blurRadius: 5.r)
      ];
    }

    return null;
  }

  Color? obtainBackgroundColor(BuildContext context) {
    if (enabled && !visuallyDisabled) {
      switch (type) {
        case ButtonType.primary:
          return null;
        case ButtonType.secondary:
          return DynamicTheme.get(context).secondary100();
        case ButtonType.text:
          return Colors.transparent;
        case ButtonType.error:
          return DynamicTheme.get(context).error100();
        case ButtonType.disable:
          return DynamicTheme.get(context).neutral40();
      }
    } else {
      if (type == ButtonType.text) {
        return Colors.transparent;
      }
      return DynamicTheme.get(context).black();
    }
  }

  DecorationImage? obtainBackgroundDecorationImage(BuildContext context) {
    if (enabled && !visuallyDisabled && type == ButtonType.primary) {
      return DecorationImage(
          image: AssetImage(
              DynamicTheme.get(context).primaryDecorationAssetPath()),
          fit: BoxFit.fill);
    }

    return null;
  }

  Color? obtainForegroundColor(BuildContext context) {
    switch (type) {
      case ButtonType.primary:
        return enabled && !visuallyDisabled
            ? DynamicTheme.get(context).white()
            : DynamicTheme.get(context).primary20();
      case ButtonType.secondary:
        return enabled && !visuallyDisabled
            ? DynamicTheme.get(context).secondary10()
            : DynamicTheme.get(context).secondary20();
      case ButtonType.text:
        // TODO: When pressed, this should be secondary120
        return enabled && !visuallyDisabled
            ? DynamicTheme.get(context).secondary100()
            : DynamicTheme.get(context).secondary20();
      case ButtonType.error:
        return enabled && !visuallyDisabled
            ? DynamicTheme.get(context).white()
            : DynamicTheme.get(context).error100();
    }
  }

  double obtainHeight() {
    return height ?? ComponentSize.normal.h;
  }

  Color? obtainOverlayColor(BuildContext context, Set<MaterialState> states) {
    if (states.contains(MaterialState.disabled)) {
      return Colors.transparent;
    }

    if (!enabled || visuallyDisabled) {
      return Colors.transparent;
    }

    switch (type) {
      case ButtonType.primary:
        return DynamicTheme.get(context).primary120();
      case ButtonType.secondary:
        return Colors.transparent;
      case ButtonType.text:
        return Colors.transparent;
      case ButtonType.error:
        return DynamicTheme.get(context).error120();
    }
  }

  double? obtainMinScale(BuildContext context) {
    if (enabled) {
      if (type == ButtonType.text) {
        return null; // default scale
      }
      return 0.98;
    } else {
      return 1.0; // disables scale
    }
  }
}

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    Key? key,
    required this.width,
    required this.height,
    this.assetColor,
    required this.assetPath,
    this.assetSize,
    this.borderRadius,
    this.fit = BoxFit.cover,
    this.margin = EdgeInsets.zero,
    this.padding = EdgeInsets.zero,
    this.onPressed,
  }) : super(key: key);

  final double width;
  final double height;
  final Color? assetColor;
  final String assetPath;
  final double? assetSize;
  final BorderRadius? borderRadius;
  final BoxFit fit;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
        onPressed: onPressed,
        child: Container(
            width: width,
            height: height,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
                color: Colors.transparent, borderRadius: borderRadius),
            margin: margin,
            padding: padding,
            child: Center(
              child: SvgPicture.asset(assetPath,
                  width: assetSize ?? width,
                  height: assetSize ?? height,
                  color: assetColor,
                  fit: fit),
            )));
  }
}

class AppIconTextButton extends StatelessWidget {
  const AppIconTextButton({
    Key? key,
    required this.height,
    this.color,
    this.backgroundColor,
    required this.iconPath,
    this.iconSize,
    this.iconTextSpacing,
    required this.text,
    this.overwriteTextColor = true,
    this.textStyle,
    this.baseWidthTextStyle,
    this.borderRadius,
    this.fit = BoxFit.cover,
    this.margin = EdgeInsets.zero,
    this.padding = EdgeInsets.zero,
    this.axis = Axis.horizontal,
    this.onPressed,
  }) : super(key: key);

  final double height;
  final Color? color;
  final Color? backgroundColor;
  final String iconPath;
  final double? iconSize;
  final double? iconTextSpacing;
  final String text;
  final bool overwriteTextColor;
  final TextStyle? textStyle;
  final TextStyle? baseWidthTextStyle;
  final BorderRadius? borderRadius;
  final BoxFit fit;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final Axis axis;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
        onPressed: onPressed,
        child: Container(
            height: height,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              color: backgroundColor ?? Colors.transparent,
            ),
            margin: margin,
            padding: padding,
            child: _buildContent()));
  }

  Widget _buildContent() {
    switch (axis) {
      case Axis.horizontal:
        return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildIconWidget(),
              SizedBox(width: iconTextSpacing ?? 0),
              _TitleText(
                text: text,
                color: overwriteTextColor ? color : null,
                textStyle: textStyle,
                baseWidthTextStyle: baseWidthTextStyle,
              ),
            ]);
      case Axis.vertical:
        return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          _buildIconWidget(),
          SizedBox(height: iconTextSpacing ?? 0),
          _TitleText(
            text: text,
            color: overwriteTextColor ? color : null,
            textStyle: textStyle,
            baseWidthTextStyle: baseWidthTextStyle,
          ),
        ]);
    }
  }

  Widget _buildIconWidget() {
    final iconSize = this.iconSize ?? height;
    return SizedBox(
        width: iconSize,
        height: iconSize,
        child: SvgPicture.asset(iconPath,
            width: iconSize, height: iconSize, color: color, fit: fit));
  }
}

class _TitleText extends StatelessWidget {
  const _TitleText({
    Key? key,
    required this.text,
    required this.color,
    required this.textStyle,
    required this.baseWidthTextStyle,
  }) : super(key: key);

  final String text;
  final Color? color;
  final TextStyle? textStyle;
  final TextStyle? baseWidthTextStyle;

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = this.textStyle ?? TextStyles.heading5;
    if (color != null) {
      textStyle = textStyle.copyWith(color: color);
    }

    final baseWidthTextStyle = this.baseWidthTextStyle ?? textStyle;
    if (textStyle == baseWidthTextStyle) {
      return Text(text,
          maxLines: 1, overflow: TextOverflow.ellipsis, style: textStyle);
    }

    return Stack(children: [
      Text(text,
          maxLines: 1, overflow: TextOverflow.ellipsis, style: textStyle),
      Opacity(
        opacity: 0.0,
        child: Text(text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: baseWidthTextStyle),
      ),
    ]);
  }
}
