import 'dart:async';

import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/blocking_progress.dialog.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/notificationbar/notification_bar.dart';
import 'package:kwotmusic/components/widgets/page/page_state.dart';
import 'package:kwotmusic/components/widgets/segmented_control_tabs.widget.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/profile/billingdetails/billing_details.model.dart';
import 'package:kwotmusic/features/profile/subscriptions/paymentmethod/subscription_payment_methods.model.dart';
import 'package:kwotmusic/features/profile/subscriptions/purchase/step3payment/subscription_payment.model.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:provider/provider.dart';

import 'subscription_plan_purchase_process.model.dart';
import 'subscription_purchase_billing_step.fragment.dart';
import 'subscription_purchase_payment_step.fragment.dart';
import 'subscription_purchase_review_step.fragment.dart';

class SubscriptionPlanPurchaseProcessPage extends StatefulWidget {
  const SubscriptionPlanPurchaseProcessPage({Key? key}) : super(key: key);

  @override
  State<SubscriptionPlanPurchaseProcessPage> createState() =>
      _SubscriptionPlanPurchaseProcessPageState();
}

class _SubscriptionPlanPurchaseProcessPageState
    extends PageState<SubscriptionPlanPurchaseProcessPage>
    with SingleTickerProviderStateMixin {
  //=

  late final TabController _purchaseStepTabController;
  late final PageController _pageController;
  late final StreamSubscription _purchaseStepSubscription;

  SubscriptionPlanPurchaseProcessModel get _purchaseProcessModel =>
      context.read<SubscriptionPlanPurchaseProcessModel>();

  BillingDetailsModel get _billingDetailModel =>
      context.read<BillingDetailsModel>();

  SubscriptionPaymentMethodsModel get _paymentMethodsModel =>
      context.read<SubscriptionPaymentMethodsModel>();

  @override
  void initState() {
    super.initState();

    _purchaseStepTabController = TabController(
      length: SubscriptionPlanPurchaseStep.values.length,
      vsync: this,
    );

    _pageController = PageController();

    _purchaseProcessModel.init();
    _purchaseStepSubscription =
        _purchaseProcessModel.purchaseStepStream.listen(_onPurchaseStepUpdated);

    _billingDetailModel.init();
    _paymentMethodsModel.init();
  }

  @override
  Widget build(BuildContext context) {
    final edgeInsets = EdgeInsets.symmetric(horizontal: ComponentInset.normal.r);
    final localeResource = LocaleResources.of(context);

    return WillPopScope(
      onWillPop: () {
        return Future.sync(() => !_purchaseProcessModel.handleBackNavigation());
      },
      child: SafeArea(
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(
              // _PageTopBar
              ComponentSize.large.r +
                  // SizedBox
                  ComponentInset.small.r +
                  // _SubscriptionPlanPurchaseStepBar
                  ComponentSize.normal.r +
                  // SizedBox
                  ComponentInset.normal.r,
            ),
            child: Column(children: [
              _PageTopBar(onBackTap: _onBackTap),
              SizedBox(height: ComponentInset.small.r),
              _SubscriptionPlanPurchaseStepBar(
                controller: _purchaseStepTabController,
                height: ComponentSize.normal.r,
                localeResource: localeResource,
                margin: edgeInsets,
              ),
              SizedBox(height: ComponentInset.normal.r),
            ]),
          ),
          body: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                const _SubscriptionPlanPurchaseBillingStep(),
                const _SubscriptionPlanPurchasePaymentStep(),
                SubscriptionPurchaseReviewStepFragment(
                  onConfirmPaymentButtonTap: () =>
                      _onConfirmPaymentButtonTap(localeResource),
                ),
              ]),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _purchaseStepSubscription.cancel();
    super.dispose();
  }

  void _onBackTap() {
    final handled = _purchaseProcessModel.handleBackNavigation();
    if (handled) return;

    DashboardNavigation.pop(context);
  }

  void _onPurchaseStepUpdated(SubscriptionPlanPurchaseStep purchaseStep) {
    _purchaseStepTabController.animateTo(purchaseStep.position);
    _pageController.animateToPage(
      purchaseStep.position,
      duration: const Duration(milliseconds: 200),
      curve: Curves.fastOutSlowIn,
    );
  }

  void _onConfirmPaymentButtonTap(TextLocaleResource localeResource) async {
    showBlockingProgressDialog(context);
    final result = await _purchaseProcessModel.initiatePayment(localeResource);

    if (!mounted) return;
    hideBlockingProgressDialog(context);

    if (!result.isSuccess() || result.isEmpty()) {
      showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()));
      return;
    }

    final temporarySubscriptionOrder = result.data();
    DashboardNavigation.pushReplacementNamed(
      context,
      Routes.subscriptionPlanPayment,
      arguments: SubscriptionPaymentArgs(
        billingDetail: _purchaseProcessModel.selectedBillingDetail!,
        paymentMethod: _purchaseProcessModel.selectedPaymentMethod!,
        plan: _purchaseProcessModel.selectedPlan,
        order: temporarySubscriptionOrder,
      ),
    );
  }
}

class _PageTopBar extends StatelessWidget {
  const _PageTopBar({
    Key? key,
    required this.onBackTap,
  }) : super(key: key);

  final VoidCallback onBackTap;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      AppIconButton(
          width: ComponentSize.large.r,
          height: ComponentSize.large.r,
          assetColor: DynamicTheme.get(context).neutral20(),
          assetPath: Assets.iconArrowLeft,
          padding: EdgeInsets.all(ComponentInset.small.r),
          onPressed: onBackTap),
      const Spacer(),
    ]);
  }
}

class _SubscriptionPlanPurchaseStepBar extends StatelessWidget {
  const _SubscriptionPlanPurchaseStepBar({
    Key? key,
    required this.controller,
    required this.height,
    required this.localeResource,
    required this.margin,
  }) : super(key: key);

  final TabController controller;
  final double height;
  final EdgeInsets margin;
  final TextLocaleResource localeResource;

  @override
  Widget build(BuildContext context) {
    return ControlledSegmentedControlTabBar<SubscriptionPlanPurchaseStep>(
        controller: controller,
        height: height,
        items: SubscriptionPlanPurchaseStep.values,
        margin: margin,
        itemTitle: (purchaseStep) {
          switch (purchaseStep) {
            case SubscriptionPlanPurchaseStep.billing:
              return localeResource.subscriptionPurchaseStepBilling;
            case SubscriptionPlanPurchaseStep.payment:
              return localeResource.subscriptionPurchaseStepPayment;
            case SubscriptionPlanPurchaseStep.review:
              return localeResource.subscriptionPurchaseStepReview;
          }
        });
  }
}

class _SubscriptionPlanPurchaseBillingStep extends StatelessWidget {
  const _SubscriptionPlanPurchaseBillingStep({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
      child: SubscriptionPurchaseBillingStepFragment(
        onBillingDetailTap: (billingDetail) {
          context
              .read<SubscriptionPlanPurchaseProcessModel>()
              .onBillingDetailSelected(billingDetail);
        },
      ),
    );
  }
}

class _SubscriptionPlanPurchasePaymentStep extends StatelessWidget {
  const _SubscriptionPlanPurchasePaymentStep({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SubscriptionPurchasePaymentStepFragment(
      onPaymentMethodTap: (paymentMethod) {
        context
            .read<SubscriptionPlanPurchaseProcessModel>()
            .onPaymentMethodSelected(paymentMethod);
      },
    );
  }
}
