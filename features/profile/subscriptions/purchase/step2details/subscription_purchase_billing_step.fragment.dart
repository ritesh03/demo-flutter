import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/models/models.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/blocking_progress.dialog.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/indicator/indicators.dart';
import 'package:kwotmusic/components/widgets/notificationbar/notification_bar.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/profile/billingdetails/addedit/addedit_billing_details.model.dart';
import 'package:kwotmusic/features/profile/billingdetails/billing_details.model.dart';
import 'package:kwotmusic/features/profile/billingdetails/delete/delete_billing_details_confirmation.bottomsheet.dart';
import 'package:kwotmusic/features/profile/billingdetails/widget/billing_detail_list_item.widget.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:provider/provider.dart';

/// Requires [BillingDetailsModel]
class SubscriptionPurchaseBillingStepFragment extends StatefulWidget {
  const SubscriptionPurchaseBillingStepFragment({
    Key? key,
    required this.onBillingDetailTap,
  }) : super(key: key);

  final Function(BillingDetail) onBillingDetailTap;

  @override
  State<SubscriptionPurchaseBillingStepFragment> createState() =>
      _SubscriptionPurchaseBillingStepFragmentState();
}

class _SubscriptionPurchaseBillingStepFragmentState
    extends State<SubscriptionPurchaseBillingStepFragment> {
  //=
  BillingDetailsModel get _billingDetailsModel =>
      context.read<BillingDetailsModel>();

  @override
  Widget build(BuildContext context) {
    final localeResource = LocaleResources.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(localeResource.chooseBillingDetails,
          style: TextStyles.boldHeading2
              .copyWith(color: DynamicTheme.get(context).white())),
      SizedBox(height: ComponentInset.normal.r),
      _BillingDetailWidget(
        localeResource: localeResource,
        onAddTap: _onAddBillingDetailTap,
        onDeleteTap: _onDeleteBillingDetailTap,
        onEditTap: _onEditBillingDetailTap,
        onTap: _onBillingDetailTap,
      ),
    ]);
  }

  void _onAddBillingDetailTap() async {
    final added = await DashboardNavigation.pushNamed(
      context,
      Routes.addBillingDetails,
    );

    if (!mounted) return;
    if (added != null && added is bool) {
      _billingDetailsModel.fetchBillingDetail();
    }
  }

  void _onDeleteBillingDetailTap() async {
    final billingDetail = _billingDetailsModel.billingDetailResult?.peek();
    if (billingDetail == null) return;

    bool? shouldDelete =
        await DeleteBillingDetailsConfirmationBottomSheet.show(context);
    if (shouldDelete == null || !shouldDelete) {
      return;
    }

    // show processing dialog
    if (!mounted) return;
    showBlockingProgressDialog(context);

    // delete billing details
    final result =
        await _billingDetailsModel.deleteBillingDetail(id: billingDetail.id);

    // hide dialog
    if (!mounted) return;
    hideBlockingProgressDialog(context);

    if (!result.isSuccess()) {
      showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()));
      return;
    }

    showDefaultNotificationBar(
        NotificationBarInfo.success(message: result.message));
  }

  void _onEditBillingDetailTap() async {
    final billingDetail = _billingDetailsModel.billingDetailResult?.peek();
    if (billingDetail == null) return;

    final updated = await DashboardNavigation.pushNamed(
      context,
      Routes.editBillingDetails,
      arguments: EditBillingDetailsArgs(billingDetail: billingDetail),
    );

    if (!mounted) return;
    if (updated != null && updated is bool) {
      _billingDetailsModel.fetchBillingDetail();
    }
  }

  void _onBillingDetailTap() {
    final billingDetail = _billingDetailsModel.billingDetailResult?.peek();
    if (billingDetail == null) return;

    widget.onBillingDetailTap(billingDetail);
  }
}

class _BillingDetailWidget extends StatelessWidget {
  const _BillingDetailWidget({
    Key? key,
    required this.localeResource,
    required this.onAddTap,
    required this.onDeleteTap,
    required this.onEditTap,
    required this.onTap,
  }) : super(key: key);

  final TextLocaleResource localeResource;
  final VoidCallback onAddTap;
  final VoidCallback onDeleteTap;
  final VoidCallback onEditTap;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Selector<BillingDetailsModel, Result<BillingDetail>?>(
        selector: (_, model) => model.billingDetailResult,
        builder: (_, result, __) {
          if (result == null) {
            return Padding(
              padding: EdgeInsets.only(top: 80.r),
              child: const LoadingIndicator(),
            );
          }

          if (!result.isSuccess()) {
            return Center(
              child: ErrorIndicator(
                  error: result.error(),
                  padding: EdgeInsets.only(top: 80.r),
                  onTryAgain:
                      context.read<BillingDetailsModel>().fetchBillingDetail),
            );
          }

          if (result.isEmpty()) {
            return _EmptyBillingDetailWidget(
              localeResource: localeResource,
              onAddBillingDetailsButtonTap: onAddTap,
            );
          }

          final billingDetail = result.data();
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BillingDetailListItem(
                  billingDetail: billingDetail,
                  onTap: onTap,
                  onEditTap: onEditTap,
                ),
                SizedBox(height: ComponentInset.normal.r),
                AppIconTextButton(
                    color: DynamicTheme.get(context).neutral10(),
                    height: ComponentSize.smaller.h,
                    iconPath: Assets.iconDelete,
                    iconTextSpacing: ComponentInset.smaller.w,
                    text: LocaleResources.of(context).deleteBillingDetails,
                    textStyle: TextStyles.boldHeading5,
                    onPressed: onDeleteTap),
              ]);
        });
  }
}

class _EmptyBillingDetailWidget extends StatelessWidget {
  const _EmptyBillingDetailWidget({
    Key? key,
    required this.localeResource,
    required this.onAddBillingDetailsButtonTap,
  }) : super(key: key);

  final TextLocaleResource localeResource;
  final VoidCallback onAddBillingDetailsButtonTap;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      SizedBox(height: ComponentInset.larger.r),
      Text(localeResource.billingDetailsEmptyTitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyles.boldHeading3
              .copyWith(color: DynamicTheme.get(context).white())),
      SizedBox(height: ComponentInset.small.r),
      Text(localeResource.billingDetailsEmptySubtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyles.body
              .copyWith(color: DynamicTheme.get(context).neutral10())),
      SizedBox(height: ComponentInset.normal.h),
      Button(
          text: localeResource.addBillingDetails,
          height: ComponentSize.large.r,
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
          onPressed: onAddBillingDetailsButtonTap),
    ]);
  }
}
