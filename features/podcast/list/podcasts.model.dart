import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/widgets/list/item_list.model.dart';
import 'package:kwotmusic/components/widgets/list/item_list_util.dart';
import 'package:kwotmusic/features/podcastcategory/picker/podcast_category_picker.bottomsheet.dart';
import 'package:wrapped_infinite_scroll_pagination/infinite_scroll_pagination.dart';

class PodcastListArgs {
  PodcastListArgs({
    this.availableFeed,
    this.selectedCategory,
  });

  final Feed<Podcast>? availableFeed;
  final PodcastCategory? selectedCategory;
}

class PodcastsModel with ChangeNotifier, ItemListModel<Podcast> {
  //=
  final Feed<Podcast>? _initialFeed;
  final PodcastCategory? _initialCategory;

  ItemListViewMode _viewMode = ItemListViewMode.list;

  PodcastsModel({
    required PodcastListArgs args,
  })  : _initialFeed = args.availableFeed,
        _initialCategory = args.selectedCategory;

  String? _appliedSearchQuery;
  List<PodcastCategory>? _selectedCategories;
  async.CancelableOperation<Result<ListPage<Podcast>>>? _podcastsOp;
  late final PagingController<int, Podcast> _podcastsController;

  void init() {
    final initialFeed = _initialFeed;
    if (initialFeed != null) {
      _viewMode = createViewModeFromFeed(initialFeed);
    }

    _podcastsController = PagingController<int, Podcast>(firstPageKey: 1);

    final initialCategory = _initialCategory;
    if (initialCategory != null) {
      _selectedCategories = [initialCategory];
    }

    _podcastsController.addPageRequestListener((pageKey) {
      _fetchPodcasts(pageKey);
    });
  }

  bool get canSearchInFeed => _initialFeed?.searchable ?? false;

  @override
  void dispose() {
    _podcastsOp?.cancel();
    _podcastsController.dispose();
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

    final feedTitle = _initialFeed?.pageTitle;
    if (feedTitle != null) {
      return feedTitle;
    }

    return null;
  }

  /*
   * Search Query
   */

  String? get appliedSearchQuery => _appliedSearchQuery;

  void updateSearchQuery(String text) {
    if (_appliedSearchQuery != text) {
      _appliedSearchQuery = text;
      _podcastsController.refresh();
      notifyListeners();
    }
  }

  void clearSearchQuery() {
    if (_appliedSearchQuery != null) {
      _appliedSearchQuery = null;
      _podcastsController.refresh();
      notifyListeners();
    }
  }

  /*
   * Podcast Category
   */

  List<PodcastCategory>? get selectedCategories =>
      _selectedCategories?.toList();

  bool get isFilterApplied => (_selectedCategories?.isNotEmpty ?? false);

  void setSelectedCategories(List<PodcastCategory> categories) {
    final selectedCategories = _selectedCategories ?? [];
    if (selectedCategories.isEmpty && categories.isEmpty) {
      notifyListeners();
      return;
    }

    _selectedCategories = categories;
    _podcastsController.refresh();
    notifyListeners();
  }

  void removeSelectedCategory(PodcastCategory category) {
    _selectedCategories?.removeWhere((element) => (element.id == category.id));
    _podcastsController.refresh();
    notifyListeners();
  }

  PodcastCategoryPickerArgs createPodcastCategoryPickerArgs() {
    final selectedCategories = _selectedCategories?.toList() ?? [];
    return PodcastCategoryPickerArgs(selectedCategories: selectedCategories);
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
   * API: Podcast List
   */

  Future<void> _fetchPodcasts(int pageKey) async {
    try {
      // Cancel current operation (if any)
      _podcastsOp?.cancel();

      final searchQuery = _appliedSearchQuery?.trim();
      final hasSearchQuery = searchQuery != null && searchQuery.isNotEmpty;

      final selectedCategories = _selectedCategories;
      final hasSelectedCategories =
          selectedCategories != null && selectedCategories.isNotEmpty;

      // Create Request
      final request = PodcastsRequest(
        categories: _selectedCategories,
        feedId: !canSearchInFeed && (hasSearchQuery || hasSelectedCategories)
            ? null
            : _initialFeed?.id,
        page: pageKey,
        query: searchQuery,
      );
      _podcastsOp = async.CancelableOperation.fromFuture(
        locator<KwotData>().podcastsRepository.fetchPodcasts(request),
        onCancel: () {
          _podcastsController.error = "Cancelled.";
        },
      );

      // Listen for result
      _podcastsOp?.value.then((result) {
        if (!result.isSuccess()) {
          _podcastsController.error = result.error();
          return;
        }

        final page = result.data();
        final currentItemCount = _podcastsController.itemList?.length ?? 0;
        final isLastPage = page.isLastPage(currentItemCount);
        if (isLastPage) {
          _podcastsController.appendLastPage(page.items??[]);
        } else {
          final nextPageKey = pageKey + 1;
          _podcastsController.appendPage(page.items??[], nextPageKey);
        }
      });
    } catch (error) {
      _podcastsController.error = error;
    }
  }

  /*
   * ItemListModel<Podcast>
   */

  @override
  PagingController<int, Podcast> controller() => _podcastsController;

  @override
  void refresh({
    required bool resetPageKey,
    bool isForceRefresh = false,
  }) {
    _podcastsOp?.cancel();

    if (resetPageKey) {
      _podcastsController.refresh();
    } else {
      // TODO: @Github/EdsonBueno/infinite_scroll_pagination/issues/106
      _podcastsController.retryLastFailedRequest();
    }
  }
}
