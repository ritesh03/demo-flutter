import 'dart:async';

import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';

class SearchCatalog {
  final SearchCatalogRequest request;
  final SearchCatalogType type;
  final Result<ListPage<SearchResultItem>> itemsResult;

  SearchCatalog({
    required this.request,
    required this.type,
    required this.itemsResult,
  });
}

class SearchCatalogRequest {
  SearchCatalogRequest({
    required this.kind,
    required this.page,
    required this.searchPlace,
    required this.query,
  });

  final SearchKind? kind;
  final int page;
  final SearchPlace searchPlace;
  final String? query;
}

enum SearchCatalogType { searchResults, recentSearches, trendingSearches }

class SearchCatalogUseCase {
  Future<SearchCatalog> searchCatalog(
    SearchCatalogRequest catalogRequest,
  ) async {
    final query = catalogRequest.query;
    if (query == null || query.trim().isEmpty) {
      final searchCatalogue = await fetchRecentSearches(catalogRequest);
      if (searchCatalogue != null) {
        return searchCatalogue;
      }
    } else {
      final searchCatalogue = await fetchSearchResults(catalogRequest);
      if (searchCatalogue != null) {
        return searchCatalogue;
      }
    }

    final searchCatalogue = await fetchTrendingSearches(catalogRequest);
    if (searchCatalogue != null) {
      return searchCatalogue;
    }

    return SearchCatalog(
        request: catalogRequest,
        type: SearchCatalogType.trendingSearches,
        itemsResult: Result.empty());
  }

  Future<SearchCatalog?> fetchRecentSearches(
      SearchCatalogRequest catalogRequest) async {
    final request = RecentSearchesRequest(
      page: catalogRequest.page,
      kind: catalogRequest.kind,
    );
    final result =
        await locator<KwotData>().searchRepository.fetchRecentSearches(request);
    if (!result.isSuccess() || (!result.isEmpty() && !result.data().isEmpty)) {
      return SearchCatalog(
          request: catalogRequest,
          type: SearchCatalogType.recentSearches,
          itemsResult: result);
    }

    return null;
  }

  Future<SearchCatalog?> fetchSearchResults(
      SearchCatalogRequest catalogRequest) async {
    final request = SearchRequest(
      page: catalogRequest.page,
      query: catalogRequest.query!,
      searchPlace: catalogRequest.searchPlace,
      kind: catalogRequest.kind,
    );
    final result = await locator<KwotData>().searchRepository.search(request);
    if (!result.isSuccess() || (!result.isEmpty() && !result.data().isEmpty)) {
      return SearchCatalog(
          request: catalogRequest,
          type: SearchCatalogType.searchResults,
          itemsResult: result);
    }

    return null;
  }

  Future<SearchCatalog?> fetchTrendingSearches(
      SearchCatalogRequest catalogRequest) async {
    final request = TrendingSearchesRequest(
      page: catalogRequest.page,
      kind: catalogRequest.kind,
    );
    final result = await locator<KwotData>()
        .searchRepository
        .fetchTrendingSearches(request);
    if (!result.isSuccess() || (!result.isEmpty() && !result.data().isEmpty)) {
      return SearchCatalog(
          request: catalogRequest,
          type: SearchCatalogType.trendingSearches,
          itemsResult: result);
    }

    return null;
  }
}
