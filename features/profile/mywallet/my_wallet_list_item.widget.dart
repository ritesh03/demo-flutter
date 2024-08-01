import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotdata/models/mywallet/get_my_wallet_history_model.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/button/buttons.dart';
import 'package:kwotmusic/components/widgets/indicator/indicators.dart';
import 'package:kwotmusic/util/util.dart';

import '../../../components/widgets/photo/svg_asset_photo.dart';
import '../../../util/date_time_methods.dart';

class MyWalletListItem extends StatelessWidget {
  const MyWalletListItem({
    Key? key,
    required this.history,
    required this.onTap,
    required this.onDownloadInvoiceTap,
  }) : super(key: key);

  final GetMyWalletHistory history;
  final VoidCallback onTap;
  final VoidCallback onDownloadInvoiceTap;

  @override
  Widget build(BuildContext context) {
    return TappableButton(
        onTap: onTap,
        borderRadius: BorderRadius.zero,
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
        child: Stack(alignment: Alignment.bottomCenter, children: [
          _Content(
            history: history,
            onDownloadInvoiceTap: onDownloadInvoiceTap,
          ),
          const Separator(),
        ]));
  }
}

class _Content extends StatelessWidget {
  const _Content({
    Key? key,
    required this.history,
    required this.onDownloadInvoiceTap,
  }) : super(key: key);

  final GetMyWalletHistory history;
  final VoidCallback onDownloadInvoiceTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ComponentInset.normal.r),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TransactionTitle(text: getTokenHeading(history.tokenType??"", history.tokens??0)),
              _TransactionDate(date: DateConvertor.dateToDDMMYY(history.purchasedDate.toString())),
            ],
          ),
        ),
        SizedBox(width: ComponentInset.normal.r),
        Expanded(child: _TransactionAmount(text: history.tokens.toString())),
       // _TransactionInvoiceDownloadButton(onTap: onDownloadInvoiceTap),
      ]),
    );
  }
}

class _TransactionTitle extends StatelessWidget {
  const _TransactionTitle({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: TextStyles.boldBody
          .copyWith(color: DynamicTheme.get(context).white()),
      textAlign: TextAlign.left,
    );
  }
}

class _TransactionDate extends StatelessWidget {
  const _TransactionDate({
    Key? key,
    required this.date,
  }) : super(key: key);

  final String date;

  @override
  Widget build(BuildContext context) {

    return Text(
      date,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyles.body
          .copyWith(color: DynamicTheme.get(context).neutral10()),
      textAlign: TextAlign.left,
    );
  }
}

class _TransactionAmount extends StatelessWidget {
  const _TransactionAmount({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SvgAssetPhoto(
            Assets.iconToken,
            width: 24.w,
            height: 24.h,
            color: DynamicTheme.get(context).white(),
          ),
          Text(text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyles.boldHeading3
                    .copyWith(color: DynamicTheme.get(context).white())),

        ]);
  }
}

class _TransactionInvoiceDownloadButton extends StatelessWidget {
  const _TransactionInvoiceDownloadButton({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppIconButton(
        width: ComponentSize.large.r,
        height: ComponentSize.large.r,
        assetColor: DynamicTheme.get(context).secondary100(),
        assetPath: Assets.downloadTokenHistory,
        padding: EdgeInsets.all(ComponentInset.small.r),
        onPressed: onTap);
  }
}

String getTokenHeading(String tokenType, int token){
  if(tokenType == "purchased"){
    return "$token token purchased";
  }else if(tokenType == "sent"){
    return "$token token sent";
  }else if(tokenType == "received"){
    return "$token token received";
  }else{
    return "";
  }
}
