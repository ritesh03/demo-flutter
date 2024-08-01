import 'dart:async';

import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/widgets/list/item_list.model.dart';
import 'package:kwotmusic/events/events.dart';
import 'package:kwotmusic/features/skit/filter/skit_filters.bottomsheet.dart';
import 'package:kwotmusic/util/paging_controller.ext.dart';
import 'package:wrapped_infinite_scroll_pagination/infinite_scroll_pagination.dart';

class SkitListArgs {
  SkitListArgs({this.availableFeed});

  final Feed<Skit>? availableFeed;
}

class SkitsModel with ChangeNotifier, ItemListModel<Skit> {
  //=
  final Feed<Skit>? _initialFeed;

  late final StreamSubscription _eventsSubscription;

  SkitsModel({
    required SkitListArgs args,
  }) : _initialFeed = args.availableFeed {
    _eventsSubscription = _listenToEvents();
  }

  String? _appliedSearchQuery;
  SkitType selectedSkitType = SkitType.video;
  SkitFilter _skitFilter = SkitFilter();

  async.CancelableOperation<Result<ListPage<Skit>>>? _skitsOp;
  late final PagingController<int, Skit> _skitsController;

  void init() {
    /// NOTE: We are not using "initialFeed" here, because
    /// it might contain a mix of audio/video skits.
    // final initialFeed = _initialFeed;
    // if (initialFeed != null) {
    //   _skitsController = PagingController<int, Skit>.fromValue(
    //       PagingState<int, Skit>(
    //           nextPageKey: 2, error: null, itemList: initialFeed.items),
    //       firstPageKey: 1);
    // } else {
    _skitsController = PagingController<int, Skit>(firstPageKey: 1);
    // }

    _skitsController.addPageRequestListener((pageKey) {
      _fetchSkits(pageKey);
    });
  }

  bool get canSearchInFeed => _initialFeed?.searchable ?? false;

  @override
  void dispose() {
    _eventsSubscription.cancel();
    _skitsOp?.cancel();
    _skitsController.dispose();
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
      _skitsController.refresh();
      notifyListeners();
    }
  }

  void clearSearchQuery() {
    if (_appliedSearchQuery != null) {
      _appliedSearchQuery = null;
      _skitsController.refresh();
      notifyListeners();
    }
  }

  /*
   * Skit Filter
   */

  bool get isFilterApplied => !_skitFilter.isDefault;

  SkitFilter get skitFilter => _skitFilter;

  List<SkitCategory> get selectedCategories => _skitFilter.categories.toList();

  void setSelectedFilter(SkitFilter skitFilter) {
    _skitFilter = skitFilter;
    _skitsController.refresh();
    notifyListeners();
  }

  void removeSelectedCategory(SkitCategory category) {
    final categories = _skitFilter.categories.toList();
    categories.removeWhere((element) => (element.id == category.id));

    _skitFilter = _skitFilter.copyWith(categories: categories);
    _skitsController.refresh();
    notifyListeners();
  }

  void resetSortOrder() {
    if (_skitFilter.sortOrder == SkitFilter.defaultSortOrder) {
      return;
    }

    _skitFilter = _skitFilter.copyWith(sortOrder: SkitFilter.defaultSortOrder);
    _skitsController.refresh();
    notifyListeners();
  }

  SkitFilterSelectionArgs createSkitCategoryPickerArgs() {
    return SkitFilterSelectionArgs(filter: _skitFilter);
  }

  /*
   * Skit Type
   */

  void setSelectedSkitType(SkitType skitType) {
    if (selectedSkitType == skitType) {
      return;
    }

    selectedSkitType = skitType;
    _skitsOp?.cancel();
    _skitsController.refresh();
    notifyListeners();
  }

  /*
   * API: Skit List
   */

  Future<void> _fetchSkits(int pageKey) async {
    try {
      // Cancel current operation (if any)
      _skitsOp?.cancel();

      final searchQuery = _appliedSearchQuery?.trim();
      final hasSearchQuery = searchQuery != null && searchQuery.isNotEmpty;

      final selectedCategories = this.selectedCategories;
      final hasSelectedCategories = selectedCategories.isNotEmpty;

      // Create Request
      final request = SkitsRequest(
        categories: selectedCategories,
        sortOrder: _skitFilter.sortOrder,
        type: selectedSkitType,
        page: pageKey,
        query: searchQuery,
        feedId: !canSearchInFeed && (hasSearchQuery || hasSelectedCategories)
            ? null
            : _initialFeed?.id,
      );
      _skitsOp = async.CancelableOperation.fromFuture(
        locator<KwotData>().skitsRepository.fetchSkits(request),
        onCancel: () {
          _skitsController.error = "Cancelled.";
        },
      );

      // Listen for result
      _skitsOp?.value.then((result) {
        if (!result.isSuccess()) {
          _skitsController.error = result.error();
          return;
        }

        final page = result.data();
        final currentItemCount = _skitsController.itemList?.length ?? 0;
        final isLastPage = page.isLastPage(currentItemCount);
        if (isLastPage) {
          _skitsController.appendLastPage(page.items??[]);
        } else {
          final nextPageKey = pageKey + 1;
          _skitsController.appendPage(page.items??[], nextPageKey);
        }
      });
    } catch (error) {
      _skitsController.error = error;
    }
  }

  /*
   * ItemListModel<Feed>
   */

  @override
  PagingController<int, Skit> controller() => _skitsController;

  @override
  void refresh({
    required bool resetPageKey,
    bool isForceRefresh = false,
  }) {
    _skitsOp?.cancel();

    if (resetPageKey) {
      _skitsController.refresh();
    } else {
      // TODO: @Github/EdsonBueno/infinite_scroll_pagination/issues/106
      _skitsController.retryLastFailedRequest();
    }
  }

  /*
   * EVENT:
   *  SkitLikeUpdatedEvent,
   */

  StreamSubscription _listenToEvents() {
    return eventBus.on().listen((event) {
      if (event is SkitLikeUpdatedEvent) {
        return _handleSkitLikeEvent(event);
      }
    });
  }

  void _handleSkitLikeEvent(SkitLikeUpdatedEvent event) {
    _skitsController.updateItems<Skit>((index, skit) {
      return event.update(skit);
    });
  }
}
