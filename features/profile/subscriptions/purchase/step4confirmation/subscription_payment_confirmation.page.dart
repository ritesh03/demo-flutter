import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/gradient/foreground_gradient_photo.widget.dart';
import 'package:kwotmusic/components/widgets/page/page_state.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/profile/subscriptions/manage/manage_subscription.page.dart';
import 'package:kwotmusic/features/profile/subscriptions/purchase/step1preview/subscription_plan_selection_preview.model.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:provider/provider.dart';

import 'subscription_payment_confirmation.model.dart';

class SubscriptionPaymentConfirmationPage extends StatefulWidget {
  const SubscriptionPaymentConfirmationPage({Key? key}) : super(key: key);

  @override
  State<SubscriptionPaymentConfirmationPage> createState() =>
      _SubscriptionPaymentConfirmationPageState();
}

class _SubscriptionPaymentConfirmationPageState
    extends PageState<SubscriptionPaymentConfirmationPage> {
  //=
  SubscriptionPaymentConfirmationModel get _paymentConfirmationModel =>
      context.read<SubscriptionPaymentConfirmationModel>();

  @override
  void initState() {
    super.initState();
    _paymentConfirmationModel.init();
  }

  @override
  Widget build(BuildContext context) {
    final localeResource = LocaleResources.of(context);

    return WillPopScope(
      onWillPop: () => Future.sync(() => false),
      child: SafeArea(
        child: Scaffold(
          body: Stack(alignment: Alignment.bottomCenter, children: [
            ForegroundGradientPhoto(
                photoPath: Assets.backgroundCongrats,
                height: 0.6.sh,
                endColorShift: 0.8),
            Selector<SubscriptionPaymentConfirmationModel,
                    Result<SubscriptionOrder>>(
                selector: (_, model) => model.subscriptionOrderResult,
                builder: (_, result, __) {
                  if (!result.isSuccess() || result.isEmpty()) {
                    return _PaymentFailedWidget(
                      localeResource: localeResource,
                      onRetryButtonTap: _onRetryButtonTap,
                      onSupportButtonTap: _onSupportButtonTap,
                    );
                  }
                  final order = result.data();
                  final activation = order.subscriptionDetail.activation;
                  return _PaymentSuccessWidget(
                    localeResource: localeResource,
                    planRenewalDate: activation?.renewalDate,
                    onContinueButtonTap: _onContinueButtonTap,
                  );
                }),
          ]),
        ),
      ),
    );
  }

  void _onContinueButtonTap() {
    DashboardNavigation.pop(context);
  }

  void _onRetryButtonTap() {
    final plan = _paymentConfirmationModel.selectedPlan;
   /* DashboardNavigation.pushReplacementNamed(
      context,
      Routes.subscriptionPlanSelectionPreview,
      arguments: SubscriptionPlanSelectionPreviewArgs(selectedPlan: plan),
    );*/
  }

  void _onSupportButtonTap() {
    DashboardNavigation.pushReplacementNamed(context, Routes.help);
  }
}

class _PaymentSuccessWidget extends StatelessWidget {
  const _PaymentSuccessWidget({
    Key? key,
    required this.localeResource,
    required this.planRenewalDate,
    required this.onContinueButtonTap,
  }) : super(key: key);

  final TextLocaleResource localeResource;
  final DateTime? planRenewalDate;
  final VoidCallback onContinueButtonTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
      child: Column(children: [
        SizedBox(height: ComponentSize.large.r),
        SizedBox(height: ComponentSize.large.r),
        Text(localeResource.subscriptionSuccessfulPaymentTitle,
            textAlign: TextAlign.center,
            style: TextStyles.boldHeading2
                .copyWith(color: DynamicTheme.get(context).white())),
        if (planRenewalDate != null) SizedBox(height: ComponentInset.small.r),
        if (planRenewalDate != null)
          SubscriptionAutoRenewalDateWarning(
            date: planRenewalDate!,
            localeResource: localeResource,
            textAlign: TextAlign.center,
          ),
        SizedBox(height: ComponentInset.medium.r),
        Button(
            width: double.infinity,
            height: ComponentSize.large.r,
            onPressed: onContinueButtonTap,
            text: localeResource.continueButton,
            type: ButtonType.primary),
        SizedBox(height: ComponentInset.normal.r),
      ]),
    );
  }
}

class _PaymentFailedWidget extends StatelessWidget {
  const _PaymentFailedWidget({
    Key? key,
    required this.localeResource,
    required this.onRetryButtonTap,
    required this.onSupportButtonTap,
  }) : super(key: key);

  final TextLocaleResource localeResource;
  final VoidCallback onRetryButtonTap;
  final VoidCallback onSupportButtonTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(height: ComponentSize.large.r),
        SizedBox(height: ComponentSize.large.r),
        Text(localeResource.subscriptionFailedPaymentTitle,
            style: TextStyles.boldHeading2
                .copyWith(color: DynamicTheme.get(context).white())),
        SizedBox(height: ComponentInset.small.r),
        Text(localeResource.subscriptionFailedPaymentSummary,
            style: TextStyles.body
                .copyWith(color: DynamicTheme.get(context).neutral10())),
        SizedBox(height: ComponentInset.medium.r),
        Button(
            width: double.infinity,
            height: ComponentSize.large.r,
            onPressed: onRetryButtonTap,
            text: localeResource.retry,
            type: ButtonType.primary),
        SizedBox(height: ComponentInset.normal.r),
        Button(
            width: double.infinity,
            height: ComponentSize.large.r,
            onPressed: onSupportButtonTap,
            text: localeResource.support,
            type: ButtonType.secondary),
        SizedBox(height: ComponentInset.normal.r),
      ]),
    );
  }
}
