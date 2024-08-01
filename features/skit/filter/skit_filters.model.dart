import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';

import 'skit_filters.bottomsheet.dart';

class SkitFiltersModel with ChangeNotifier {
  SkitFiltersModel({
    required SkitFilterSelectionArgs args,
  }) : _filter = args.filter;

  SkitFilter _filter;
  Result<List<SkitCategory>>? _categoriesResult;
  Result<List<SkitCategory>>? _searchResult;

  Result<List<SkitCategory>>? get categoriesResult =>
      _searchResult ?? _categoriesResult;

  SkitFilter get selectedFilter => _filter;

  List<SkitCategory> get selectedCategories => selectedFilter.categories;

  SkitSortOrder get selectedSortOrder => selectedFilter.sortOrder;

  void fetchSkitCategories() async {
    if (_categoriesResult != null) {
      _categoriesResult = null;
      notifyListeners();
    }

    final result = await locator<KwotData>().skitsRepository.fetchSkitCategories();
    _categoriesResult = result;
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

    final result = _categoriesResult;
    if (result == null || !result.isSuccess()) {
      _searchResult = null;
      notifyListeners();
      return;
    }

    final filteredCategories = result.data().where((category) {
      return category.title.toLowerCase().contains(searchQuery);
    }).toList();
    _searchResult = Result.success(filteredCategories);
    notifyListeners();
  }

  bool canClearSelection() {
    final result = _categoriesResult;
    if (result == null || !result.isSuccess()) {
      return false;
    }

    // 0: defaultCategory
    // 1/1+: Categories
    return ((result.peek()?.length) ?? 0) > 1;
  }

  bool canApplySelection() {
    return canClearSelection();
  }

  bool canChangeSortOption() {
    return canClearSelection();
  }

  /*
   * SEARCH QUERY
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

  /*
   * SKIT CATEGORY
   */

  bool isCategorySelected(SkitCategory category) {
    final index = selectedFilter.categories.indexWhere((element) {
      return (element.id == category.id);
    });
    return index != -1;
  }

  void toggleCategorySelection(SkitCategory category) {
    final categories = _filter.categories.toList();
    if (isCategorySelected(category)) {
      categories.removeWhere((element) => (element.id == category.id));
    } else {
      categories.add(category);
    }
    _filter = _filter.copyWith(categories: categories);
    notifyListeners();
  }

  /*
   * SKIT SORT ORDER
   */

  void setSortOrder(SkitSortOrder sortOrder) {
    _filter = _filter.copyWith(sortOrder: sortOrder);
    notifyListeners();
  }
}
