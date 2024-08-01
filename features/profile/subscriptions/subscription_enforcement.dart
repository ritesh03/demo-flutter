import 'package:flutter/cupertino.dart';
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/models/models.dart';
import 'package:kwotmusic/components/widgets/alert_box_buy_token.dart';
import 'package:kwotmusic/components/widgets/notificationbar/notification_bar.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';

import 'purchase/step1preview/subscription_plan_selection_preview.model.dart';
import 'subscription_detail.model.dart';

class SubscriptionEnforcement {
  //=
  static bool fulfilSubscriptionRequirement(
    BuildContext context, {
    required String feature,
   required String text,
  }) {
    final subscriptionModel = locator<SubscriptionDetailModel>();
    final hasFeature = subscriptionModel.isFeatureAwarded(feature);
    if (hasFeature == false) {
      ShowAlertBox.showAlertUpgradePlan(context, onTapCancel: () {
        RootNavigation.pop(context);
      }, onTapBuy: () {
        RootNavigation.popUntilRoot(context);
        DashboardNavigation.pushNamed(context, Routes.manageSubscription);
      },
          alertText: text);
      /*showDefaultNotificationBar(
        NotificationBarInfo.error(
          message: LocaleResources.of(context).yourSubscriptionDoesNotAllowMessage,
        ),
      );*/
      return false;
    } else if (hasFeature) {
      return true;
    } else {}

    return false;
  }
}
