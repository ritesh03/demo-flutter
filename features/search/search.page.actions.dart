import 'package:kwotdata/models/models.dart';

abstract class SearchPageActionCallback {
  void onBackPressed();

  void onSearchResultItemTap(SearchResultItem item);

  void onSearchResultItemOptionsTap(SearchResultItem item);

  void onRecentSearchResultItemTap(SearchResultItem item);

  void onRemoveRecentSearchResultItemTap(SearchResultItem item);

  void onClearRecentSearchesTap();
}
