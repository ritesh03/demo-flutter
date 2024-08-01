import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/models/artist/subscription.artist.model.dart';
import 'package:kwotdata/models/models.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/util/hexcolor.dart';
import 'package:kwotapi/src/entities/subscription/subscription_period.enum.dart';

class UISubscriptionPlan {
  UISubscriptionPlan({
    required this.bgGradient,
    required this.benefits,
    required this.description,
    required this.displayPrice,
    required this.name,
    required this.renewalDurationText,
    this.tokens,
    this.period,
    this.currencySymbol,
  });

  final Gradient bgGradient;
  final List<SubscriptionFeature> benefits;
  final String description;
  final String displayPrice;
  final String name;
  final String? period;
  final String? renewalDurationText;
  final String? tokens;
  final String? currencySymbol;
}

extension SubscriptionPlanExt on SubscriptionPlan {
  UISubscriptionPlan toUISubscriptionPlan(TextLocaleResource localeResource) {
    final String? renewalDurationText;
    renewalDurationText = payment !=null? payment!.period:"";
    /*switch (payment?.period) {
      case null:
        renewalDurationText = null;
        break;
      case SubscriptionPeriod.threeMinutes:
        renewalDurationText = 'Per three minutes';
        break;
      case SubscriptionPeriod.hour:
        renewalDurationText = 'Per hour';
        break;
      case SubscriptionPeriod.week:
        renewalDurationText = localeResource.subscriptionPlanPerWeek;
        break;
      case SubscriptionPeriod.month:
        renewalDurationText = localeResource.subscriptionPlanPerMonth;
        break;
      case SubscriptionPeriod.year:
        renewalDurationText = localeResource.subscriptionPlanPerYear;
        break;
      case SubscriptionPeriod.twoMonth:
        renewalDurationText = localeResource.twoMonths;
        break;
      case SubscriptionPeriod.threeMonths:
        renewalDurationText = "3 Months";
        break;
      case SubscriptionPeriod.oneMonth:
        renewalDurationText = "1 Month";
        break;
      case SubscriptionPeriod.twoMonthss:
        renewalDurationText = "2 Month";
        break;
    }*/

    final String displayPrice;
    if (payment != null) {
      displayPrice = payment!.currency.displayPrice(payment!.price);
    } else {
      displayPrice = localeResource.subscriptionPlanFree;
    }

    const defaultColor = Colors.blueGrey;
    final List<String> hexColors = this.colors ?? <String>[];
    final List<Color> colors = hexColors.take(2).map((hexColor) {
      return HexColorUtil.hexToColor(hexColor) ?? defaultColor;
    }).toList();

    while (colors.length < 2) {
      colors.add(defaultColor);
    }

    return UISubscriptionPlan(
      bgGradient: LinearGradient(
        colors: colors,
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      benefits: benefits??[],
      description: description??"",
      displayPrice: displayPrice,
      name: name??"",
      renewalDurationText: renewalDurationText,
      tokens: token
    );
  }
}
extension SubscriptionPlaModelEXT on SubscriptionArtistPlanModel {
  ///for renewal duaration text is set on string
  UISubscriptionPlan toUISubscriptionPlanModel(TextLocaleResource localeResource) {
     String? renewalDurationText;
    switch (plan!.timePeriod) {
      case null:
        renewalDurationText = null;
        break;
      case "per three minutes":
        renewalDurationText = 'Per three minutes';
        break;
      case "per hour":
        renewalDurationText = 'Per hour';
        break;
      case "week":
        renewalDurationText = localeResource.subscriptionPlanPerWeek;
        break;
      case "month":
        renewalDurationText = localeResource.subscriptionPlanPerMonth;
        break;
      case "year":
        renewalDurationText = localeResource.subscriptionPlanPerYear;
        break;
    }

    final String displayPrice;
    if (plan != null) {
      displayPrice = price.toString();
    } else {
      displayPrice = localeResource.subscriptionPlanFree;
    }

    const defaultColor = Colors.blueGrey;
    final List<String> hexColors = this.plan!.colors ?? <String>[];
    final List<Color> colors = hexColors.take(2).map((hexColor) {
      return HexColorUtil.hexToColor(hexColor) ?? defaultColor;
    }).toList();

    while (colors.length < 2) {
      colors.add(defaultColor);
    }

    return UISubscriptionPlan(
      bgGradient: LinearGradient(
        colors: colors,
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      benefits: plan!.benefits!,
      description: plan!.description!,
      displayPrice: displayPrice,
      name: plan!.name!,
      currencySymbol: plan!.payment!.currencySymbol,
      tokens: tokens.toString(),
      renewalDurationText: plan!.timePeriod,
    );
  }
}
