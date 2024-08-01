

// ignore_for_file: constant_identifier_names



import 'package:shared_preferences/shared_preferences.dart';

class SharedPref{
  static SharedPreferences? prefs;
  static const userAmount ="amount";
  static const currencySymbol = "symbol";

  static  clear(){
    prefs?.remove(userAmount);
    prefs?.remove(currencySymbol);
  }
}
