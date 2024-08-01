import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kwotdata/models/getCurrencyRate/get_currency_rate.dart';
import 'package:kwotdata/models/mywallet/get_my_wallet_history_model.dart';
import 'package:provider/provider.dart';

import '../../../components/kit/assets.dart';
import '../../../components/kit/component_inset.dart';
import '../../../components/kit/component_size.dart';
import '../../../components/kit/textstyles.dart';
import '../../../components/kit/theme/dynamic_theme.dart';
import '../../../components/widgets/alert_box_buy_token.dart';
import '../../../components/widgets/button.dart';
import '../../../components/widgets/gradient/foreground_gradient_photo.widget.dart';
import '../../../components/widgets/list/item_list.widget.dart';
import '../../../components/widgets/page/title/page_title_bar_text.widget.dart';
import '../../../components/widgets/page/title/page_title_bar_wrapper.dart';
import '../../../components/widgets/photo/svg_asset_photo.dart';
import '../../../components/widgets/textfield/search/searchbar.widget.dart';
import '../../../l10n/localizations.dart';
import '../../../navigation/dashboard_navigation.dart';
import '../../../router/routes.dart';
import '../../../util/get_currency_rate.dart';
import '../../../util/util_url_launcher.dart';
import '../../dashboard/dashboard_config.dart';
import '../../dashboard/widget/titlebar/dashboard_title.widgets.dart';
import 'my_wallet_list_item.widget.dart';
import 'my_wallet_model.dart';

class MyWalletPage extends StatefulWidget {
  const MyWalletPage({Key? key}) : super(key: key);

  @override
  State<MyWalletPage> createState() => _MyWalletPageState();
}

class _MyWalletPageState extends State<MyWalletPage> {
  late FocusNode _searchInputFocusNode;
  late ScrollController _scrollController;
  MyWalletModel get _model => context.read<MyWalletModel>();

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
        body:  PageTitleBarWrapper(
          barHeight: ComponentSize.large.r,
          title: PageTitleBarText(
              text: localeResource.paymentHistory,
              color: DynamicTheme.get(context).white(),
              onTap: () {}),
          actions: [
            DashboardPageTitleAction(
                asset: Assets.iconSearch,
                color: DynamicTheme.get(context).neutral20(),
                onTap: () {}),
          ],
          child: _ItemList(
            controller: _scrollController,
            header: _ItemListHeader(
              localeResource: localeResource,
              searchInputFocusNode: _searchInputFocusNode,
              model: _model,
            ),
            localeResource: localeResource,
            onDownloadInvoiceTap: () {},
            onTransactionTap: () {},
          ),
        )
      ),
    );
  }
}

class _ItemListHeader extends StatelessWidget {
  const _ItemListHeader({
    Key? key,
    required this.localeResource,
    required this.searchInputFocusNode,
    required this.model,
  }) : super(key: key);

  final TextLocaleResource localeResource;
  final FocusNode searchInputFocusNode;
  final MyWalletModel model;

  @override
  Widget build(BuildContext context) {
    return Selector<MyWalletModel, bool>(
        selector: (_, model) => model.isTokenEmpty,
    builder: (_, isEmpty, __) {
      if(isEmpty){
        return  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
            child: Text(localeResource.myWallet,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyles.boldHeading2
                    .copyWith(color: DynamicTheme.get(context).white())),
          ),
          SizedBox(
            height: ComponentInset.normal.h,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
            child: Container(
              height: 104.h,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: DynamicTheme.get(context).secondary10(),
                  borderRadius: BorderRadius.circular(ComponentInset.small.r)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: ComponentInset.normal.h,
                  ),
                  const _Title(),
                  SizedBox(
                    height: ComponentInset.small.h,
                  ),
                  _AmountWidget(
                    model: model,
                  ),
                ],
              ),
            ),
          ),
          _buildBuyTokenButton(context,model),
          SizedBox(
            height: ComponentInset.medium.h,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
            child: const _SearchTitle(),
          ),
          SizedBox(
            height: ComponentInset.normal.h,
          ),
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
      }else{
        return const SizedBox.shrink();
      }

    });
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
    return Selector<MyWalletModel, bool>(
      selector: (_, model) => model.isWalletHistoryEmpty,
      builder: (_, isPaymentHistoryEmpty, __) {
        if (isPaymentHistoryEmpty) return const SizedBox.shrink();
        return SearchBar(
          focusNode: focusNode,
          hintText: localeResource.search,
          onQueryChanged: context.read<MyWalletModel>().updateSearchQuery,
          onQueryCleared: context.read<MyWalletModel>().clearSearchQuery,
        );
      },
    );
  }
}

Widget _buildBuyTokenButton(BuildContext context,MyWalletModel _model) {
  return Button(
    margin: EdgeInsets.only(
      top: ComponentInset.normal.r,
      left: ComponentInset.normal.r,
      right: ComponentInset.normal.r,
    ),
    text: LocaleResources.of(context).buyTokens,
    height: ComponentSize.large.h,
    type: ButtonType.primary,
    width: MediaQuery.of(context).size.width,
    onPressed: () {
      if(Platform.isIOS){
        Navigator.pushNamed(context, Routes.buyTokenPage).then((value) {
          if(value == true){
            Navigator.pushReplacementNamed(context, Routes.myWalletPage);
          }
        });
        return ;
      }else{
        if (_model.billingDetailResult!.message != "Successful") {
          ShowAlertBox.showAlertForAddBillingDetails(context,
              onTapCancel: () {
                Navigator.of(context, rootNavigator: true).pop();
              }, onTapBuy: () {
                DashboardNavigation.pushNamed(context, Routes.billingDetails);
                Navigator.of(context, rootNavigator: true).pop();
              });
        } else {
           UrlLauncherUtil.buyToken(context).then((value) {
           });
        }
      }


    },
  );
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
  final Function() onTransactionTap;
  final Function() onDownloadInvoiceTap;

  @override
  Widget build(BuildContext context) {
    return Selector<MyWalletModel, bool>(
        selector: (_, model) => model.isWalletHistoryEmpty,
        builder: (_, hasNoWalletTransactions, __) {
          if (hasNoWalletTransactions) {
            return _NoPaymentHistoryPage(header: header);
          }
          return ItemListWidget<GetMyWalletHistory, MyWalletModel>(
              controller: controller,
              headerSlivers: [SliverToBoxAdapter(child: header)],
              footerSlivers: [DashboardConfigAwareFooter.asSliver()],
              itemBuilder: (context, transaction, index) {
                return MyWalletListItem(
                  history: transaction,
                  onTap: () {},
                  onDownloadInvoiceTap: () {},
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
        Text(LocaleResources.of(context).thereIsNoHistoryYet,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: TextStyles.boldHeading2
                .copyWith(color: DynamicTheme.get(context).white())),
        SizedBox(height: ComponentInset.small.h),
        Text(LocaleResources.of(context).youWillSeeYourTokenHistoryHere,
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

class _Title extends StatelessWidget {
  const _Title({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(LocaleResources.of(context).yourBalance,
        style: TextStyles.heading4
            .copyWith(color: DynamicTheme.get(context).white()));
  }
}

class _SearchTitle extends StatelessWidget {
  const _SearchTitle({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(LocaleResources.of(context).tokenHistory,
        style: TextStyles.boldHeading3
            .copyWith(color: DynamicTheme.get(context).white()));
  }
}

class _AmountWidget extends StatelessWidget {
  const _AmountWidget({
    Key? key,
    required this.model,
  }) : super(key: key);

  final MyWalletModel model;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.symmetric(horizontal: ComponentInset.small.w),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SvgAssetPhoto(
              Assets.iconToken,
              width: 37.w,
              height: 37.h,
              color: DynamicTheme.get(context).white(),
            ),
            Container(
              constraints: BoxConstraints(maxWidth: 100.w),
              child: Selector<MyWalletModel, String>(
                  selector: (_, model) => model.tokens,
                  builder: (_, plan, __) {
                    return Text(plan??"",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyles.boldHeading1
                            .copyWith(color: DynamicTheme.get(context).white()));
                  }),
            ),
            SizedBox(
              width: 30.w,
            ),
            Text(LocaleResources.of(context).equal,
                textAlign: TextAlign.center,
                style: TextStyles.caption
                    .copyWith(color: DynamicTheme.get(context).neutral10())),
            SizedBox(
              width: 30.w,
            ),
            Selector<MyWalletModel, String>(
                shouldRebuild: (prev,next)=>true,
                selector: (_, model) => model.symbol,
                builder: (_, plan, __) {
                  return Text(plan,
                      style: TextStyles.robotoBoldHeading8
                          .copyWith(color: DynamicTheme.get(context).white()));
                }),
            Container(
              constraints: BoxConstraints(maxWidth: 90.w),
              child: Selector<MyWalletModel, String>(
                shouldRebuild: (prev,next)=>true,
                  selector: (_, model) => model.amount,
                  builder: (_, plan, __) {
                    return Text(plan,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyles.boldHeading1
                            .copyWith(color: DynamicTheme.get(context).white()));
                  }),
            ),
          ]),
    );
  }
}
