import 'dart:async';

import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/model/mixin_on_refresh.dart';
import 'package:kwotmusic/components/model/mixin_search_query.dart';
import 'package:kwotmusic/components/widgets/list/item_list.model.dart';
import 'package:kwotmusic/events/events.dart';
import 'package:kwotmusic/util/paging_controller.ext.dart';
import 'package:wrapped_infinite_scroll_pagination/infinite_scroll_pagination.dart';

class LibraryHomeModel
    with
        ChangeNotifier,
        ItemListModel<Track>,
        OnRefreshMixin,
        SearchQueryMixin {
  //=
  late final StreamSubscription _eventsSubscription;

  LibraryHomeModel() {
    _eventsSubscription = _listenToEvents();
  }

  async.CancelableOperation<Result<ListPage<Track>>>? _tracksOp;
  late final PagingController<int, Track> _tracksController;

  void init() {
    _tracksController = PagingController<int, Track>(firstPageKey: 1);
    _tracksController.addPageRequestListener((pageKey) {
      _fetchTracks(pageKey);
    });
  }

  @override
  void dispose() {
    _eventsSubscription.cancel();
    _tracksOp?.cancel();
    _tracksController.dispose();
    super.dispose();
  }

  /*
   * API: TRACK List
   */

  Future<void> _fetchTracks(int pageKey) async {
    try {
      // Cancel current operation (if any)
      _tracksOp?.cancel();

      // Create Request
      final request = LikedTracksRequest(
        page: pageKey,
        query: searchQuery,
      );
      _tracksOp = async.CancelableOperation.fromFuture(
        locator<KwotData>().libraryRepository.fetchLikedTracks(request),
        onCancel: () {
          _tracksController.error = "Cancelled.";
        },
      );

      // Listen for result
      _tracksOp?.value.then((result) {
        if (!result.isSuccess()) {
          _tracksController.error = result.error();
          return;
        }

        final page = result.data();
        final currentItemCount = _tracksController.itemList?.length ?? 0;
        final isLastPage = page.isLastPage(currentItemCount);
        if (isLastPage) {
          if(page.items != null) {
            _tracksController.appendLastPage(page.items!);
          }
        } else {
          final nextPageKey = pageKey + 1;
          if(page.items != null) {
            _tracksController.appendPage(page.items!, nextPageKey);
          }
        }
      });
    } catch (error) {
      _tracksController.error = error;
    }
  }

  /*
   * ItemListModel<TRACK>
   */

  @override
  PagingController<int, Track> controller() => _tracksController;

  @override
  void refresh({
    required bool resetPageKey,
    bool isForceRefresh = false,
  }) {
    _tracksOp?.cancel();

    if (resetPageKey) {
      _tracksController.refresh();
    } else {
      // TODO: @Github/EdsonBueno/infinite_scroll_pagination/issues/106
      _tracksController.retryLastFailedRequest();
    }
  }

  /*
   * OnRefreshMixin
   */

  @override
  void onRefresh() {
    _tracksController.refresh();
  }

  /*
   * EVENT:
   *  TrackLikeUpdatedEvent
   */

  StreamSubscription _listenToEvents() {
    return eventBus.on().listen((event) {
      if (event is TrackLikeUpdatedEvent) {
        return _handleTrackLikeEvent(event);
      }
    });
  }

  void _handleTrackLikeEvent(TrackLikeUpdatedEvent event) {
    final itemCount = _tracksController.itemList?.length ?? 0;
    if (itemCount <= 1) {
      _tracksController.refresh();
      return;
    }

    _tracksController.updateItems<Track>((index, item) {
      return event.update(item);
    });
  }
}
