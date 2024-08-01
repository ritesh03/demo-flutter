import 'package:flutter/cupertino.dart';
import 'package:async/async.dart' as async;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotdata/models/mywallet/get_my_wallet_history_model.dart';
import 'package:kwotdata/models/mywallet/get_tokens_model.dart';
import 'package:kwotdata/models/result.dart';
import 'package:kwotmusic/util/prefs.dart';
import 'package:wrapped_infinite_scroll_pagination/src/core/paging_controller.dart';

import '../../../components/widgets/list/item_list.model.dart';
class MyWalletModel with ChangeNotifier,ItemListModel<GetMyWalletHistory>{
  async.CancelableOperation<Result<GetTotalTokens>>? _totalTokensOp;
  Result<GetTotalTokens>? resultTotalTokens;
  async.CancelableOperation<Result<ListPage<GetMyWalletHistory>>>?_walletHistoryOp;
  async.CancelableOperation<Result<BillingDetail>>? _billingDetailOp;
  Result<BillingDetail>? billingDetailResult;
  late final PagingController<int, GetMyWalletHistory> walletHistoryController;
  String? _appliedSearchQuery;

  void init() async{


   fetchTotalTokens();
   walletHistoryController = PagingController<int, GetMyWalletHistory>(firstPageKey: 1);
   walletHistoryController.addPageRequestListener((pageKey) {
     fetchMyWalletHistory(pageKey);
   });
   fetchBillingDetail();


 }
  @override
  void dispose() {
    _walletHistoryOp?.cancel();
    walletHistoryController.dispose();
    _totalTokensOp?.cancel();
    super.dispose();
  }

  /*
   * Search Query
   */

  String? get appliedSearchQuery => _appliedSearchQuery;

  void updateSearchQuery(String text) {
    if (_appliedSearchQuery != text) {
      _appliedSearchQuery = text;
      walletHistoryController.refresh();
      notifyListeners();
    }
  }

  void clearSearchQuery() {
    if (_appliedSearchQuery != null) {
      _appliedSearchQuery = null;
      walletHistoryController.refresh();
      notifyListeners();
    }
  }

  /*
   * API: wallet history list
   */

  bool _isWalletHistoryEmpty = false;

  bool get isWalletHistoryEmpty => _isWalletHistoryEmpty;
  bool _isTokenEmpty = false;

  bool get isTokenEmpty => _isTokenEmpty;

  String _token = "";
  String get tokens => _token;
  String _amount = "";
  String get amount => _amount;
  String _symbol = "";
  String get symbol => _symbol;


  Future<void> fetchMyWalletHistory(int pageKey) async {
    try {
      // Cancel current operation (if any)
      _walletHistoryOp?.cancel();

      if (_isWalletHistoryEmpty) {
        _isWalletHistoryEmpty = false;
        notifyListeners();
      }

      // Create Request
      final request = PaymentTransactionsRequest(
        page: pageKey,
        query: _appliedSearchQuery,
      );
      final myWalletHistory = async.CancelableOperation.fromFuture(
        locator<KwotData>().accountRepository.fetchMyWalletHistory(request),
        onCancel: () {
          walletHistoryController.error = "Cancelled.";
        },
      );
      _walletHistoryOp = myWalletHistory;

      // Listen for result
      final result = await myWalletHistory.value;
      if (!result.isSuccess()) {
        walletHistoryController.error = result.error();
        return;
      }

      final page = result.data();
      if (request.query == null && page.totalItems == 0) {
        _isWalletHistoryEmpty = true;
        notifyListeners();
      }

      final currentItemCount =
          walletHistoryController.itemList?.length ?? 0;
      final isLastPage = page.isLastPage(currentItemCount);
      if (isLastPage) {
        walletHistoryController.appendLastPage(page.items??[]);
      } else {
        final nextPageKey = pageKey + 1;
        walletHistoryController.appendPage(page.items??[], nextPageKey);
      }
    } catch (error) {
      walletHistoryController.error = error;
    }
  }


  Future<void> fetchTotalTokens() async {
    try {

      // Cancel current operation (if any)
      _totalTokensOp?.cancel();

      if (resultTotalTokens != null) {
        resultTotalTokens = null;
        notifyListeners();
      }
      // Create Request
      _totalTokensOp = async.CancelableOperation.fromFuture(
          locator<KwotData>().accountRepository.fetchTotalTokens());

      // Wait for result
      resultTotalTokens = await _totalTokensOp?.value;
      _token = resultTotalTokens!.data().walletTokens =='null'? "0":resultTotalTokens!.data().walletTokens;


      if(SharedPref.prefs!.getString(SharedPref.userAmount)!= null){
       _amount = ((num.parse(SharedPref.prefs!.getString(SharedPref.userAmount)??"0")??0).toDouble() * (num.parse(resultTotalTokens!.data().walletAmount))).toString();
       }else{
        _amount = resultTotalTokens!.data().walletAmount;
      }

      if(SharedPref.prefs!.getString(SharedPref.currencySymbol)!= null){
        _symbol = SharedPref.prefs!.getString(SharedPref.currencySymbol)??"";
      }else{
        _symbol = resultTotalTokens!.data().currencySymbol;
      }

      if (resultTotalTokens!.isSuccess()) {
        _isTokenEmpty = true;
        notifyListeners();
      }
      notifyListeners();

    } catch (error) {
      resultTotalTokens = Result.error("Error: $error");
    }
    notifyListeners();
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

  @override
  PagingController<int, GetMyWalletHistory> controller() => walletHistoryController;

  @override
  void refresh({required bool resetPageKey, bool isForceRefresh = false}) {
    _walletHistoryOp?.cancel();

    if (resetPageKey) {
      walletHistoryController.refresh();
    } else {
      // TODO: @Github/EdsonBueno/infinite_scroll_pagination/issues/106
      walletHistoryController.retryLastFailedRequest();
    }
  }


}