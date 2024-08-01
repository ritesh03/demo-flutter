import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/models/models.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/checkbox/checkbox.dart';
import 'package:kwotmusic/components/widgets/indicator/indicators.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';
import 'package:kwotmusic/features/dashboard/dashboard_config.dart';
import 'package:kwotmusic/features/profile/billingdetails/widget/billing_detail_list_item.widget.dart';
import 'package:kwotmusic/features/profile/subscriptions/widget/subscription_plan.widget.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/navigation/dashboard_navigation.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:provider/provider.dart';

import 'subscription_plan_purchase_process.model.dart';

/// Requires [SubscriptionPlanPurchaseProcessModel]
class SubscriptionPurchaseReviewStepFragment extends StatefulWidget {
  const SubscriptionPurchaseReviewStepFragment({
    Key? key,
    required this.onConfirmPaymentButtonTap,
  }) : super(key: key);

  final VoidCallback onConfirmPaymentButtonTap;

  @override
  State<SubscriptionPurchaseReviewStepFragment> createState() =>
      _SubscriptionPurchaseReviewStepFragmentState();
}

class _SubscriptionPurchaseReviewStepFragmentState
    extends State<SubscriptionPurchaseReviewStepFragment>
    implements _FragmentActionsListener {
  //=
  SubscriptionPlanPurchaseProcessModel get _purchaseProcessModel =>
      context.read<SubscriptionPlanPurchaseProcessModel>();

  @override
  Widget build(BuildContext context) {
    final localeResource = LocaleResources.of(context);
    final padding = EdgeInsets.symmetric(horizontal: ComponentInset.normal.r);

    return Selector<SubscriptionPlanPurchaseProcessModel,
            Result<SubscriptionPaymentDetail>?>(
        selector: (_, model) => model.paymentDetailResult,
        builder: (_, result, __) {
          if (result == null) {
            return const LoadingIndicator();
          }

          if (!result.isSuccess() || result.isEmpty()) {
            return ErrorIndicator(
              error: result.error(),
              onTryAgain: onReloadSubscriptionPaymentDetail,
            );
          }

          final paymentDetail = result.data();

          return SingleChildScrollView(
              padding: padding,
              child: _SubscriptionReviewWidget(
                listener: this,
                localeResource: localeResource,
                paymentDetail: paymentDetail,
              ));
        });
  }

  @override
  void onChangeBillingDetailsTap() {
    _purchaseProcessModel
        .moveToPurchaseStep(SubscriptionPlanPurchaseStep.billing);
  }

  @override
  void onChangePaymentDetailsTap() {
    _purchaseProcessModel
        .moveToPurchaseStep(SubscriptionPlanPurchaseStep.payment);
  }

  @override
  void onToggleAgreementAcceptanceTap() {
    _purchaseProcessModel.toggleAgreementAcceptance();
  }

  @override
  void onSupportButtonTap() {
    DashboardNavigation.pushNamed(context, Routes.help);
  }

  @override
  void onReloadSubscriptionPaymentDetail() {
    _purchaseProcessModel.fetchSubscriptionPaymentDetail();
  }

  @override
  void onConfirmPaymentButtonTap() {
    widget.onConfirmPaymentButtonTap();
  }
}

abstract class _FragmentActionsListener {
  void onChangeBillingDetailsTap();

  void onChangePaymentDetailsTap();

  void onToggleAgreementAcceptanceTap();

  void onSupportButtonTap();

  void onReloadSubscriptionPaymentDetail();

  void onConfirmPaymentButtonTap();
}

class _SubscriptionReviewWidget extends StatelessWidget {
  const _SubscriptionReviewWidget({
    Key? key,
    required this.listener,
    required this.localeResource,
    required this.paymentDetail,
  }) : super(key: key);

  final _FragmentActionsListener listener;
  final TextLocaleResource localeResource;
  final SubscriptionPaymentDetail paymentDetail;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(localeResource.reviewYourDetails,
          style: TextStyles.boldHeading2
              .copyWith(color: DynamicTheme.get(context).white())),
      SizedBox(height: ComponentInset.medium.r),

      // BILLING DETAILS
      _SectionHeadingBar(
          title: localeResource.billingDetails,
          actionButtonText: localeResource.change,
          onActionButtonTap: listener.onChangeBillingDetailsTap),
      SizedBox(height: ComponentInset.small.r),
      BillingDetailListItem(
        billingDetail: paymentDetail.billingDetail,
        onTap: null,
        onEditTap: null,
      ),
      SizedBox(height: ComponentInset.large.r),

      // PAYMENT METHOD
      _SectionHeadingBar(
          title: localeResource.payment,
          actionButtonText: localeResource.change,
          onActionButtonTap: listener.onChangePaymentDetailsTap),
      SizedBox(height: ComponentInset.small.r),
      _SelectedSubscriptionPaymentMethodWidget(
        billingDetail: paymentDetail.billingDetail,
        paymentMethod: paymentDetail.paymentMethod,
      ),
      SizedBox(height: ComponentInset.large.r),

      // SUBSCRIPTION PLAN
      _SectionHeading(text: localeResource.subscriptionPlanCompact),
      SizedBox(height: ComponentInset.small.r),
     // SubscriptionPlanWidget(plan: paymentDetail.plan, onTap: null),
      SizedBox(height: ComponentInset.large.r),

      // TERMS AND CONDITIONS
      _PurchaseConditionsAgreementCheckBox(
          text: localeResource.subscriptionPurchaseConditionsAgreement,
          onToggleTap: listener.onToggleAgreementAcceptanceTap),
      SizedBox(height: ComponentInset.normal.r),

      // SUPPORT BUTTON
      Button(
          width: double.infinity,
          height: ComponentSize.large.r,
          onPressed: listener.onSupportButtonTap,
          text: localeResource.support,
          type: ButtonType.secondary),
      SizedBox(height: ComponentInset.large.r),

      // PAYMENT DETAIL
      _SubscriptionPaymentDetailWidget(
        localeResource: localeResource,
        paymentDetail: paymentDetail,
      ),
      SizedBox(height: ComponentInset.normal.r),

      // CHECKOUT BUTTON
      _CheckoutButton(
          text: localeResource.confirmPayment,
          onTap: listener.onConfirmPaymentButtonTap),

      SizedBox(height: ComponentInset.normal.r),
      const DashboardConfigAwareFooter(),
    ]);
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.boldHeading3
            .copyWith(color: DynamicTheme.get(context).white()));
  }
}

class _SectionHeadingBar extends StatelessWidget {
  const _SectionHeadingBar({
    Key? key,
    required this.title,
    required this.actionButtonText,
    required this.onActionButtonTap,
  }) : super(key: key);

  final String title;
  final String actionButtonText;
  final VoidCallback onActionButtonTap;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: _SectionHeading(text: title)),
      Button(
          height: ComponentSize.smaller.r,
          onPressed: onActionButtonTap,
          text: actionButtonText,
          type: ButtonType.text),
      SizedBox(width: ComponentInset.small.r),
    ]);
  }
}

class _SelectedSubscriptionPaymentMethodWidget extends StatelessWidget {
  const _SelectedSubscriptionPaymentMethodWidget({
    Key? key,
    required this.billingDetail,
    required this.paymentMethod,
  }) : super(key: key);

  final BillingDetail billingDetail;
  final SubscriptionPaymentMethod paymentMethod;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: ComponentSize.large.r,
        decoration: BoxDecoration(
          color: DynamicTheme.get(context).black(),
          borderRadius: BorderRadius.circular(ComponentRadius.normal.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
        child: Row(children: [
          Photo(
            paymentMethod.logo,
            options: PhotoOptions(
              width: ComponentSize.small.r,
              height: ComponentSize.small.r,
              borderRadius: BorderRadius.circular(ComponentRadius.small.r),
            ),
          ),
          SizedBox(width: ComponentInset.normal.r),
          Text(
            billingDetail.name,
            style: TextStyles.boldBody.copyWith(
              color: DynamicTheme.get(context).white(),
            ),
          ),
        ]));
  }
}

class _PurchaseConditionsAgreementCheckBox extends StatelessWidget {
  const _PurchaseConditionsAgreementCheckBox({
    Key? key,
    required this.text,
    required this.onToggleTap,
  }) : super(key: key);

  final String text;
  final VoidCallback onToggleTap;

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Selector<SubscriptionPlanPurchaseProcessModel, bool>(
          selector: (_, model) => model.hasAgreedToPurchaseConditions,
          builder: (_, hasAgreedToPurchaseConditions, __) {
            return KCheckBox(
              checked: hasAgreedToPurchaseConditions,
              onTap: onToggleTap,
            );
          }),
      SizedBox(width: ComponentInset.small.r),
      Expanded(
        child: Text(text,
            style: TextStyles.body
                .copyWith(color: DynamicTheme.get(context).white())),
      ),
    ]);
  }
}

class _CheckoutButton extends StatelessWidget {
  const _CheckoutButton({
    Key? key,
    required this.text,
    required this.onTap,
  }) : super(key: key);

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Selector<SubscriptionPlanPurchaseProcessModel, bool>(
        selector: (_, model) => model.canCheckout,
        builder: (_, canCheckout, __) {
          return Button(
            width: double.infinity,
            height: ComponentSize.large.r,
            visuallyDisabled: !canCheckout,
            onPressed: onTap,
            text: text,
            type: ButtonType.primary,
          );
        });
  }
}

class _SubscriptionPaymentDetailWidget extends StatelessWidget {
  const _SubscriptionPaymentDetailWidget({
    Key? key,
    required this.localeResource,
    required this.paymentDetail,
  }) : super(key: key);

  final TextLocaleResource localeResource;
  final SubscriptionPaymentDetail paymentDetail;

  @override
  Widget build(BuildContext context) {
    final currency = paymentDetail.plan.payment!.currency;
    return Container(
      decoration: BoxDecoration(
        color: DynamicTheme.get(context).black(),
        borderRadius: BorderRadius.circular(ComponentRadius.normal.r),
      ),
      padding: EdgeInsets.all(ComponentInset.normal.r),
      child: Column(children: [
        for (final paymentEntry in paymentDetail.paymentEntries) ...{
          _PaymentDetailEntryWidget(
            title: paymentEntry.title,
            displayPrice: currency.displayPrice(paymentEntry.price),
          ),
          SizedBox(height: ComponentInset.large.r),
        },
        _PaymentDetailTotalEntryWidget(
          displayPrice: currency.displayPrice(paymentDetail.totalPrice),
          localeResource: localeResource,
        ),
      ]),
    );
  }
}

class _PaymentDetailEntryWidget extends StatelessWidget {
  const _PaymentDetailEntryWidget({
    Key? key,
    required this.title,
    required this.displayPrice,
  }) : super(key: key);

  final String title;
  final String displayPrice;

  @override
  Widget build(BuildContext context) {
    final textColor = DynamicTheme.get(context).white();
    return Row(children: [
      Expanded(
        child: Text(
          title,
          style: TextStyles.heading4.copyWith(color: textColor),
        ),
      ),
      Text(
        displayPrice,
        style: TextStyles.robotoBoldHeading4.copyWith(color: textColor),
      )
    ]);
  }
}

class _PaymentDetailTotalEntryWidget extends StatelessWidget {
  const _PaymentDetailTotalEntryWidget({
    Key? key,
    required this.displayPrice,
    required this.localeResource,
  }) : super(key: key);

  final String displayPrice;
  final TextLocaleResource localeResource;

  @override
  Widget build(BuildContext context) {
    final localeResource = LocaleResources.of(context);
    final textColor = DynamicTheme.get(context).white();
    return Row(children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(localeResource.totalCaps,
              style: TextStyles.boldHeading4.copyWith(color: textColor)),
          Text(localeResource.taxesIncludedWhenApplicable,
              style: TextStyles.heading6
                  .copyWith(color: DynamicTheme.get(context).neutral10())),
        ]),
      ),
      Text(displayPrice,
          style: TextStyles.robotoBoldHeading4.copyWith(color: textColor))
    ]);
  }
}
