import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

Future<List<dynamic>> parseJsonArrayFromAssets(String assetsPath) async {
  return await rootBundle
      .loadString(assetsPath)
      .then((value) => jsonDecode(value));
}

Future<Map<String, dynamic>> parseJsonObjectFromAssets(
    String assetsPath) async {
  return await rootBundle
      .loadString(assetsPath)
      .then((value) => jsonDecode(value));
}
