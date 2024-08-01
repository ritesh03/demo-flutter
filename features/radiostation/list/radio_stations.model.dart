import 'dart:async';

import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/widgets/list/item_list.model.dart';
import 'package:kwotmusic/components/widgets/list/item_list_util.dart';
import 'package:kwotmusic/events/events.dart';
import 'package:kwotmusic/util/paging_controller.ext.dart';
import 'package:wrapped_infinite_scroll_pagination/infinite_scroll_pagination.dart';

class RadioStationListArgs {
  RadioStationListArgs({required this.availableFeed});

  final Feed<RadioStation> availableFeed;
}

class RadioStationsModel with ChangeNotifier, ItemListModel<RadioStation> {
  //=
  final Feed<RadioStation> _initialFeed;
  ItemListViewMode _viewMode = ItemListViewMode.list;

  late final StreamSubscription _eventsSubscription;

  RadioStationsModel({
    required RadioStationListArgs args,
  }) : _initialFeed = args.availableFeed {
    _eventsSubscription = _listenToEvents();
  }

  String? _appliedSearchQuery;

  async.CancelableOperation<Result<ListPage<RadioStation>>>? _radioStationsOp;
  late final PagingController<int, RadioStation> _radioStationsController;

  void init() {
    _viewMode = createViewModeFromFeed(_initialFeed);
    _radioStationsController =
        PagingController<int, RadioStation>(firstPageKey: 1);

    _radioStationsController.addPageRequestListener((pageKey) {
      _fetchRadioStations(pageKey);
    });
  }

  bool get canSearchInFeed => _initialFeed.searchable;

  @override
  void dispose() {
    _eventsSubscription.cancel();
    _radioStationsOp?.cancel();
    _radioStationsController.dispose();
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
      _radioStationsController.refresh();
      notifyListeners();
    }
  }

  void clearSearchQuery() {
    if (_appliedSearchQuery != null) {
      _appliedSearchQuery = null;
      _radioStationsController.refresh();
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
   * API: Radio Station List
   */

  Future<void> _fetchRadioStations(int pageKey) async {
    try {
      // Cancel current operation (if any)
      _radioStationsOp?.cancel();

      final searchQuery = _appliedSearchQuery?.trim();
      final hasSearchQuery = searchQuery != null && searchQuery.isNotEmpty;

      // Create Request
      final request = RadioStationsRequest(
        page: pageKey,
        query: searchQuery,
        feedId: !canSearchInFeed && hasSearchQuery ? null : _initialFeed.id,
      );
      _radioStationsOp = async.CancelableOperation.fromFuture(
        locator<KwotData>().radioStationsRepository.fetchRadioStations(request),
        onCancel: () {
          _radioStationsController.error = "Cancelled.";
        },
      );

      // Listen for result
      _radioStationsOp?.value.then((result) {
        if (!result.isSuccess()) {
          _radioStationsController.error = result.error();
          return;
        }

        final page = result.data();
        final currentItemCount = _radioStationsController.itemList?.length ?? 0;
        final isLastPage = page.isLastPage(currentItemCount);
        if (isLastPage) {
          _radioStationsController.appendLastPage(page.items??[]);
        } else {
          final nextPageKey = pageKey + 1;
          _radioStationsController.appendPage(page.items??[], nextPageKey);
        }
      });
    } catch (error) {
      _radioStationsController.error = error;
    }
  }

  /*
   * ItemListModel<Feed>
   */

  @override
  PagingController<int, RadioStation> controller() => _radioStationsController;

  @override
  void refresh({
    required bool resetPageKey,
    bool isForceRefresh = false,
  }) {
    _radioStationsOp?.cancel();

    if (resetPageKey) {
      _radioStationsController.refresh();
    } else {
      // TODO: @Github/EdsonBueno/infinite_scroll_pagination/issues/106
      _radioStationsController.retryLastFailedRequest();
    }
  }

  /*
   * EVENT:
   *  RadioStationLikeUpdatedEvent
   */

  StreamSubscription _listenToEvents() {
    return eventBus.on().listen((event) {
      if (event is RadioStationLikeUpdatedEvent) {
        return _handleRadioStationLikeEvent(event);
      }
    });
  }

  void _handleRadioStationLikeEvent(RadioStationLikeUpdatedEvent event) {
    _radioStationsController.updateItems<RadioStation>((index, item) {
      return event.update(item);
    });
  }
}
