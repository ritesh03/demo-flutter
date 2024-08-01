import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/widgets/list/item_list.model.dart';
import 'package:kwotmusic/components/widgets/list/item_list_util.dart';
import 'package:kwotmusic/features/podcastcategory/picker/podcast_category_picker.bottomsheet.dart';
import 'package:wrapped_infinite_scroll_pagination/infinite_scroll_pagination.dart';

class PodcastEpisodeListArgs {
  PodcastEpisodeListArgs({required this.availableFeed});

  final Feed<PodcastEpisode> availableFeed;
}

class PodcastEpisodesModel with ChangeNotifier, ItemListModel<PodcastEpisode> {
  //=
  final Feed<PodcastEpisode> _initialFeed;
  ItemListViewMode _viewMode = ItemListViewMode.list;

  PodcastEpisodesModel({
    required PodcastEpisodeListArgs args,
  }) : _initialFeed = args.availableFeed;

  String? _appliedSearchQuery;
  List<PodcastCategory>? _selectedCategories;

  async.CancelableOperation<Result<ListPage<PodcastEpisode>>>?
      _podcastEpisodesOp;
  late final PagingController<int, PodcastEpisode> _podcastEpisodesController;

  void init() {
    _viewMode = createViewModeFromFeed(_initialFeed);
    _podcastEpisodesController =
        PagingController<int, PodcastEpisode>(firstPageKey: 1);

    _podcastEpisodesController.addPageRequestListener((pageKey) {
      _fetchPodcastEpisodes(pageKey);
    });
  }

  bool get canSearchInFeed => _initialFeed.searchable;

  @override
  void dispose() {
    _podcastEpisodesOp?.cancel();
    _podcastEpisodesController.dispose();
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
      _podcastEpisodesController.refresh();
      notifyListeners();
    }
  }

  void clearSearchQuery() {
    if (_appliedSearchQuery != null) {
      _appliedSearchQuery = null;
      _podcastEpisodesController.refresh();
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
    _podcastEpisodesController.refresh();
    notifyListeners();
  }

  void removeSelectedCategory(PodcastCategory category) {
    _selectedCategories?.removeWhere((element) => (element.id == category.id));
    _podcastEpisodesController.refresh();
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
   * API: Podcast Episode List
   */

  Future<void> _fetchPodcastEpisodes(int pageKey) async {
    try {
      // Cancel current operation (if any)
      _podcastEpisodesOp?.cancel();

      final searchQuery = _appliedSearchQuery?.trim();
      final hasSearchQuery = searchQuery != null && searchQuery.isNotEmpty;

      final selectedCategories = _selectedCategories;
      final hasSelectedCategories =
          selectedCategories != null && selectedCategories.isNotEmpty;

      // Create Request
      final request = PodcastEpisodesRequest(
        categories: _selectedCategories,
        feedId: !canSearchInFeed && (hasSearchQuery || hasSelectedCategories)
            ? null
            : _initialFeed.id,
        page: pageKey,
        query: searchQuery,
      );
      _podcastEpisodesOp = async.CancelableOperation.fromFuture(
        locator<KwotData>().podcastsRepository.fetchPodcastEpisodes(request),
        onCancel: () {
          _podcastEpisodesController.error = "Cancelled.";
        },
      );

      // Listen for result
      _podcastEpisodesOp?.value.then((result) {
        if (!result.isSuccess()) {
          _podcastEpisodesController.error = result.error();
          return;
        }

        final page = result.data();
        final currentItemCount =
            _podcastEpisodesController.itemList?.length ?? 0;
        final isLastPage = page.isLastPage(currentItemCount);
        if (isLastPage) {
          _podcastEpisodesController.appendLastPage(page.items??[]);
        } else {
          final nextPageKey = pageKey + 1;
          _podcastEpisodesController.appendPage(page.items??[], nextPageKey);
        }
      });
    } catch (error) {
      _podcastEpisodesController.error = error;
    }
  }

  /*
   * ItemListModel<Feed>
   */

  @override
  PagingController<int, PodcastEpisode> controller() =>
      _podcastEpisodesController;

  @override
  void refresh({
    required bool resetPageKey,
    bool isForceRefresh = false,
  }) {
    _podcastEpisodesOp?.cancel();

    if (resetPageKey) {
      _podcastEpisodesController.refresh();
    } else {
      // TODO: @Github/EdsonBueno/infinite_scroll_pagination/issues/106
      _podcastEpisodesController.retryLastFailedRequest();
    }
  }
}
