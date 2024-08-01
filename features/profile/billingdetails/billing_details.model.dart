import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';

class BillingDetailsModel with ChangeNotifier {
  //=

  async.CancelableOperation<Result<BillingDetail>>? _billingDetailOp;
  Result<BillingDetail>? billingDetailResult;

  void init() {
    fetchBillingDetail();
  }

  @override
  void dispose() {
    _billingDetailOp?.cancel();
    super.dispose();
  }

  /*
   * API: Billing Details
   */

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

  void updateBillingDetail(BillingDetail? billingDetail) {
    if (billingDetail == null) {
      billingDetailResult = Result.empty();
    } else {
      billingDetailResult = Result.success(billingDetail);
    }

    notifyListeners();
  }

  /*
   * API: Delete Billing Details
   */

  Future<Result> deleteBillingDetail({
    required String id,
  }) async {
    final request = DeleteBillingDetailRequest(id: id);
    final result =
        await locator<KwotData>().accountRepository.deleteBillingDetail(request);
    if (result.isSuccess()) {
      updateBillingDetail(null);
    }
    return result;
  }
}
