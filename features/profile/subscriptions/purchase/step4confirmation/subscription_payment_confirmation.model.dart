import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';

class SubscriptionPaymentConfirmationArgs {
  SubscriptionPaymentConfirmationArgs({
    required this.selectedPlan,
    required this.subscriptionOrderResult,
  });

  final SubscriptionPlan selectedPlan;
  final Result<SubscriptionOrder> subscriptionOrderResult;
}

class SubscriptionPaymentConfirmationModel with ChangeNotifier {
  late SubscriptionPlan _selectedPlan;
  late Result<SubscriptionOrder> _subscriptionOrderResult;

  SubscriptionPaymentConfirmationModel({
    required SubscriptionPaymentConfirmationArgs args,
  })  : _selectedPlan = args.selectedPlan,
        _subscriptionOrderResult = args.subscriptionOrderResult;

  void init() {}

  SubscriptionPlan get selectedPlan => _selectedPlan;

  Result<SubscriptionOrder> get subscriptionOrderResult =>
      _subscriptionOrderResult;
}
