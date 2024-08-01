import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotdata/models/list_page.dart';
import 'package:kwotdata/models/result.dart';
import 'package:kwotdata/models/user/user.dart';
import 'package:kwotmusic/util/paging_controller.ext.dart';
import 'package:wrapped_infinite_scroll_pagination/src/core/paging_controller.dart';
import 'package:async/async.dart' as async;
import '../../components/widgets/list/item_list.model.dart';
import '../../events/events.dart';
import 'package:kwotapi/src/entities/artist/followings.request.dart';

 class FansModel with ChangeNotifier, ItemListModel<User> {
   String? artistId;
   String? artistName;
  late final StreamSubscription _eventsSubscription;
  FansModel({
      this.artistId,
     this.artistName,
  }) {
    _eventsSubscription = _listenToEvents();
  }

  async.CancelableOperation<Result<ListPage<User>>>? _fansOp;
  late final PagingController<int, User> _fansController;

  void init() {
    _fansController = PagingController<int, User>(firstPageKey: 1);
    _fansController.addPageRequestListener((pageKey) {
      _fetchFans(pageKey);
    });
  }

  @override
  void dispose() {
    _fansOp?.cancel();
    //_fansController.dispose();
    super.dispose();
  }

  /*
   * Search Query
   */
  String? _appliedSearchQuery;
  String? get appliedSearchQuery => _appliedSearchQuery;

  void updateSearchQuery(String text) {
    if (_appliedSearchQuery != text) {
      _appliedSearchQuery = text;
      _fansController.refresh();
      notifyListeners();
    }
  }

  void clearSearchQuery() {
    if (_appliedSearchQuery != null) {
      _appliedSearchQuery = null;
      _fansController.refresh();
      notifyListeners();
    }
  }
  /*
   * API: Fans List
   */

  Future<void> _fetchFans(
    int pageKey,
  ) async {
    try {
      // Cancel current operation (if any)
      _fansOp?.cancel();

      // Create Request
      final request = KArtistFollowingsRequest(
          id: artistId!,
          page: pageKey.toString(),
          limit: "3",
          query: _appliedSearchQuery);
      _fansOp = async.CancelableOperation.fromFuture(
          locator<KwotData>().artistsRepository.fetchFans(request),
          onCancel: () {
        _fansController.error = "Cancelled.";
      });

      // Listen for result
      _fansOp?.value.then((result) {
        if (!result.isSuccess()) {
          _fansController.error = result.error();
          return;
        }

        final page = result.data();
        final currentItemCount = _fansController.itemList?.length ?? 0;
        final isLastPage = page.isLastPage(currentItemCount);
        if (isLastPage) {
          if (page.items != null) {
            _fansController.appendLastPage(page.items!);
          }
        } else {
          final nextPageKey = pageKey + 1;
          if (page.items != null) {
            _fansController.appendPage(page.items!, nextPageKey);
          }
        }
      });
    } catch (error) {
      _fansController.error = error;
    }
  }






/*
   * EVENT: UserBlockUpdatedEvent, UserFollowUpdatedEvent
   */

  StreamSubscription _listenToEvents() {
    return eventBus.on().listen((event) {
      if (event is UserBlockUpdatedEvent) {
        return _handleUserBlockEvent(event);
      }
      if (event is UserFollowUpdatedEvent) {
        return _handleUserFollowEvent(event);
      }
    });
  }

  void _handleUserBlockEvent(UserBlockUpdatedEvent event) {
    _fansController.updateItems<User>((index, item) {
      return event.update(item);
    });
  }

  void _handleUserFollowEvent(UserFollowUpdatedEvent event) {
    _fansController.updateItems<User>((index, item) {
      return event.update(item);
    });
  }

  @override
  PagingController<int, User> controller() => _fansController;

  @override
  void refresh({required bool resetPageKey, bool isForceRefresh = false}) {
    _fansOp?.cancel();

    if (resetPageKey) {
      _fansController.refresh();
    } else {
      // TODO: @Github/EdsonBueno/infinite_scroll_pagination/issues/106
      _fansController.retryLastFailedRequest();
    }
  }
}
