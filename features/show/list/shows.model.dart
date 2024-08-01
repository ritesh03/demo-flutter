import 'dart:async';

import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/widgets/list/item_list.model.dart';
import 'package:kwotmusic/events/events.dart';
import 'package:kwotmusic/util/paging_controller.ext.dart';
import 'package:wrapped_infinite_scroll_pagination/infinite_scroll_pagination.dart';

class ShowListArgs {
  ShowListArgs({this.availableFeed});

  final Feed<Show>? availableFeed;
}

class ShowsModel with ChangeNotifier, ItemListModel<Show> {
  //=
  final Feed<Show>? _initialFeed;

  late final StreamSubscription _eventsSubscription;

  ShowsModel({
    required ShowListArgs args,
  }) : _initialFeed = args.availableFeed {
    _eventsSubscription = _listenToEvents();
  }

  String? _appliedSearchQuery;

  async.CancelableOperation<Result<ListPage<Show>>>? _showsOp;
  late final PagingController<int, Show> _showsController;

  void init() {
    _showsController = PagingController<int, Show>(firstPageKey: 1);
    _showsController.addPageRequestListener((pageKey) {
      _fetchShows(pageKey);
    });
  }

  bool get canSearchInFeed => _initialFeed?.searchable ?? false;

  @override
  void dispose() {
    _eventsSubscription.cancel();
    _showsOp?.cancel();
    _showsController.dispose();
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
      _showsController.refresh();
      notifyListeners();
    }
  }

  void clearSearchQuery() {
    if (_appliedSearchQuery != null) {
      _appliedSearchQuery = null;
      _showsController.refresh();
      notifyListeners();
    }
  }

  /*
   * API: Show List
   */

  Future<void> _fetchShows(int pageKey) async {
    try {
      // Cancel current operation (if any)
      _showsOp?.cancel();

      final searchQuery = _appliedSearchQuery?.trim();
      final hasSearchQuery = searchQuery != null && searchQuery.isNotEmpty;

      // Create Request
      final request = ShowsRequest(
        page: pageKey,
        query: searchQuery,
        feedId: !canSearchInFeed && hasSearchQuery ? null : _initialFeed?.id,
      );
      _showsOp = async.CancelableOperation.fromFuture(
        locator<KwotData>().showsRepository.fetchShows(request),
        onCancel: () {
          _showsController.error = "Cancelled.";
        },
      );

      // Listen for result
      _showsOp?.value.then((result) {
        if (!result.isSuccess()) {
          _showsController.error = result.error();
          return;
        }

        final page = result.data();
        final currentItemCount = _showsController.itemList?.length ?? 0;
        final isLastPage = page.isLastPage(currentItemCount);
        if (isLastPage) {
          _showsController.appendLastPage(page.items??[]);
        } else {
          final nextPageKey = pageKey + 1;
          _showsController.appendPage(page.items??[], nextPageKey);
        }
      });
    } catch (error) {
      _showsController.error = error;
    }
  }

  /*
   * ItemListModel<Feed>
   */

  @override
  PagingController<int, Show> controller() => _showsController;

  @override
  void refresh({
    required bool resetPageKey,
    bool isForceRefresh = false,
  }) {
    _showsOp?.cancel();

    if (resetPageKey) {
      _showsController.refresh();
    } else {
      // TODO: @Github/EdsonBueno/infinite_scroll_pagination/issues/106
      _showsController.retryLastFailedRequest();
    }
  }

  /*
   * EVENT:
   *  ShowLikeUpdatedEvent,
   *  ShowReminderUpdatedEvent
   */

  StreamSubscription _listenToEvents() {
    return eventBus.on().listen((event) {
      if (event is ShowLikeUpdatedEvent) {
        return _handleShowLikeEvent(event);
      }
      if (event is ShowReminderUpdatedEvent) {
        return _handleShowReminderEvent(event);
      }
    });
  }

  void _handleShowLikeEvent(ShowLikeUpdatedEvent event) {
    return _showsController.updateItems<Show>((index, item) {
      return event.update(item);
    });
  }

  void _handleShowReminderEvent(ShowReminderUpdatedEvent event) {
    return _showsController.updateItems<Show>((index, item) {
      return event.update(item);
    });
  }
}
