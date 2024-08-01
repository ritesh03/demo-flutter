import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/widgets/list/item_list.model.dart';
import 'package:wrapped_infinite_scroll_pagination/infinite_scroll_pagination.dart';

class PaymentHistoryModel with ChangeNotifier, ItemListModel<PaymentTransaction> {
  //=

  String? _appliedSearchQuery;

  async.CancelableOperation<Result<ListPage<PaymentTransaction>>>?_paymentTransactionsOp;
  late final PagingController<int, PaymentTransaction>_paymentTransactionsController;

  void init() {
    _paymentTransactionsController =
        PagingController<int, PaymentTransaction>(firstPageKey: 1);
    _paymentTransactionsController.addPageRequestListener((pageKey) {
      _fetchPaymentTransactions(pageKey);
    });
  }

  @override
  void dispose() {
    _paymentTransactionsOp?.cancel();
    _paymentTransactionsController.dispose();
    super.dispose();
  }

  /*
   * Search Query
   */

  String? get appliedSearchQuery => _appliedSearchQuery;

  void updateSearchQuery(String text) {
    if (_appliedSearchQuery != text) {
      _appliedSearchQuery = text;
      _paymentTransactionsController.refresh();
      notifyListeners();
    }
  }

  void clearSearchQuery() {
    if (_appliedSearchQuery != null) {
      _appliedSearchQuery = null;
      _paymentTransactionsController.refresh();
      notifyListeners();
    }
  }

  /*
   * API: Payment Transaction List
   */

  bool _isPaymentHistoryEmpty = false;

  bool get isPaymentHistoryEmpty => _isPaymentHistoryEmpty;

  Future<void> _fetchPaymentTransactions(int pageKey) async {
    try {
      // Cancel current operation (if any)
      _paymentTransactionsOp?.cancel();

      if (_isPaymentHistoryEmpty) {
        _isPaymentHistoryEmpty = false;
        notifyListeners();
      }

      // Create Request
      final request = PaymentTransactionsRequest(
        page: pageKey,
        query: _appliedSearchQuery,
      );
      final paymentTransactionsOp = async.CancelableOperation.fromFuture(
        locator<KwotData>().accountRepository.fetchPaymentTransactions(request),
        onCancel: () {
          _paymentTransactionsController.error = "Cancelled.";
        },
      );
      _paymentTransactionsOp = paymentTransactionsOp;

      // Listen for result
      final result = await paymentTransactionsOp.value;
      if (!result.isSuccess()) {
        _paymentTransactionsController.error = result.error();
        return;
      }

      final page = result.data();
      if (request.query == null && page.totalItems == 0) {
        _isPaymentHistoryEmpty = true;
        notifyListeners();
      }

      final currentItemCount =
          _paymentTransactionsController.itemList?.length ?? 0;
      final isLastPage = page.isLastPage(currentItemCount);
      if (isLastPage) {
        _paymentTransactionsController.appendLastPage(page.items??[]);
      } else {
        final nextPageKey = pageKey + 1;
        _paymentTransactionsController.appendPage(page.items??[], nextPageKey);
      }
    } catch (error) {
      _paymentTransactionsController.error = error;
    }
  }

  /*
   * ItemListModel<PaymentTransaction>
   */

  @override
  PagingController<int, PaymentTransaction> controller() =>
      _paymentTransactionsController;

  @override
  void refresh({
    required bool resetPageKey,
    bool isForceRefresh = false,
  }) {
    _paymentTransactionsOp?.cancel();

    if (resetPageKey) {
      _paymentTransactionsController.refresh();
    } else {
      // TODO: @Github/EdsonBueno/infinite_scroll_pagination/issues/106
      _paymentTransactionsController.retryLastFailedRequest();
    }
  }
}
