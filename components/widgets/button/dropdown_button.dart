import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/marquee/marquee.dart';

class DropDownButton extends StatelessWidget {
  const DropDownButton({
    Key? key,
    this.width,
    this.height,
    this.enabled = true,
    this.errorText,
    this.hasLabel = true,
    required this.hintText,
    required this.inputText,
    this.labelText,
    this.margin = EdgeInsets.zero,
    required this.onTap,
    this.showShadow = false,
  }) : super(key: key);

  final double? width;
  final double? height;
  final bool enabled;
  final String? errorText;
  final bool hasLabel;
  final String hintText;
  final String? inputText;
  final String? labelText;
  final EdgeInsets margin;
  final VoidCallback onTap;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
      onPressed: enabled ? onTap : null,
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasLabel) _buildLabel(context),
          if (hasLabel) SizedBox(height: 2.h),
          Container(
              width: width,
              height: obtainHeight(),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                  color: obtainBackgroundColor(context),
                  borderRadius: obtainBorderRadius(),
                  boxShadow: obtainBoxShadow(context)),
              margin: margin,
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                SizedBox(width: ComponentInset.normal.w),
                Expanded(child: _buildText(context)),
                SizedBox(width: ComponentInset.normal.w),
                _buildIcon(context),
                SizedBox(width: ComponentInset.small.w),
              ]))
        ]);
  }

  Widget _buildLabel(BuildContext context) {
    return Container(
        height: ComponentSize.smallest.h,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.small.w),
        child: Marquee(
          text: obtainLabelText(),
          style: TextStyles.heading6.copyWith(
            color: obtainLabelColor(context),
          ),
          scrollAxis: Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.start,
          blankSpace: 20.0,
          velocity: 100.0,
          accelerationDuration: const Duration(seconds: 1),
          accelerationCurve: Curves.linear,
          decelerationDuration: const Duration(milliseconds: 500),
          decelerationCurve: Curves.easeOut,
        ));
  }

  Widget _buildText(BuildContext context) {
    final inputText = this.inputText;
    final textStyle = TextStyles.heading5;

    if (inputText == null || inputText.isEmpty) {
      return Text(hintText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textStyle.copyWith(color: obtainHintColor(context)));
    }

    return Text(inputText,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: textStyle.copyWith(color: obtainTextColor(context)));
  }

  Widget _buildIcon(BuildContext context) {
    return Container(
        width: ComponentSize.small.r,
        height: ComponentSize.small.r,
        padding: EdgeInsets.all(ComponentInset.smaller.r),
        child: SvgPicture.asset(
          Assets.iconArrowDown,
          color: obtainIconColor(context),
        ));
  }

  Color obtainBackgroundColor(BuildContext context) {
    if (errorText != null) {
      return DynamicTheme.get(context).error100();
    }

    return enabled
        ? DynamicTheme.get(context).neutral80()
        : DynamicTheme.get(context).black();
  }

  BorderRadius obtainBorderRadius() {
    return BorderRadius.circular(ComponentRadius.normal.r);
  }

  List<BoxShadow>? obtainBoxShadow(BuildContext context) {
    if (enabled && showShadow) {
      return const [
        BoxShadow(
            // TODO: Perhaps use a neutral color for shadow
            color: Colors.black26,
            offset: Offset(0, 4),
            blurRadius: 5.0)
      ];
    }

    return null;
  }

  double obtainHeight() {
    return height ?? ComponentSize.normal.h;
  }

  Color obtainHintColor(BuildContext context) {
    if (errorText != null) {
      return DynamicTheme.get(context).white();
    }

    return enabled
        ? DynamicTheme.get(context).neutral20()
        : DynamicTheme.get(context).neutral60();
  }

  String obtainLabelText() {
    // Show errorText as label if not null.
    if (errorText != null) {
      return errorText!;
    }

    return labelText!;
  }

  Color obtainLabelColor(BuildContext context) {
    if (errorText != null) {
      return DynamicTheme.get(context).error100();
    }

    return DynamicTheme.get(context).neutral40();
  }

  Color obtainTextColor(BuildContext context) {
    return DynamicTheme.get(context).white();
  }

  Color obtainIconColor(BuildContext context) {
    if (errorText != null) {
      return DynamicTheme.get(context).white();
    }

    return enabled
        ? DynamicTheme.get(context).neutral10()
        : DynamicTheme.get(context).neutral60();
  }
}
