import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/widgets/list/item_list.model.dart';
import 'package:kwotmusic/components/widgets/list/item_list_util.dart';
import 'package:wrapped_infinite_scroll_pagination/infinite_scroll_pagination.dart';

class PodcastCategoryListArgs {
  PodcastCategoryListArgs({required this.availableFeed});

  final Feed<PodcastCategory> availableFeed;
}

class PodcastCategoriesModel
    with ChangeNotifier, ItemListModel<PodcastCategory> {
  //=
  final Feed<PodcastCategory> _initialFeed;
  ItemListViewMode _viewMode = ItemListViewMode.list;

  PodcastCategoriesModel({
    required PodcastCategoryListArgs args,
  }) : _initialFeed = args.availableFeed;

  String? _appliedSearchQuery;

  async.CancelableOperation<Result<List<PodcastCategory>>>?
      _podcastCategoriesOp;
  late final PagingController<int, PodcastCategory>
      _podcastCategoriesController;

  void init() {
    _viewMode = createViewModeFromFeed(_initialFeed);
    _podcastCategoriesController =
        PagingController<int, PodcastCategory>(firstPageKey: 1);

    _podcastCategoriesController.addPageRequestListener((pageKey) {
      _fetchPodcastCategories(pageKey);
    });
  }

  bool get canSearchInFeed => _initialFeed.searchable;

  @override
  void dispose() {
    _podcastCategoriesOp?.cancel();
    _podcastCategoriesController.dispose();
    super.dispose();
  }

  /*
   * Page
   */

  String? get pageTitle {
    final searchQuery = _appliedSearchQuery;
    if (!canSearchInFeed &&
        searchQuery != null &&
        searchQuery.trim().isNotEmpty) {
      return null;
    }

    return _initialFeed.pageTitle;
  }

  /*
   * Search Query
   */

  String? get appliedSearchQuery => _appliedSearchQuery;

  void updateSearchQuery(String text) {
    if (_appliedSearchQuery != text) {
      _appliedSearchQuery = text;
      _podcastCategoriesController.refresh();
      notifyListeners();
    }
  }

  void clearSearchQuery() {
    if (_appliedSearchQuery != null) {
      _appliedSearchQuery = null;
      _podcastCategoriesController.refresh();
      notifyListeners();
    }
  }

  /*
   * View Mode
   */

  ItemListViewMode get viewMode => _viewMode;

  int get viewColumnCount {
    switch (viewMode) {
      case ItemListViewMode.list:
        return 1;
      case ItemListViewMode.grid:
        return 2;
    }
  }

  void showListViewMode() {
    _viewMode = ItemListViewMode.list;
    notifyListeners();
  }

  void showGridViewMode() {
    _viewMode = ItemListViewMode.grid;
    notifyListeners();
  }

  /*
   * API: Podcast Category List
   */

  Future<void> _fetchPodcastCategories(int pageKey) async {
    try {
      // Cancel current operation (if any)
      _podcastCategoriesOp?.cancel();

      final searchQuery = _appliedSearchQuery?.trim();
      final hasSearchQuery = searchQuery != null && searchQuery.isNotEmpty;

      // Create Request
      final request = PodcastCategoriesRequest(
        query: searchQuery,
        feedId: !canSearchInFeed && hasSearchQuery ? null : _initialFeed.id,
      );
      _podcastCategoriesOp = async.CancelableOperation.fromFuture(
        locator<KwotData>().podcastsRepository.fetchPodcastCategories(request),
        onCancel: () {
          _podcastCategoriesController.error = "Cancelled.";
        },
      );

      // Listen for result
      _podcastCategoriesOp?.value.then((result) {
        if (!result.isSuccess()) {
          _podcastCategoriesController.error = result.error();
          return;
        }

        final categories = result.data();
        _podcastCategoriesController.appendLastPage(categories);
      });
    } catch (error) {
      _podcastCategoriesController.error = error;
    }
  }

  /*
   * ItemListModel<Feed>
   */

  @override
  PagingController<int, PodcastCategory> controller() =>
      _podcastCategoriesController;

  @override
  void refresh({
    required bool resetPageKey,
    bool isForceRefresh = false,
  }) {
    _podcastCategoriesOp?.cancel();
    _podcastCategoriesController.refresh();
  }
}
