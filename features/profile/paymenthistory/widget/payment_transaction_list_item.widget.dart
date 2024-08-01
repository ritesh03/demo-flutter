import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/button/buttons.dart';
import 'package:kwotmusic/components/widgets/indicator/indicators.dart';
import 'package:kwotmusic/util/util.dart';

import '../../../../util/prefs.dart';

class PaymentTransactionListItem extends StatelessWidget {
  const PaymentTransactionListItem({
    Key? key,
    required this.transaction,
    required this.onTap,
    required this.onDownloadInvoiceTap,
  }) : super(key: key);

  final PaymentTransaction transaction;
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
            transaction: transaction,
            onDownloadInvoiceTap: onDownloadInvoiceTap,
          ),
          const Separator(),
        ]));
  }
}

class _Content extends StatelessWidget {
  const _Content({
    Key? key,
    required this.transaction,
    required this.onDownloadInvoiceTap,
  }) : super(key: key);

  final PaymentTransaction transaction;
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
              _TransactionTitle(text: transaction.title),
              _TransactionDate(date: transaction.createdAt),
            ],
          ),
        ),
        SizedBox(width: ComponentInset.normal.r),
        Expanded(child: _TransactionAmount(text: transaction.displayPrice)),
      //  _TransactionInvoiceDownloadButton(onTap: onDownloadInvoiceTap),
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

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final text = date.toDefaultDateFormat();
    return Text(
      text,
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
    String planPrice =
        "${num.parse(SharedPref.prefs!.getString(SharedPref.userAmount) == null ? "1" : SharedPref.prefs!.getString(SharedPref.userAmount) == "" ? "1" : SharedPref.prefs!.getString(SharedPref.userAmount) ?? "1").toDouble() * (double.parse(text))}";
    double doubleValue = double.parse(planPrice);
    int intValue = doubleValue.toInt();
    return Text("${SharedPref.prefs!.getString(SharedPref.currencySymbol) ?? "\$"}${intValue.toString()}",
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyles.boldHeading3
          .copyWith(color: DynamicTheme.get(context).white()),
    );
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
        assetPath: Assets.iconDownload,
        padding: EdgeInsets.all(ComponentInset.small.r),
        onPressed: onTap);
  }
}
