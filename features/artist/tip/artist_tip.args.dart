import 'package:flutter/cupertino.dart';
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:async/async.dart' as async;
import 'package:kwotdata/models/artist/subscription.plan.artist.dart';
import 'package:kwotdata/models/mywallet/get_tokens_model.dart';

import '../../../components/widgets/blocking_progress.dialog.dart';

class ArtistTipArgs {
  final Artist artist;
  final bool haveToken;

  ArtistTipArgs({
    required this.artist,
    required this.haveToken
  });
}
class ArtistTipModel extends ChangeNotifier{
   late final Artist artist;
   final bool  haveToken;
   ArtistTipModel({required this.artist,required this.haveToken});
   final tokenController = TextEditingController();

   async.CancelableOperation<Result<GetTotalTokens>>? _totalTokensOp;
   Result<GetTotalTokens>? resultTotalTokens;
   async.CancelableOperation<Result<BillingDetail>>? _billingDetailOp;
   Result<BillingDetail>? billingDetailResult;
   Result<Plan>? leaveFanClubResult;
   async.CancelableOperation<Result<Plan>>? _leaveFanClub;
   String? tokens;




 void init(){
  fetchTotalTokens();
  fetchBillingDetail();
 }

 @override
  void dispose() {
    _totalTokensOp!.cancel();
    _billingDetailOp!.cancel();
    super.dispose();
  }

   bool _isTokenEmpty = false;

   bool get isTokenEmpty => _isTokenEmpty;


   String? _addressLine1InputError;

   String? get addressLine1InputError => _addressLine1InputError;

   void onAddressLine1InputChanged(String text) {
     notifyAddressLine1InputError(null);
   }

   void notifyAddressLine1InputError(String? error) {
     _addressLine1InputError = error;
     notifyListeners();
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
       tokens = resultTotalTokens!.data().walletTokens;

       if (resultTotalTokens!.isSuccess()) {
         _isTokenEmpty = true;
         tokens = resultTotalTokens!.data().walletTokens;
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



   Future<bool> sendTip(context,) async {
     try {
       showBlockingProgressDialog(context);
       // Cancel current operation (if any)
       _leaveFanClub?.cancel();

       if (leaveFanClubResult != null) {
         leaveFanClubResult = null;
         notifyListeners();
       }
       // Create Request

       _leaveFanClub = async.CancelableOperation.fromFuture(
           locator<KwotData>().artistsRepository.sendTip(id: artist.id, amount: int.parse(tokenController.text)));
       // Wait for result
       leaveFanClubResult = await _leaveFanClub?.value;
       if (leaveFanClubResult != null) {
         hideBlockingProgressDialog(context);
       }
       if (leaveFanClubResult!.isSuccess()) {
         return true;
       }
       else {
         return false;
       }
     } catch (error) {
       hideBlockingProgressDialog(context);
       leaveFanClubResult = Result.error("Error: $error");
       return false;
     }
   }



}