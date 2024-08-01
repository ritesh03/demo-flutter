import 'package:flutter/cupertino.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kwotdata/models/artist/subscription.artist.model.dart';
import 'package:kwotdata/models/subscription/subscription_plan.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import "package:kwotmusic/components/widgets/photo/svg_asset_photo.dart";
import 'package:kwotmusic/features/profile/subscriptions/ui_subscription_plan.dart';

import '../../../../features/artist/profile/artist.model.dart';
import '../../../../l10n/localizations.dart';
import '../../../../util/prefs.dart';
import '../../looping_page_view.dart';
import '../../photo/photo.dart';

class FanClubPlanWidget extends StatefulWidget {
  String planId;
  final SubscriptionArtistPlanModel plan;
  ArtistModel artistModel;
  bool isButtonEnable;
  VoidCallback onaTap;
  FanClubPlanWidget({
    Key? key,
    required this.plan,
    required this.planId,
    required this.artistModel,
    required this.isButtonEnable,
    required this.onaTap,
  }) : super(key: key);

  @override
  State<FanClubPlanWidget> createState() => _FanClubPlanWidgetState();
}

class _FanClubPlanWidgetState extends State<FanClubPlanWidget> {
  String? selectedIndex;
  @override
  Widget build(BuildContext context) {
    final subPlan = widget.plan.toUISubscriptionPlanModel(
      LocaleResources.of(context),
    );
    final logoMaskOffset =
        _obtainLogoMaskOffset(contentPadding: ComponentInset.small.r);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ComponentInset.small.w),
      child: ScaleTap(
        onPressed: () {},
        child: GestureDetector(
          onTap: widget.onaTap,
          /*() {
            widget.setState(() {
              selectedIndex = widget.planId;
              widget.artistModel.planId = widget.planId;
              widget.artistModel.toBuyPlanToken =widget.plan.tokens;
              widget.isButtonEnable = true;
            });
          },*/
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(ComponentInset.small.r),
                border: Border.all(
                    color: widget.isButtonEnable
                        ? DynamicTheme.get(context).white()
                        : Colors.transparent,
                    width: widget.isButtonEnable ? 2.w : 2.w)),
            child: Container(
              decoration: BoxDecoration(
                gradient: subPlan.bgGradient,
                borderRadius: BorderRadius.circular(ComponentInset.small.r),
              ),
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: <Widget>[
                  Positioned(
                      right: logoMaskOffset.dx,
                      bottom: -56,
                      child: const _ShadowMask()),
                  _Content(
                    plan: subPlan,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Offset _obtainLogoMaskOffset({
    required double contentPadding,
  }) {
    double childHeight = 0 ?? 0;
    if (childHeight != 0) {
      childHeight += contentPadding * 2;
    }

    return Offset(
      -24.r,
      -36.r + childHeight,
    );
  }
}

class _ShadowMask extends StatelessWidget {
  const _ShadowMask({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: math.pi / 15,
      child: SvgAssetPhoto(
        Assets.iconKwot,
        width: 144.r,
        height: 144.r,
        color: Colors.white.withOpacity(0.05),
      ),
    );
  }
}

///All the content of this widget is come from backend so i have used static text
class _Content extends StatelessWidget {
  UISubscriptionPlan plan;
  _Content({Key? key, required this.plan}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ComponentInset.inset20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: ComponentInset.normal.h,
          ),
          _amountWidget(context, plan),
          _durationWidget(context, plan),
          _planNameWidget(context, plan),
          _descriptionWidget(context, plan),
          SizedBox(
            height: ComponentInset.normal.h,
          ),
          for (final benefit in plan.benefits) ...{
            _PlanBenefit(text: benefit.feature ?? ""),
            SizedBox(height: ComponentInset.small.r),
          },
        ],
      ),
    );
  }
}

Widget _amountWidget(BuildContext context, UISubscriptionPlan plan) {
  String planPrice =
      "${num.parse(SharedPref.prefs?.getString(SharedPref.userAmount) == null ? "1" : SharedPref.prefs!.getString(SharedPref.userAmount) == "" ? "1" : SharedPref.prefs?.getString(SharedPref.userAmount) ?? "1").toDouble() * (double.parse(plan.displayPrice))}";
  double doubleValue = double.parse(planPrice);
  int intValue = doubleValue.toInt();
  return Row(
    children: <Widget>[
      SvgAssetPhoto(
        Assets.tokenIcon,
        width: ComponentSize.small9.w,
        height: ComponentSize.small9.h,
      ),
      SizedBox(
        width: ComponentInset.smaller.w,
      ),
      Text("${plan.tokens} - ",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyles.boldHeading4
              .copyWith(color: DynamicTheme.get(context).white())),
      Text(
          "${SharedPref.prefs!.getString(SharedPref.currencySymbol) ?? "\$"}${intValue.toString()}",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyles.robotoBoldHeading5
              .copyWith(color: DynamicTheme.get(context).white()))
    ],
  );
}

Widget _durationWidget(BuildContext context, UISubscriptionPlan plan) {
  return Text(plan.renewalDurationText ?? "",
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyles.caption
          .copyWith(color: DynamicTheme.get(context).neural100()));
}

Widget _planNameWidget(BuildContext context, UISubscriptionPlan plan) {
  return Text(plan.name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyles.boldHeading2
          .copyWith(color: DynamicTheme.get(context).white()));
}

Widget _descriptionWidget(BuildContext context, UISubscriptionPlan plan) {
  return Text(plan.description,
      style: TextStyles.heading6
          .copyWith(color: DynamicTheme.get(context).neural100()));
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
