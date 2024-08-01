import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';

typedef SubscriptionPaymentMethodsResult = Result<List<SubscriptionPaymentMethod>>;

class SubscriptionPaymentMethodsModel with ChangeNotifier {
  //=

  async.CancelableOperation<SubscriptionPaymentMethodsResult>? _paymentMethodsOp;
  SubscriptionPaymentMethodsResult? paymentMethodsResult;

  void init() {
    fetchPaymentMethods();
  }

  @override
  void dispose() {
    _paymentMethodsOp?.cancel();
    super.dispose();
  }

  /*
   * API: Payment Methods
   */

  Future<void> fetchPaymentMethods() async {
    try {
      // Cancel current operation (if any)
      _paymentMethodsOp?.cancel();

      if (paymentMethodsResult != null) {
        paymentMethodsResult = null;
        notifyListeners();
      }

      // Create operation
      final paymentMethodsOp = async.CancelableOperation.fromFuture(
        locator<KwotData>().subscriptionRepository.fetchSubscriptionPaymentMethods(),
      );
      _paymentMethodsOp = paymentMethodsOp;

      // Listen for result
      paymentMethodsResult = await paymentMethodsOp.value;
    } catch (error) {
      paymentMethodsResult = Result.error(error.toString());
    }

    notifyListeners();
  }
}
