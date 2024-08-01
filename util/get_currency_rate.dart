
import 'package:async/async.dart' as async;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotdata/models/getCurrencyRate/get_currency_rate.dart';
import 'package:kwotdata/src/repository/storage/storage_data_source.dart';
import 'package:kwotmusic/util/prefs.dart';

class GetCurrency {
  static GetCurrencyRate? currencyRateResult;
  static StorageDataSource storage = locator<StorageDataSource>();

  static async.CancelableOperation<dynamic>? _currencyOp;
  static Future<void> fetchCurrency() async {
    // Cancel current operation (if any)
    _currencyOp?.cancel();
    if (currencyRateResult != null) {
      currencyRateResult = null;
    }
    // Create Request
    _currencyOp = async.CancelableOperation.fromFuture(locator<KwotData>()
        .accountRepository
        .fetchCurrencyRate() );
    try{
      var res = await _currencyOp?.value;
      matchCountryCode(res);

    }catch(e){
      print("exception::  ${e}");
    }

  }

  static void matchCountryCode(Map<String, dynamic> responseData) {
    final Map<String, dynamic> rates = responseData['rates'];
    final String currencyCode = responseData['location']['currencyCode'];
    final String currencySymbol = responseData['location']['currencySymbol'];

    bool matchDOne = false;
    rates.forEach((key, value) {
      if (key == currencyCode) {
        matchDOne = true;
        String vale = value['value'].toString();
        SharedPref.prefs!.setString(SharedPref.userAmount, vale);
        SharedPref.prefs!.setString(SharedPref.currencySymbol, currencySymbol);
      }
    });
    if(!matchDOne){
      String vale = rates['USD']['value'].toString();
      SharedPref.prefs!.setString(SharedPref.userAmount, vale);
      SharedPref.prefs!.setString(SharedPref.currencySymbol, "\$");
    }
  }
}


