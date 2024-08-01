import 'dart:io';

import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/material_bottom_sheet.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/promptdialogsheet/prompt_dialog_sheet.widget.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/artist/tip/artist_tip.args.dart';
import 'package:kwotmusic/l10n/localizations.dart';

import '../../../components/widgets/alert_box_buy_token.dart';
import '../../../router/routes.dart';
import '../../../util/util_url_launcher.dart';

class BuyTokenBottomSheet extends StatefulWidget {
  //=
  static Future<bool?> show(
    BuildContext context, {required ArtistTipModel model}) {
    return showMaterialBottomSheet<bool>(
      context,
      expand: false,
      builder: (_, __) => BuyTokenBottomSheet(model: model,),
    );
  }

  const BuyTokenBottomSheet({
    Key? key,
    required this.model
  }) : super(key: key);

final ArtistTipModel model;

  @override
  State<BuyTokenBottomSheet> createState() =>
      _BuyTokenBottomSheetState();
}

class _BuyTokenBottomSheetState extends State<BuyTokenBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final localization = LocaleResources.of(context);

    return PromptDialogSheet(
      backgroundAssetPath: Assets.backgroundGuitar,
      highlightedActionTitle: localization.buyMoreTokens,
      onNormalActionTap: () => RootNavigation.pop(context, true),
      onHighlightedActionTap: () {
          if (widget.model.billingDetailResult!.message != "Successful") {
            ShowAlertBox.showAlertForAddBillingDetails(context, onTapCancel: () {
              Navigator.of(context, rootNavigator: true).pop();
            }, onTapBuy: () {
              DashboardNavigation.pushNamed(context, Routes.addBillingDetails)
                  .then((value) {
                widget.model.fetchBillingDetail();
              });
              Navigator.of(context, rootNavigator: true).pop();
              Navigator.of(context, rootNavigator: true).pop();
            });
          } else {
            if(Platform.isIOS) {
              DashboardNavigation.pushNamed(context, Routes.myWalletPage).then((value) {
                widget.model.fetchTotalTokens();
              });
            }else{
              UrlLauncherUtil.buyToken(context).then((value) {
                widget.model.fetchTotalTokens();
              });
            }
            Navigator.of(context, rootNavigator: true).pop();
          }


      },
      normalActionTitle:  localization.cancel,
      subtitle:localization.doYouWantToBuyMore,
      title: localization.youHaveNotEnoughTokens,
    );
  }
}
