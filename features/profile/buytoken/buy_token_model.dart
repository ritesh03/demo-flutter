import 'dart:async';
import 'package:async/async.dart' as async;
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotdata/models/artist/subscription.artist.model.dart';
import 'package:kwotdata/models/result.dart';
import 'package:kwotmusic/core.dart';

import '../../../components/widgets/blocking_progress.dialog.dart';
import '../../../components/widgets/notificationbar/notification_bar.dart';
import '../../../util/get_context.dart';

class BuyTokenModel extends ChangeNotifier{
  async.CancelableOperation<Result<Plan>>? _buyTokenOp;
  Result<Plan>? buyTokenResult;

  /// Product ids
  String productIdKM100 = 'KM100';
  String productIdKM1000 = 'KM1000';
  String productIdKM200 = 'KM200';
  String productIdKM2000 = 'KM2000';
  String productIdKM500 = 'KM500';

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  /// variables
  /// checks if the inAppPurchase API is available on this device
  bool isInAppPurchaseAvailable = false;
// keeps a list of products queried from Playstore or app store
  List<ProductDetails> products = [];
// List of users past purchases
  List<PurchaseDetails> _purchases = [];
// subscription that listens to a stream of updates to purchase details
  late StreamSubscription _subscription;
  int? selectedIndex;
  BuildContext? context;

  ProductDetails? selectedProduct;


  /// color code
  List<List<Color>> colorList = [
    [Color(0xFF9C06B4), Color(0xFF3A0E55)],
    [Color(0xFF06B42C), Color(0xFF0E552A)],
    [Color(0xFF0692B4), Color(0xFF0E4455)],
    [Color(0xFF9CB406), Color(0xFF54550E)],
    [Color(0xFF06B42C), Color(0xFF0E552A)],
  ];
  List<Color> getRandomColor() {
    final random = Random();
    final index = random.nextInt(colorList.length);
    final selectedColors = colorList[index];
    return selectedColors;
  }

   init(BuildContext context){
     context = context;
     _initialize( context);


   }


   onTapProduct(ProductDetails productDetails,int index){
     selectedIndex = index;
     selectedProduct = productDetails;
     notifyListeners();
   }


  Future<void> _initialize(BuildContext context) async {
    // Check availability of InApp Purchases
    isInAppPurchaseAvailable = await _inAppPurchase.isAvailable();
    // perform our async calls only when in-app purchase is available
    if(isInAppPurchaseAvailable){
      await _getUserProducts(context);

      _subscription = _inAppPurchase.purchaseStream.listen(
        ((value){
        _onPurchaseUpdate(value, context);
      }),
      onDone: _updateStreamOnDone,
      onError: _updateStreamOnError,
      );

    }
  }


  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList,BuildContext context) async {
    // Handle purchases here

    for (var purchaseDetails in purchaseDetailsList) {
      await _handlePurchase(purchaseDetails,  context);
    }
    notifyListeners();
  }

  Future<void> _handlePurchase(PurchaseDetails purchaseDetails,BuildContext context) async {
    showBlockingProgressDialog(context);
    if (purchaseDetails.status == PurchaseStatus.purchased) {
      buyTokens(context, purchaseDetails.productID.replaceAll("KM", "")).then((value) {
        if(value){
          Navigator.pop(context,true);
          showDefaultNotificationBar(
            const NotificationBarInfo.success(message:"Tokens purchased successfully"),
          );
        }else{
          Navigator.of(context, rootNavigator: false).pop();
          showDefaultNotificationBar(
            const NotificationBarInfo.error(message:"Something went wrong"),
          );
        }
      });
    }else if(purchaseDetails.status == PurchaseStatus.canceled){
      hideBlockingProgressDialog(context);
    }else if(purchaseDetails.status == PurchaseStatus.error){
      hideBlockingProgressDialog(context);
    }else if(purchaseDetails.status == PurchaseStatus.pending){
     // hideBlockingProgressDialog(context);
    }
    if (purchaseDetails.pendingCompletePurchase) {
      await _inAppPurchase.completePurchase(purchaseDetails);
      hideBlockingProgressDialog(context);
    }
  }

  void _updateStreamOnDone() {
    _subscription.cancel();
    hideBlockingProgressDialog(NavigationService.navigatorKey.currentContext!);
  }

  void _updateStreamOnError(dynamic error) {
    //Handle error here
    hideBlockingProgressDialog(NavigationService.navigatorKey.currentContext!);
  }

  // Method to retrieve product list
  Future<void> _getUserProducts(BuildContext context) async {
    showBlockingProgressDialog(NavigationService.navigatorKey.currentContext!);
    Set<String> ids = {productIdKM100,productIdKM200,productIdKM500,productIdKM1000,productIdKM2000};
    ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(ids);
   List<ProductDetails> productGet = response.productDetails;
    productGet.sort((a, b) => removeString(a.title).compareTo(removeString(b.title)));
    products = productGet;
    hideBlockingProgressDialog(NavigationService.navigatorKey.currentContext!);
    notifyListeners();

  }
int removeString(String input){
   RegExp numericRegex = RegExp(r'\d+');
   String? numericString = numericRegex.stringMatch(input);
   return int.parse(numericString??"0");
 }


  // Method to purchase a product
  void buyProduct(BuildContext context) async{

    if(selectedProduct !=  null) {
      showBlockingProgressDialog(NavigationService.navigatorKey.currentContext!);
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: selectedProduct!);
     var result = await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam, autoConsume: true).then((value) {

     });

      hideBlockingProgressDialog(NavigationService.navigatorKey.currentContext!);
    }

  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }


  Future<bool> buyTokens(context,String token) async {
    try {
      // Cancel current operation (if any)
      _buyTokenOp?.cancel();

      // Create Request
      _buyTokenOp = async.CancelableOperation.fromFuture(
          locator<KwotData>().subscriptionRepository.buyToken(token));
      // Wait for result
      buyTokenResult = (await _buyTokenOp?.value);
      if (buyTokenResult != null) {
        hideBlockingProgressDialog(NavigationService.navigatorKey.currentContext!);

      }
      if (buyTokenResult!.isSuccess()) {
        return true;
      }
      else {
        return false;
      }
    } catch (error) {
      hideBlockingProgressDialog(NavigationService.navigatorKey.currentContext!);
      buyTokenResult = Result.error("Error: $error");
      return false;
    }
  }



}