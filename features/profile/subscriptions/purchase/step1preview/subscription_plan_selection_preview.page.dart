import 'dart:io';

import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/models/models.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/page/page_state.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/profile/subscriptions/planchooser/choose_subscription_plan.bottomsheet.dart';
import 'package:kwotmusic/features/profile/subscriptions/widget/subscription_plan.widget.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:provider/provider.dart';

import '../../../../../components/widgets/alert_box_buy_token.dart';
import '../../../../../components/widgets/notificationbar/notification_bar.dart';
import '../../../../../util/util_url_launcher.dart';
import 'subscription_plan_selection_preview.model.dart';

class SubscriptionPlanSelectionPreviewPage extends StatefulWidget {
  SubscriptionPlanSelectionPreviewPage({
    Key? key,
  }) : super(key: key);

  @override
  State<SubscriptionPlanSelectionPreviewPage> createState() =>
      _SubscriptionPlanSelectionPreviewPageState();
}

class _SubscriptionPlanSelectionPreviewPageState
    extends PageState<SubscriptionPlanSelectionPreviewPage> {

  SubscriptionPlanSelectionPreviewModel get _model => context.read<SubscriptionPlanSelectionPreviewModel>();

  @override
  void initState() {
    super.initState();
    _model.init();
  }

  @override
  Widget build(BuildContext context) {
    final localeResource = LocaleResources.of(context);

    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(ComponentSize.large.r),
          child: const _PageTopBar(),
        ),
        body: _PageContent(
          localeResource: localeResource,
          onChangePlanButtonTap: _onChangeSubscriptionPlanButtonTap,
          onStartPurchaseFlowButtonTap: _onStartPurchaseFlowButtonTap,
        ),
      ),
    );
  }

  void _onChangeSubscriptionPlanButtonTap() async {
    final selectedPlan = await ChooseSubscriptionPlanBottomSheet.show(
      context,
      chosenSubscriptionPlanId: _model.selectedPlan!.id,
    );

    if (!mounted) return;
    if (selectedPlan == null) {
      return;
    }

    _model.updateSelectedPlan(selectedPlan);
  }

  void _onStartPurchaseFlowButtonTap() {
    final plan = _model.selectedPlan;
    if (plan!.name != _model.userPlan) {
      if (plan.name == "Free Plan") {
        ShowAlertBox.showAlertConfirmFreePlatformSubscription(context, onTapCancel: (){
          Navigator.of(context, rootNavigator: true).pop();
        }, onTapBuy: (){
          Navigator.of(context, rootNavigator: true).pop();
          _model.buySubscription(plan, context).then((value) {
            if (value) {
              Navigator.pop(context, true);
              showDefaultNotificationBar(
                NotificationBarInfo.success(
                    message:
                    "Congrats! You have successfully subscribed to ${plan.name}. "),
              );
            } else {
              Navigator.pop(context, false);
              showDefaultNotificationBar(
                const NotificationBarInfo.error(
                    message: "Oops, something went wrong."),
              );
            }
          });

        }, planName: plan.name??"", );
      } else if (_model.profileResult!.data().tokens! > int.parse(plan.token!)) {
        ShowAlertBox.showAlertConfirmPlatformSubscription(context,
            onTapCancel: () {
          Navigator.of(context, rootNavigator: true).pop();
        }, onTapBuy: () {
          _model.buySubscription(plan, context).then((value) {
            Navigator.of(context, rootNavigator: true).pop();
            if (value) {
              Navigator.pop(context, true);
              showDefaultNotificationBar(
                NotificationBarInfo.success(
                    message:
                        "Congrats! You have successfully subscribed to ${plan.name}. "),
              );
            } else {
              Navigator.pop(context, false);
              showDefaultNotificationBar(
                const NotificationBarInfo.error(
                    message: "Oops, something went wrong."),
              );
            }
          });
        }, planName: plan.name??"", tokens: plan.token ?? "", isFromAEvent: false);
      } else {
        ShowAlertBox.showAlertInsufficientKMBeats(context, onTapCancel: () {
          Navigator.of(context, rootNavigator: true).pop();
        }, onTapBuy: () {
          if (_model.billingDetailResult!.message != "Successful") {
            ShowAlertBox.showAlertForAddBillingDetails(context,
                onTapCancel: () {
              Navigator.of(context, rootNavigator: true).pop();
            }, onTapBuy: () {
              DashboardNavigation.pushNamed(context, Routes.addBillingDetails)
                  .then((value) {
                _model.fetchBillingDetail();
              });
              Navigator.of(context, rootNavigator: true).pop();
              Navigator.of(context, rootNavigator: true).pop();
            });
          } else {
            if(Platform.isIOS) {
              Navigator.pushNamed(context, Routes.myWalletPage).then((value) {
                _model.fetchProfile();
              });
            }else {
               UrlLauncherUtil.buyToken(context).then((value) {
                 _model.fetchProfile();
               });
            }
            Navigator.of(context, rootNavigator: true).pop();
          }
        });
      }
    } else {
      showDefaultNotificationBar(const NotificationBarInfo.error(
          message: "You are already subscribed to this plan."));
    }
  }
}

class _PageTopBar extends StatelessWidget {
  const _PageTopBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      AppIconButton(
          width: ComponentSize.large.r,
          height: ComponentSize.large.r,
          assetColor: DynamicTheme.get(context).neutral20(),
          assetPath: Assets.iconArrowLeft,
          padding: EdgeInsets.all(ComponentInset.small.r),
          onPressed: () => DashboardNavigation.pop(context)),
      const Spacer(),
    ]);
  }
}

class _PageContent extends StatelessWidget {
  const _PageContent({
    Key? key,
    required this.localeResource,
    required this.onChangePlanButtonTap,
    required this.onStartPurchaseFlowButtonTap,
  }) : super(key: key);

  final TextLocaleResource localeResource;
  final VoidCallback onChangePlanButtonTap;
  final VoidCallback onStartPurchaseFlowButtonTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _PageTitle(
              text: localeResource.subscriptionPlanConfirmationPageTitle),
          SizedBox(height: ComponentInset.normal.r),
          const _SelectedSubscriptionPlanWidget(),
          SizedBox(height: ComponentInset.medium.r),
          Button(
              height: ComponentSize.smaller.r,
              onPressed: onChangePlanButtonTap,
              text: localeResource.subscriptionChangePlan,
              type: ButtonType.text),
          SizedBox(height: ComponentInset.medium.r),
          _PageSubtitle(
              text: localeResource.subscriptionPlanConfirmationPageSubtitle),
          SizedBox(height: ComponentInset.normal.r),
          Button(
              width: double.infinity,
              height: ComponentSize.large.r,
              onPressed: onStartPurchaseFlowButtonTap,
              text: localeResource.getStarted,
              type: ButtonType.primary),
          SizedBox(height: ComponentInset.normal.r),
        ]),
      ),
    );
  }
}

class _PageTitle extends StatelessWidget {
  const _PageTitle({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyles.boldHeading2
            .copyWith(color: DynamicTheme.get(context).white()));
  }
}

class _PageSubtitle extends StatelessWidget {
  const _PageSubtitle({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyles.boldHeading3
            .copyWith(color: DynamicTheme.get(context).white()));
  }
}

class _SelectedSubscriptionPlanWidget extends StatelessWidget {
  const _SelectedSubscriptionPlanWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<SubscriptionPlanSelectionPreviewModel, SubscriptionPlan>(

        selector: (_, model) => model.selectedPlan!,
        builder: (_, plan, __) {
          return SubscriptionPlanWidget(plan: plan, onTap: null);
        });
  }
}
