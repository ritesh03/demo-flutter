import 'dart:async';

import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/widgets/list/item_list.model.dart';
import 'package:kwotmusic/events/events.dart';
import 'package:kwotmusic/util/paging_controller.ext.dart';
import 'package:wrapped_infinite_scroll_pagination/infinite_scroll_pagination.dart';

abstract class FollowingsModel with ChangeNotifier, ItemListModel<User> {
  //=
  final String userId;
  final String? userName;

  late final StreamSubscription _eventsSubscription;

  FollowingsModel({
    required this.userId,
    required this.userName,
  }) {
    _eventsSubscription = _listenToEvents();
  }

  String? _appliedSearchQuery;

  async.CancelableOperation<Result<ListPage<User>>>? _followingsOp;
  late final PagingController<int, User> _followingsController;

  void init() {
    _followingsController = PagingController<int, User>(firstPageKey: 1);

    _followingsController.addPageRequestListener((pageKey) {
      _fetchFollowings(pageKey);
    });
  }

  @override
  void dispose() {
    _eventsSubscription.cancel();

    _followingsOp?.cancel();
    _followingsController.dispose();
    super.dispose();
  }

  /*
   * Search Query
   */

  String? get appliedSearchQuery => _appliedSearchQuery;

  void updateSearchQuery(String text) {
    if (_appliedSearchQuery != text) {
      _appliedSearchQuery = text;
      _followingsController.refresh();
      notifyListeners();
    }
  }

  void clearSearchQuery() {
    if (_appliedSearchQuery != null) {
      _appliedSearchQuery = null;
      _followingsController.refresh();
      notifyListeners();
    }
  }

  /*
   * API: Following List
   */

  Future<Result<ListPage<User>>> onCreateFollowingsRequest({
    required String userId,
    required String? query,
    required int page,
  });

  Future<void> _fetchFollowings(int pageKey) async {
    try {
      // Cancel current operation (if any)
      _followingsOp?.cancel();

      // Create Request
      _followingsOp = async.CancelableOperation.fromFuture(
        onCreateFollowingsRequest(
          userId: userId,
          query: _appliedSearchQuery,
          page: pageKey,
        ),
        onCancel: () {
          _followingsController.error = "Cancelled.";
        },
      );

      // Listen for result
      _followingsOp?.value.then((result) {
        if (!result.isSuccess()) {
          _followingsController.error = result.error();
          return;
        }

        final page = result.data();
        final currentItemCount = _followingsController.itemList?.length ?? 0;
        final isLastPage = page.isLastPage(currentItemCount);
        if (isLastPage) {
          if(page.items != null) {
            _followingsController.appendLastPage(page.items!);
          }
        } else {
          final nextPageKey = pageKey + 1;
          if(page.items != null) {
            _followingsController.appendPage(page.items!, nextPageKey);
          }
        }
      });
    } catch (error) {
      _followingsController.error = error;
    }
  }

  /*
   * ItemListModel<User>
   */

  @override
  PagingController<int, User> controller() => _followingsController;

  @override
  void refresh({
    required bool resetPageKey,
    bool isForceRefresh = false,
  }) {
    _followingsOp?.cancel();

    if (resetPageKey) {
      _followingsController.refresh();
    } else {
      // TODO: @Github/EdsonBueno/infinite_scroll_pagination/issues/106
      _followingsController.retryLastFailedRequest();
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
    _followingsController.updateItems<User>((index, item) {
      return event.update(item);
    });
  }

  void _handleUserFollowEvent(UserFollowUpdatedEvent event) {
    _followingsController.updateItems<User>((index, item) {
      return event.update(item);
    });
  }
}
