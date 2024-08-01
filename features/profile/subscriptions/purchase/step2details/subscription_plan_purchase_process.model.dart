import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:rxdart/rxdart.dart';

class SubscriptionPlanPurchaseProcessArgs {
  SubscriptionPlanPurchaseProcessArgs({
     this.selectedPlan,
  });

  final SubscriptionPlan? selectedPlan;
}

class SubscriptionPlanPurchaseProcessModel with ChangeNotifier {
  final SubscriptionPlan _selectedPlan;

  final _purchaseStepSubject = BehaviorSubject<SubscriptionPlanPurchaseStep>();

  BillingDetail? _selectedBillingDetail;
  SubscriptionPaymentMethod? _selectedPaymentMethod;

  async.CancelableOperation<Result<SubscriptionPaymentDetail>>?
  _paymentDetailOp;
  Result<SubscriptionPaymentDetail>? _paymentDetailResult;

  bool _hasAgreedToPurchaseConditions = false;

  SubscriptionPlanPurchaseProcessModel({required SubscriptionPlanPurchaseProcessArgs args,}) : _selectedPlan = args.selectedPlan! {
    _purchaseStepSubject.add(SubscriptionPlanPurchaseStep.billing);
  }

  void init() {}

  ValueStream<SubscriptionPlanPurchaseStep> get purchaseStepStream =>
      _purchaseStepSubject.stream;

  SubscriptionPlanPurchaseStep get _purchaseStep => purchaseStepStream.value;

  SubscriptionPlan get selectedPlan => _selectedPlan;

  BillingDetail? get selectedBillingDetail => _selectedBillingDetail;

  SubscriptionPaymentMethod? get selectedPaymentMethod =>
      _selectedPaymentMethod;

  Result<SubscriptionPaymentDetail>? get paymentDetailResult =>
      _paymentDetailResult;

  bool get hasAgreedToPurchaseConditions => _hasAgreedToPurchaseConditions;

  bool get canCheckout {
    return _selectedBillingDetail != null &&
        _selectedPaymentMethod != null &&
        _hasAgreedToPurchaseConditions;
  }

  @override
  void dispose() {
    _paymentDetailOp?.cancel();
    super.dispose();
  }

  void onBillingDetailSelected(BillingDetail billingDetail) {
    _selectedBillingDetail = billingDetail;
    if (_selectedPaymentMethod == null) {
      moveToPurchaseStep(SubscriptionPlanPurchaseStep.payment);
    } else {
      moveToPurchaseStep(SubscriptionPlanPurchaseStep.review);
    }

    fetchSubscriptionPaymentDetail();
  }

  void onPaymentMethodSelected(SubscriptionPaymentMethod paymentMethod) {
    _selectedPaymentMethod = paymentMethod;
    _purchaseStepSubject.add(SubscriptionPlanPurchaseStep.review);
    notifyListeners();

    fetchSubscriptionPaymentDetail();
  }

  void moveToPurchaseStep(SubscriptionPlanPurchaseStep purchaseStep) {
    _purchaseStepSubject.add(purchaseStep);
  }

  Future<void> fetchSubscriptionPaymentDetail() async {
    final billingDetail = _selectedBillingDetail;
    if (billingDetail == null) return;

    final paymentMethod = _selectedPaymentMethod;
    if (paymentMethod == null) return;

    final paymentDetail = _paymentDetailResult?.peek();
    if (paymentDetail != null) {
      if (paymentDetail.billingDetail.id == billingDetail.id &&
          paymentDetail.paymentMethod.id == paymentMethod.id &&
          paymentDetail.plan.id == selectedPlan.id) {
        return;
      }
    }

    try {
      // Cancel current operation (if any)
      _paymentDetailOp?.cancel();

      if (_paymentDetailResult != null) {
        _paymentDetailResult = null;
        notifyListeners();
      }

      // Create operation
      final request = SubscriptionPaymentDetailRequest(
        plan: selectedPlan,
        billingDetail: billingDetail,
        paymentMethod: paymentMethod,
      );
      _paymentDetailOp = async.CancelableOperation.fromFuture(
        locator<KwotData>()
            .subscriptionRepository
            .fetchSubscriptionPaymentDetail(request),
      );
      _paymentDetailResult = await _paymentDetailOp!.value;

      final paymentDetail = _paymentDetailResult?.peek();
      if (paymentDetail != null) {
        if (paymentDetail.billingDetail.id != billingDetail.id ||
            paymentDetail.paymentMethod.id != paymentMethod.id ||
            paymentDetail.plan.id != selectedPlan.id) {
          _paymentDetailResult = Result.error("Error: Payment Detail Mismatch");
        }
      }
    } catch (error) {
      _paymentDetailResult = Result.error(error.toString());
    }

    notifyListeners();
  }

  void toggleAgreementAcceptance() {
    _hasAgreedToPurchaseConditions = !_hasAgreedToPurchaseConditions;
    notifyListeners();
  }

  bool handleBackNavigation() {
    switch (_purchaseStep) {
      case SubscriptionPlanPurchaseStep.billing:
        return false;
      case SubscriptionPlanPurchaseStep.payment:
        _purchaseStepSubject.add(SubscriptionPlanPurchaseStep.billing);
        notifyListeners();
        return true;
      case SubscriptionPlanPurchaseStep.review:
        _purchaseStepSubject.add(SubscriptionPlanPurchaseStep.payment);
        notifyListeners();
        return true;
    }
  }

  Future<Result> initiatePayment(TextLocaleResource localeResource) async {
    final billingDetail = _selectedBillingDetail;
    if (billingDetail == null) {
      return Result.error(localeResource.errorBillingDetailNotSelected);
    }

    final paymentMethod = _selectedPaymentMethod;
    if (paymentMethod == null) {
      return Result.error(localeResource.errorPaymentMethodNotSelected);
    }

    if (!hasAgreedToPurchaseConditions) {
      return Result.error(localeResource.errorPurchaseConditionsNotAccepted);
    }

    try {
      final request = CreateTemporarySubscriptionOrderRequest(
          plan: selectedPlan);
         // billingDetail: billingDetail,
        //  paymentMethod: paymentMethod);

      final result = await locator<KwotData>().subscriptionRepository.createTemporarySubscriptionOrder(request);
      return result;
    } catch (error) {
      return Result.error(error.toString());
    }
  }
}

enum SubscriptionPlanPurchaseStep {
  billing(position: 0),
  payment(position: 1),
  review(position: 2);

  final int position;

  const SubscriptionPlanPurchaseStep({
    required this.position,
  });
}
