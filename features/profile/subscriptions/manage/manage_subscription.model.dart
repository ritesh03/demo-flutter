import 'dart:async';

import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/features/profile/subscriptions/subscription_detail.model.dart';

class ManageSubscriptionModel with ChangeNotifier {
  Result<SubscriptionDetail>? _subscriptionDetailResult;
  Result<List<SubscriptionPlan>>? _subscriptionPlansResult;

  StreamSubscription? _subscriptionDetailResultSubscription;
  StreamSubscription? _subscriptionPlansResultSubscription;


  void init() {
    _subscriptionDetailResultSubscription = locator<SubscriptionDetailModel>()
        .subscriptionDetailStream
        .distinct()
        .listen((result) {
      _subscriptionDetailResult = result;
      notifyListeners();
    });

    _subscriptionPlansResultSubscription = locator<SubscriptionDetailModel>()
        .subscriptionPlansStream
        .listen((result) {
      _subscriptionPlansResult = result;
      notifyListeners();
    });
  }

  Result<SubscriptionDetail>? get subscriptionDetailResult =>
      _subscriptionDetailResult;

  SubscriptionDetail? get subscriptionDetail =>
      _subscriptionDetailResult?.peek();

  Result<List<SubscriptionPlan>>? get subscriptionPlansResult {
    final subscriptionDetailResult = _subscriptionDetailResult;
    if (subscriptionDetailResult == null || !subscriptionDetailResult.isSuccess() || subscriptionDetailResult.isEmpty()) {
      return Result.empty();
    }

    final subscriptionDetail = subscriptionDetailResult.data();
    /*if (subscriptionDetail.activation != null) {
      // The user has a premium plan
      return Result.empty();
    }*/
    return _subscriptionPlansResult;
  }

  @override
  void dispose() {
    _subscriptionDetailResultSubscription?.cancel();
    _subscriptionPlansResultSubscription?.cancel();
    super.dispose();
  }

  void refreshActiveSubscription() {
    locator<SubscriptionDetailModel>().refreshSubscriptionDetail();
  }

  void refreshSubscriptionPlans() {
    locator<SubscriptionDetailModel>().refreshSubscriptionPlans();
  }

  Future<Result> cancelSubscription() async {
    try {
      final result =
          await locator<KwotData>().subscriptionRepository.cancelSubscription();
      if (result.isSuccess()) {
        refreshActiveSubscription();
      }
      return result;
    } catch (error) {
      return Result.error("Error: $error");
    }
  }
}
