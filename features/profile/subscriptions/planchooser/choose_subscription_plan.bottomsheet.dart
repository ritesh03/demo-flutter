import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/models/models.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/bottomsheet_drag_handle.widget.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/material_bottom_sheet.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/indicator/indicators.dart';
import 'package:kwotmusic/components/widgets/looping_page_view.dart';
import 'package:kwotmusic/features/profile/subscriptions/subscription_detail.model.dart';
import 'package:kwotmusic/features/profile/subscriptions/widget/subscription_plan.widget.dart';
import 'package:kwotmusic/l10n/localizations.dart';

class ChooseSubscriptionPlanBottomSheet extends StatefulWidget {
  //=
  static Future<SubscriptionPlan?> show(
    BuildContext context, {
    String? chosenSubscriptionPlanId,
  }) {
    return showMaterialBottomSheet<SubscriptionPlan?>(
      context,
      expand: false,
      builder: (context, controller) {
        return ChooseSubscriptionPlanBottomSheet(
            chosenSubscriptionPlanId: chosenSubscriptionPlanId);
      },
    );
  }

  const ChooseSubscriptionPlanBottomSheet({
    Key? key,
    required this.chosenSubscriptionPlanId,
  }) : super(key: key);

  final String? chosenSubscriptionPlanId;

  @override
  State<ChooseSubscriptionPlanBottomSheet> createState() =>
      _ChooseSubscriptionPlanBottomSheetState();
}

class _ChooseSubscriptionPlanBottomSheetState
    extends State<ChooseSubscriptionPlanBottomSheet> {
  //=
  late final LoopingPageController _loopingPageController;

  @override
  void initState() {
    super.initState();

    _loopingPageController = LoopingPageController();
  }

  @override
  Widget build(BuildContext context) {
    final smallSpacing = ComponentInset.small.r;
    final normalSpacing = ComponentInset.normal.r;
    final localeResource = LocaleResources.of(context);

    return Column(mainAxisSize: MainAxisSize.min, children: [
      const BottomSheetDragHandle(),
      SizedBox(height: smallSpacing),

      // TITLE
      Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: normalSpacing),
        child: Text(localeResource.subscriptionChooseAPlan,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyles.boldHeading2
                .copyWith(color: DynamicTheme.get(context).white())),
      ),
      SizedBox(height: normalSpacing),

      // PLANS
      _SubscriptionPlanChooser(
          chosenSubscriptionPlanId: widget.chosenSubscriptionPlanId,
          height: 272.r,
          itemSpacing: smallSpacing,
          localeResource: localeResource,
          loopingPageController: _loopingPageController,
          onTap: _onTap),
      SizedBox(height: normalSpacing),

      // CAPTION / NOTE
      Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: normalSpacing),
        child: Text(localeResource.subscriptionPlanAutoRenewalNote,
            overflow: TextOverflow.ellipsis,
            maxLines: 3,
            style: TextStyles.heading5
                .copyWith(color: DynamicTheme.get(context).neutral10()),
            textAlign: TextAlign.left),
      ),
      SizedBox(height: normalSpacing),

      // JOIN BUTTON
      if (widget.chosenSubscriptionPlanId == null)
        Container(
          padding: EdgeInsets.only(
              left: normalSpacing, right: normalSpacing, bottom: normalSpacing),
          child: Button(
            width: double.infinity,
            onPressed: _onJoinTap,
            text: localeResource.subscriptionJoinKwotPremium,
            type: ButtonType.primary,
          ),
        ),
    ]);
  }

  void _onTap(SubscriptionPlan plan) {
    Navigator.of(context).pop(plan);
  }

  void _onJoinTap() {
    final itemIndex = _loopingPageController.currentItemIndex;
    final plan = locator<SubscriptionDetailModel>()
        .getSubscriptionPlanByIndex(itemIndex);
    if (plan != null) {
      Navigator.of(context).pop(plan);
    }
  }
}

class _SubscriptionPlanChooser extends StatelessWidget {
  const _SubscriptionPlanChooser({
    Key? key,
    required this.chosenSubscriptionPlanId,
    required this.height,
    required this.itemSpacing,
    required this.localeResource,
    required this.loopingPageController,
    required this.onTap,
  }) : super(key: key);

  final String? chosenSubscriptionPlanId;
  final double height;
  final double itemSpacing;
  final TextLocaleResource localeResource;
  final LoopingPageController loopingPageController;
  final Function(SubscriptionPlan) onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: StreamBuilder<SubscriptionPlansResult?>(
          stream: locator<SubscriptionDetailModel>().subscriptionPlansStream,
          builder: (_, snapshot) {
            final result = snapshot.data;
            if (result == null) {
              return const Center(child: LoadingIndicator());
            }
            if (!result.isSuccess() || result.isEmpty()) {
              return Center(
                child: ErrorIndicator(
                  error: result.error(),
                  onTryAgain: locator<SubscriptionDetailModel>()
                      .refreshSubscriptionPlans,
                ),
              );
            }
            final plans = result.data();
            return LoopingPageView(
              controller: loopingPageController,
              itemCount: plans.length,
              itemBuilder: (_, index) {
                final plan = plans[index];
                return SubscriptionPlanWidget(
                  plan: plan,
                  margin: EdgeInsets.symmetric(horizontal: itemSpacing),
                  maxHeight: height,
                  onTap: onTap,
                  showBorder: chosenSubscriptionPlanId == plan.id,
                );
              },
            );
          }),
    );
  }
}
