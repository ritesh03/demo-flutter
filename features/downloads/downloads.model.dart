import 'dart:async';

import 'package:async/async.dart' as async;
import 'package:flutter/foundation.dart';
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/model/mixin_on_refresh.dart';
import 'package:kwotmusic/components/model/mixin_search_query.dart';
import 'package:kwotmusic/components/widgets/list/item_list.model.dart';
import 'package:kwotmusic/events/events.dart';
import 'package:kwotmusic/util/paging_controller.ext.dart';
import 'package:wrapped_infinite_scroll_pagination/infinite_scroll_pagination.dart';

class DownloadsModel
    with
        ChangeNotifier,
        ItemListModel<Track>,
        OnRefreshMixin,
        SearchQueryMixin {
  //=
  late final StreamSubscription _eventsSubscription;

  async.CancelableOperation<Result<List<Track>>>? _downloadsOp;
  late final PagingController<int, Track> _downloadsController;

  DownloadsModel() {
    _eventsSubscription = _listenToEvents();
  }

  void init() {
    _downloadsController = PagingController<int, Track>(firstPageKey: 1);
    _downloadsController.addPageRequestListener((pageKey) {
      _fetchDownloads(pageKey);
    });
  }

  int get totalDownloads => _downloadsController.itemList?.length ?? 0;

  @override
  void dispose() {
    _eventsSubscription.cancel();
    _downloadsOp?.cancel();
    _downloadsController.dispose();
    super.dispose();
  }

  /*
   * API: DOWNLOADS List
   */

  Future<void> _fetchDownloads(int page) async {
    try {
      // Cancel current operation (if any)
      _downloadsOp?.cancel();

      // Create Request
      final request = TracksRequest(page: 1, query: searchQuery);
      _downloadsOp = async.CancelableOperation.fromFuture(
        locator<KwotData>().downloadManager.getTracks(request),
        onCancel: () {
          _downloadsController.error = "Cancelled.";
        },
      );

      // Listen for result
      _downloadsOp?.value.then((result) {
        if (!result.isSuccess()) {
          _downloadsController.error = result.error();
          notifyListeners();
          return;
        }

        final downloads = result.data();
        _downloadsController.appendLastPage(downloads);
        notifyListeners();
      });
    } catch (error) {
      _downloadsController.error = error;
      notifyListeners();
    }
  }

  /*
   * ItemListModel<Track>
   */

  @override
  PagingController<int, Track> controller() => _downloadsController;

  @override
  void refresh({
    required bool resetPageKey,
    bool isForceRefresh = false,
  }) {
    _downloadsOp?.cancel();

    if (resetPageKey) {
      _downloadsController.refresh();
    } else {
      // TODO: @Github/EdsonBueno/infinite_scroll_pagination/issues/106
      _downloadsController.retryLastFailedRequest();
    }
  }

  /*
   * OnRefreshMixin
   */

  @override
  void onRefresh() {
    _downloadsController.refresh();
  }

  /*
   * EVENT:
   *  TrackLikeUpdatedEvent
   */

  StreamSubscription _listenToEvents() {
    return eventBus.on().listen((event) {
      if (event is TrackLikeUpdatedEvent) {
        return _handleTrackLikeEvent(event);
      } else if (event is TrackDownloadDeletedEvent) {
        return _handleTrackDownloadDeletedEvent(event);
      }
    });
  }

  void _handleTrackLikeEvent(TrackLikeUpdatedEvent event) {
    _downloadsController.updateItems<Track>((index, item) {
      return event.update(item);
    });
  }

  void _handleTrackDownloadDeletedEvent(TrackDownloadDeletedEvent event) {
    _downloadsController.applyFilterWhere<Track>((item) {
      return event.id != item.id;
    });
  }
}
