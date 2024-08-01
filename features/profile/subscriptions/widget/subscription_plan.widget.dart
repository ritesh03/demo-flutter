import 'dart:math' as math;

import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:kwotdata/models/models.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/photo/svg_asset_photo.dart';
import 'package:kwotmusic/features/profile/subscriptions/ui_subscription_plan.dart';
import 'package:kwotmusic/l10n/localizations.dart';

import '../../../../util/prefs.dart';

class SubscriptionPlanWidget extends StatelessWidget {
  const SubscriptionPlanWidget({
    Key? key,
    this.margin = EdgeInsets.zero,
    this.maxHeight,
    required this.onTap,
    required this.plan,
    this.showBorder = false,
    this.child,
    this.childHeight,
  }) : super(key: key);

  final EdgeInsets margin;
  final double? maxHeight;
  final Function(SubscriptionPlan)? onTap;
  final SubscriptionPlan? plan;
  final bool showBorder;
  final Widget? child;
  final double? childHeight;

  @override
  Widget build(BuildContext context) {
    final subscriptionPlan = plan?.toUISubscriptionPlan(
      LocaleResources.of(context),
    );

    final border = showBorder
        ? Border.all(color: DynamicTheme.get(context).white(), width: 2.r)
        : null;

    final contentPadding = _obtainContentPadding();
    final logoMaskOffset =
        _obtainLogoMaskOffset(contentPadding: contentPadding);

    return ScaleTap(
      scaleMinValue: 0.98,
      onPressed: (onTap != null) ? () => onTap!.call(plan!) : null,
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight ?? double.infinity),
        margin: margin,
        decoration: BoxDecoration(
          gradient: subscriptionPlan?.bgGradient,
          borderRadius: BorderRadius.circular(ComponentRadius.normal.r),
          border: border,
        ),
        child: Stack(children: [
          Positioned(
              right: logoMaskOffset.dx,
              bottom: logoMaskOffset.dy,
              child: const _ShadowMask()),
          Padding(
            padding: EdgeInsets.all(contentPadding),
            child: _Content(
                hasFixedHeight: maxHeight != null,
                plan: subscriptionPlan,
                child: child),
          ),
        ]),
      ),
    );
  }

  double _obtainContentPadding() {
    return ComponentInset.normal.r;
  }

  Offset _obtainLogoMaskOffset({
    required double contentPadding,
  }) {
    double childHeight = this.childHeight ?? 0;
    if (childHeight != 0) {
      childHeight += contentPadding * 2;
    }

    return Offset(
      -24.r,
      -36.r + childHeight,
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    Key? key,
    required this.hasFixedHeight,
    required this.plan,
    required this.child,
  }) : super(key: key);

  final bool hasFixedHeight;
  final UISubscriptionPlan? plan;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _PlanPrice(
        text: plan?.displayPrice ?? "",
        token: plan?.tokens ?? "",
        planName: plan?.name,
      ),
      if (plan?.renewalDurationText != null)
        _PlanRenewalDuration(text: plan!.renewalDurationText!),
      _PlanName(text: (plan!.name)),
      _PlanDescription(text: plan!.description),
      SizedBox(height: ComponentInset.normal.r),
      if (!hasFixedHeight)
        for (final benefit in plan!.benefits) ...{
          _PlanBenefit(text: benefit.feature ?? ""),
          SizedBox(height: ComponentInset.small.r),
        },
      if (hasFixedHeight)
        Expanded(child: _PlanBenefits(benefits: plan!.benefits)),
      if (child != null) child!,
    ]);
  }
}

class _ShadowMask extends StatelessWidget {
  const _ShadowMask({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: math.pi / 12,
      child: SvgAssetPhoto(
        Assets.iconKwot,
        width: 144.r,
        height: 144.r,
        color: Colors.white.withOpacity(0.05),
      ),
    );
  }
}

class _PlanPrice extends StatelessWidget {
  const _PlanPrice({Key? key, required this.text, this.token, this.planName})
      : super(key: key);

  final String text;
  final String? token;
  final String? planName;

  @override
  Widget build(BuildContext context) {
    String planPrice = "${num.parse(SharedPref.prefs!.getString(SharedPref.userAmount) == null? "1":SharedPref.prefs!.getString(SharedPref.userAmount) ==""?"1":SharedPref.prefs!.getString(SharedPref.userAmount)??"1").toDouble() * (double.parse(text))}";
    double doubleValue = double.parse(planPrice);
    int intValue = doubleValue.toInt();
    return planName == "Free Plan"
        ? Text("FREE",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyles.robotoBoldHeading5
                .copyWith(color: DynamicTheme.get(context).white()))
        : Row(
            children: <Widget>[
              SvgAssetPhoto(
                Assets.tokenIcon,
                width: ComponentSize.small9.w,
                height: ComponentSize.small9.h,
              ),
              SizedBox(
                width: ComponentInset.smaller.w,
              ),
              Text("${token ?? ""} - ",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.robotoBoldHeading5
                      .copyWith(color: DynamicTheme.get(context).white())),
              SizedBox(
                width: 100,
                child: Text("${SharedPref.prefs!.getString(SharedPref.currencySymbol) ?? "\$"}${intValue.toString()}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyles.robotoBoldHeading5
                        .copyWith(color: DynamicTheme.get(context).white())),
              )
            ],
          );

    /*Text(text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.robotoBoldHeading5
            .copyWith(color: DynamicTheme.get(context).white()))*/
    ;
  }
}

class _PlanRenewalDuration extends StatelessWidget {
  const _PlanRenewalDuration({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.caption
            .copyWith(color: DynamicTheme.get(context).neutral10()));
  }
}

class _PlanName extends StatelessWidget {
  const _PlanName({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.boldHeading2
            .copyWith(color: DynamicTheme.get(context).white()));
  }
}

class _PlanDescription extends StatelessWidget {
  const _PlanDescription({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyles.heading6
            .copyWith(color: DynamicTheme.get(context).neutral10()));
  }
}

class _PlanBenefits extends StatelessWidget {
  const _PlanBenefits({
    Key? key,
    required this.benefits,
  }) : super(key: key);

  final List<SubscriptionFeature> benefits;

  @override
  Widget build(BuildContext context) {
    if (benefits.isEmpty) return const SizedBox.shrink();
    return ShaderMask(
      shaderCallback: (Rect rect) {
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.white],
          stops: [0.8, 1.0],
        ).createShader(rect);
      },
      blendMode: BlendMode.dstOut,
      child: ListView(physics: const NeverScrollableScrollPhysics(), children: [
        for (final benefit in benefits) ...{
          _PlanBenefit(text: benefit.feature ?? ""),
          SizedBox(height: ComponentInset.small.r),
        },
      ]),
    );
  }
}

class _PlanBenefit extends StatelessWidget {
  const _PlanBenefit({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    final iconSize = ComponentSize.smallest.r;
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SvgAssetPhoto(
        Assets.iconCheckMedium,
        width: iconSize,
        height: iconSize,
        color: DynamicTheme.get(context).success(),
      ),
      SizedBox(width: ComponentInset.small.r),
      Expanded(
        child: Text(text,
            style: TextStyles.heading6
                .copyWith(color: DynamicTheme.get(context).white())),
      ),
    ]);
  }
}
