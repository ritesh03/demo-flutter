

import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:async/async.dart' as async;

import '../../../../../components/widgets/blocking_progress.dialog.dart';

class SubscriptionPlanSelectionPreviewArgs {
  SubscriptionPlanSelectionPreviewArgs({
    required this.selectedPlan,
    required this.planName
  });

  final SubscriptionPlan? selectedPlan;
  final String planName;
}

class SubscriptionPlanSelectionPreviewModel with ChangeNotifier {
  late SubscriptionPlan? _selectedPlan;
  late String _planName;
  async.CancelableOperation<Result<Profile>>? _profileOp;
  async.CancelableOperation<Result<TemporarySubscriptionOrder>>? _subscriptionOp;
  Result<Profile>? profileResult;
  Result<TemporarySubscriptionOrder>? subscriptionResult;
  async.CancelableOperation<Result<BillingDetail>>? _billingDetailOp;
  Result<BillingDetail>? billingDetailResult;





  SubscriptionPlanSelectionPreviewModel({required SubscriptionPlanSelectionPreviewArgs args,required String planName,}) : _selectedPlan = args?.selectedPlan,_planName = planName;

  void init() {

    fetchProfile();
    fetchBillingDetail();

  }

      @override
  void dispose() {
    _profileOp!.cancel();
    _billingDetailOp!.cancel();

    super.dispose();
  }

  SubscriptionPlan? get selectedPlan => _selectedPlan;
  String get userPlan => _planName;

  void updateSelectedPlan(SubscriptionPlan plan) {
    _selectedPlan = plan;
    notifyListeners();
  }

  /// Fetch user token to purchase plan
  Future<void> fetchProfile() async {
    // Cancel current operation (if any)
    _profileOp?.cancel();

    if (profileResult != null) {
      profileResult = null;
      notifyListeners();
    }

    // Create Request
    _profileOp = async.CancelableOperation.fromFuture(
        locator<KwotData>().accountRepository.fetchProfile());

    // Wait for result
    profileResult = await _profileOp?.value;
    notifyListeners();
  }
///Buy Platform subscription
  Future<bool> buySubscription(SubscriptionPlan plan, context) async {
    showBlockingProgressDialog(context);
    // Cancel current operation (if any)
    _subscriptionOp?.cancel();

    if (subscriptionResult != null) {
      subscriptionResult = null;
      notifyListeners();
    }
    final request = CreateTemporarySubscriptionOrderRequest(
        plan: plan);

    // Create Request
    _subscriptionOp = async.CancelableOperation.fromFuture(
        locator<KwotData>().subscriptionRepository.createTemporarySubscriptionOrder(request));

    // Wait for result
    subscriptionResult = await _subscriptionOp?.value;
    notifyListeners();
    if(subscriptionResult!.isSuccess()){
      hideBlockingProgressDialog(context);
      return true;
    }
    else{
      hideBlockingProgressDialog(context);
      return false;
    }

  }


  ///fetch user billing details
  Future<void> fetchBillingDetail() async {
    try {
      // Cancel current operation (if any)
      _billingDetailOp?.cancel();

      if (billingDetailResult != null) {
        billingDetailResult = null;
        notifyListeners();
      }

      // Create operation
      final billingDetailOp = async.CancelableOperation.fromFuture(
          locator<KwotData>().accountRepository.fetchBillingDetail());
      _billingDetailOp = billingDetailOp;

      // Listen for result
      billingDetailResult = await billingDetailOp.value;
    } catch (error) {
      billingDetailResult = Result.error(error.toString());
    }

    notifyListeners();
  }
}


