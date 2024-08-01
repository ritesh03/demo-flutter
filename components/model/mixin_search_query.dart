import 'package:flutter/material.dart'  hide SearchBar;

import 'mixin_on_refresh.dart';

mixin SearchQueryMixin on ChangeNotifier, OnRefreshMixin {
  String? _searchQuery;

  String? get searchQuery => _searchQuery;

  bool get hasSearchQuery => _searchQuery != null;

  void updateSearchQuery(String? text) {
    String? nextQuery = text?.trim();
    if (nextQuery != null && nextQuery.isEmpty) {
      nextQuery = null;
    }

    if (_searchQuery != nextQuery) {
      _searchQuery = nextQuery;
      onRefresh();
      notifyListeners();
    }
  }

  void clearSearchQuery() {
    updateSearchQuery(null);
  }
}
