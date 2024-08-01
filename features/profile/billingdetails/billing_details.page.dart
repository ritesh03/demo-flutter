import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/blocking_progress.dialog.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/gradient/foreground_gradient_photo.widget.dart';
import 'package:kwotmusic/components/widgets/indicator/indicators.dart';
import 'package:kwotmusic/components/widgets/notificationbar/notification_bar.dart';
import 'package:kwotmusic/components/widgets/page/page_state.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/profile/billingdetails/addedit/addedit_billing_details.model.dart';
import 'package:kwotmusic/features/profile/billingdetails/billing_details.model.dart';
import 'package:kwotmusic/features/profile/billingdetails/delete/delete_billing_details_confirmation.bottomsheet.dart';
import 'package:kwotmusic/features/profile/billingdetails/widget/billing_detail_list_item.widget.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:provider/provider.dart';

class BillingDetailsPage extends StatefulWidget {
  const BillingDetailsPage({Key? key}) : super(key: key);

  @override
  State<BillingDetailsPage> createState() => _BillingDetailsPageState();
}

class _BillingDetailsPageState extends PageState<BillingDetailsPage> {
  //=

  @override
  void initState() {
    super.initState();
    billingDetailsModelOf(context).init();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: PreferredSize(
                preferredSize: Size.fromHeight(ComponentSize.large.h),
                child: _buildAppBar()),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitle(),
                SizedBox(height: ComponentInset.medium.h),
                Expanded(child: _buildContent())
              ],
            )));
  }

  /*
   * APP BAR
   */

  Widget _buildAppBar() {
    return Row(children: [
      AppIconButton(
          width: ComponentSize.large.r,
          height: ComponentSize.large.r,
          assetColor: DynamicTheme.get(context).neutral20(),
          assetPath: Assets.iconArrowLeft,
          padding: EdgeInsets.all(ComponentInset.small.r),
          onPressed: () => DashboardNavigation.pop(context)),
    ]);
  }

  /*
   * TITLE
   */

  Widget _buildTitle() {
    return Container(
        height: ComponentSize.small.h,
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
        child: Text(
          LocaleResources.of(context).billingDetails,
          style: TextStyles.boldHeading2
              .copyWith(color: DynamicTheme.get(context).white()),
        ));
  }

  Widget _buildContent() {
    return Selector<BillingDetailsModel, Result<BillingDetail>?>(
        selector: (_, model) => model.billingDetailResult,
        builder: (_, result, __) {
          if (result == null) {
            return const LoadingIndicator();
          }

          if (!result.isSuccess()) {
            return ErrorIndicator(
              error: result.error(),
              onTryAgain: billingDetailsModelOf(context).fetchBillingDetail,
            );
          }

          if (result.isEmpty()) {
            return _EmptyBillingDetailWidget(
              onAddBillingDetailsButtonTap: _onAddBillingDetailsButtonTapped,
            );
          }

          final billingDetail = result.data();
          return _BillingDetailWidget(
            billingDetail: billingDetail,
            onDeleteTap: () => _onDeleteBillingDetailTap(billingDetail),
            onEditTap: () => _onEditBillingDetailTap(billingDetail),
            onTap: () => _onBillingDetailTap(billingDetail),
            padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
          );
        });
  }

  BillingDetailsModel billingDetailsModelOf(BuildContext context) {
    return context.read<BillingDetailsModel>();
  }

  void _onAddBillingDetailsButtonTapped() async {
    final added = await DashboardNavigation.pushNamed(
      context,
      Routes.addBillingDetails,
    );

    if (!mounted) return;
    if (added != null && added is bool) {
      billingDetailsModelOf(context).fetchBillingDetail();
    }
  }

  void _onBillingDetailTap(BillingDetail billingDetail) {}

  void _onEditBillingDetailTap(BillingDetail billingDetail) async {
    final updated = await DashboardNavigation.pushNamed(
      context,
      Routes.editBillingDetails,
      arguments: EditBillingDetailsArgs(billingDetail: billingDetail),
    );

    if (!mounted) return;
    if (updated != null && updated is bool) {
      billingDetailsModelOf(context).fetchBillingDetail();
    }
  }

  void _onDeleteBillingDetailTap(BillingDetail billingDetail) async {
    bool? shouldDelete =
        await DeleteBillingDetailsConfirmationBottomSheet.show(context);
    if (shouldDelete == null || !shouldDelete) {
      return;
    }

    // show processing dialog
    if (!mounted) return;
    showBlockingProgressDialog(context);

    // delete billing details
    final result = await billingDetailsModelOf(context)
        .deleteBillingDetail(id: billingDetail.id);

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
}

class _BillingDetailWidget extends StatelessWidget {
  const _BillingDetailWidget({
    Key? key,
    required this.billingDetail,
    required this.onTap,
    required this.onEditTap,
    required this.onDeleteTap,
    required this.padding,
  }) : super(key: key);

  final BillingDetail billingDetail;
  final VoidCallback onTap;
  final VoidCallback onEditTap;
  final VoidCallback onDeleteTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: padding,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          BillingDetailListItem(
            billingDetail: billingDetail,
            onTap: onTap,
            onEditTap: onEditTap,
          ),
          SizedBox(height: ComponentInset.normal.h),
          AppIconTextButton(
              color: DynamicTheme.get(context).neutral10(),
              height: ComponentSize.smaller.h,
              iconPath: Assets.iconDelete,
              iconTextSpacing: ComponentInset.smaller.w,
              text: LocaleResources.of(context).deleteBillingDetails,
              textStyle: TextStyles.boldHeading5,
              onPressed: onDeleteTap),
        ]));
  }
}

class _EmptyBillingDetailWidget extends StatelessWidget {
  const _EmptyBillingDetailWidget({
    Key? key,
    required this.onAddBillingDetailsButtonTap,
  }) : super(key: key);

  final VoidCallback onAddBillingDetailsButtonTap;

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.bottomCenter, children: [
      ForegroundGradientPhoto(
          photoPath: Assets.backgroundEmptyState, height: 0.4.sh),
      Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        SizedBox(height: 48.h),
        Text(LocaleResources.of(context).billingDetailsEmptyTitle,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: TextStyles.boldHeading2
                .copyWith(color: DynamicTheme.get(context).white())),
        SizedBox(height: ComponentInset.small.h),
        Text(LocaleResources.of(context).billingDetailsEmptySubtitle,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: TextStyles.body
                .copyWith(color: DynamicTheme.get(context).neutral10())),
        SizedBox(height: ComponentInset.normal.h),
        Button(
            text: LocaleResources.of(context).addBillingDetails,
            height: ComponentSize.large.h,
            width: 1.sw,
            margin: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
            onPressed: onAddBillingDetailsButtonTap),
      ]),
    ]);
  }
}
