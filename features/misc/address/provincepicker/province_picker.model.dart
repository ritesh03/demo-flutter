import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';

class ProvincePickerModel with ChangeNotifier {
  ProvincePickerModel({
    required this.countryId,
    required this.selectedProvince,
  });

  final String countryId;
  final Province? selectedProvince;

  Result<List<Province>>? _provincesResult;
  Result<List<Province>>? _searchResult;

  Result<List<Province>>? get provincesResult =>
      _searchResult ?? _provincesResult;

  void fetchProvinces() async {
    if (_provincesResult != null) {
      _provincesResult = null;
      notifyListeners();
    }

    final request = ProvincesRequest(countryId: countryId);
    final result =
        await locator.get<KwotData>().miscRepository.fetchProvinces(request);
    _provincesResult = result;
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

    final result = _provincesResult;
    if (result == null || !result.isSuccess()) {
      _searchResult = null;
      notifyListeners();
      return;
    }

    final filteredProvinces = result.data().where((province) {
      return province.name.toLowerCase().contains(searchQuery);
    }).toList();
    _searchResult = Result.success(filteredProvinces);
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
