import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';

class CountryPickerModel with ChangeNotifier {
  CountryPickerModel({required this.selectedCountry});

  final Country? selectedCountry;
  Result<List<Country>>? _countriesResult;
  Result<List<Country>>? _searchResult;

  Result<List<Country>>? get countriesResult =>
      _searchResult ?? _countriesResult;

  void fetchCountries() async {
    if (_countriesResult != null) {
      _countriesResult = null;
      notifyListeners();
    }

    final result =
        await locator.get<KwotData>().miscRepository.fetchCountries();
    _countriesResult = result;
    if (_appliedSearchQuery != null) {
      _search();
    }

    notifyListeners();
  }

  void _search() {
    final searchQuery = _appliedSearchQuery?.toLowerCase();
    if (searchQuery == null || searchQuery.isEmpty) {
      _searchResult = null;
      notifyListeners();
      return;
    }

    final result = _countriesResult;
    if (result == null || !result.isSuccess()) {
      _searchResult = null;
      notifyListeners();
      return;
    }

    final filteredCountries = result.data().where((country) {
      return country.name.toLowerCase().contains(searchQuery) ||
          country.phoneCode.contains(searchQuery);
    }).toList();
    _searchResult = Result.success(filteredCountries);
    notifyListeners();
  }

  /*
   * Search Query
   */

  String? _appliedSearchQuery;

  String? get appliedSearchQuery => _appliedSearchQuery;

  void updateSearchQuery(String text) {
    if (_appliedSearchQuery != text) {
      _appliedSearchQuery = text;
      _search();
    }
  }

  void clearSearchQuery() {
    if (_appliedSearchQuery != null) {
      _appliedSearchQuery = null;
      _search();
    }
  }
}
