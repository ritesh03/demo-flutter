import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/gradient/foreground_gradient_photo.widget.dart';
import 'package:kwotmusic/components/widgets/list/item_list.widget.dart';
import 'package:kwotmusic/components/widgets/page/page_state.dart';
import 'package:kwotmusic/components/widgets/page/title/page_title_bar_text.widget.dart';
import 'package:kwotmusic/components/widgets/page/title/page_title_bar_wrapper.dart';
import 'package:kwotmusic/components/widgets/textfield.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/dashboard/dashboard_config.dart';
import 'package:kwotmusic/features/dashboard/widget/titlebar/dashboard_title.widgets.dart';
import 'package:kwotmusic/features/profile/paymenthistory/widget/payment_transaction_list_item.widget.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/util/util.dart';
import 'package:provider/provider.dart';

import 'payment_history.model.dart';

class PaymentHistoryPage extends StatefulWidget {
  const PaymentHistoryPage({Key? key}) : super(key: key);

  @override
  State<PaymentHistoryPage> createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends PageState<PaymentHistoryPage> {
  //=
  late FocusNode _searchInputFocusNode;
  late ScrollController _scrollController;

  PaymentHistoryModel get _model => context.read<PaymentHistoryModel>();

  @override
  void initState() {
    super.initState();
    _searchInputFocusNode = FocusNode();
    _scrollController = ScrollController();

    _model.init();
  }

  @override
  Widget build(BuildContext context) {
    final localeResource = LocaleResources.of(context);
    return SafeArea(
      child: Scaffold(
        body: PageTitleBarWrapper(
          barHeight: ComponentSize.large.r,
          title: PageTitleBarText(
              text: localeResource.paymentHistory,
              color: DynamicTheme.get(context).white(),
              onTap: _onTitleTap),
          actions: [
            DashboardPageTitleAction(
                asset: Assets.iconSearch,
                color: DynamicTheme.get(context).neutral20(),
                onTap: _onSearchIconTap),
          ],
          child: _ItemList(
            controller: _scrollController,
            header: _ItemListHeader(
              localeResource: localeResource,
              searchInputFocusNode: _searchInputFocusNode,
            ),
            localeResource: localeResource,
            onDownloadInvoiceTap: _onDownloadInvoiceTap,
            onTransactionTap: _onPaymentTransactionTap,
          ),
        ),
      ),
    );
  }

  void _onTitleTap() {
    _scrollController.animateToTop();
  }

  void _onSearchIconTap() {
    _scrollController.animateToTop().then((_) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        FocusScope.of(context).requestFocus(_searchInputFocusNode);
      });
    });
  }

  void _onPaymentTransactionTap(PaymentTransaction paymentTransaction) {}

  void _onDownloadInvoiceTap(PaymentTransaction paymentTransaction) {}
}

class _ItemListHeader extends StatelessWidget {
  const _ItemListHeader({
    Key? key,
    required this.localeResource,
    required this.searchInputFocusNode,
  }) : super(key: key);

  final TextLocaleResource localeResource;
  final FocusNode searchInputFocusNode;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // TOP BAR: BACK BUTTON
      Row(children: [
        AppIconButton(
            width: ComponentSize.large.r,
            height: ComponentSize.large.r,
            assetColor: DynamicTheme.get(context).neutral20(),
            assetPath: Assets.iconArrowLeft,
            padding: EdgeInsets.all(ComponentInset.small.r),
            onPressed: () => DashboardNavigation.pop(context)),
      ]),

      // TITLE BAR
      Padding(
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
        child: Text(localeResource.paymentHistory,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyles.boldHeading2
                .copyWith(color: DynamicTheme.get(context).white())),
      ),
      SizedBox(height: ComponentInset.medium.r),

      // SEARCH BAR
      Padding(
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
        child: _PageSearchBar(
          focusNode: searchInputFocusNode,
          localeResource: localeResource,
        ),
      ),
      SizedBox(height: ComponentInset.normal.r),
    ]);
  }
}

class _PageSearchBar extends StatelessWidget {
  const _PageSearchBar({
    Key? key,
    required this.focusNode,
    required this.localeResource,
  }) : super(key: key);

  final FocusNode focusNode;
  final TextLocaleResource localeResource;

  @override
  Widget build(BuildContext context) {
    return Selector<PaymentHistoryModel, bool>(
      selector: (_, model) => model.isPaymentHistoryEmpty,
      builder: (_, isPaymentHistoryEmpty, __) {
        if (isPaymentHistoryEmpty) return const SizedBox.shrink();
        return SearchBar(
          focusNode: focusNode,
          hintText: localeResource.paymentHistorySearchHint,
          onQueryChanged: context.read<PaymentHistoryModel>().updateSearchQuery,
          onQueryCleared: context.read<PaymentHistoryModel>().clearSearchQuery,
        );
      },
    );
  }
}

class _ItemList extends StatelessWidget {
  const _ItemList({
    Key? key,
    required this.controller,
    required this.header,
    required this.localeResource,
    required this.onTransactionTap,
    required this.onDownloadInvoiceTap,
  }) : super(key: key);

  final ScrollController controller;
  final Widget header;
  final TextLocaleResource localeResource;
  final Function(PaymentTransaction) onTransactionTap;
  final Function(PaymentTransaction) onDownloadInvoiceTap;

  @override
  Widget build(BuildContext context) {
    return Selector<PaymentHistoryModel, bool>(
        selector: (_, model) => model.isPaymentHistoryEmpty,
        builder: (_, hasNoPaymentTransactions, __) {
          if (hasNoPaymentTransactions) {
            return _NoPaymentHistoryPage(header: header);
          }

          return ItemListWidget<PaymentTransaction, PaymentHistoryModel>(
              controller: controller,
              headerSlivers: [SliverToBoxAdapter(child: header)],
              footerSlivers: [DashboardConfigAwareFooter.asSliver()],
              itemBuilder: (context, transaction, index) {
                return PaymentTransactionListItem(
                  transaction: transaction,
                  onTap: () => onTransactionTap(transaction),
                  onDownloadInvoiceTap: () => onDownloadInvoiceTap(transaction),
                );
              });
        });
  }
}

class _NoPaymentHistoryPage extends StatelessWidget {
  const _NoPaymentHistoryPage({
    Key? key,
    required this.header,
  }) : super(key: key);

  final Widget header;

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.bottomCenter, children: [
      ForegroundGradientPhoto(
        photoPath: Assets.backgroundEmptyState,
        height: 0.4.sh,
      ),
      Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        header,
        SizedBox(height: 48.h),
        Text(LocaleResources.of(context).paymentHistoryEmptyTitle,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: TextStyles.boldHeading2
                .copyWith(color: DynamicTheme.get(context).white())),
        SizedBox(height: ComponentInset.small.h),
        Text(LocaleResources.of(context).paymentHistoryEmptySubtitle,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: TextStyles.body
                .copyWith(color: DynamicTheme.get(context).neutral10())),
        const Spacer(),
      ]),
    ]);
  }
}
