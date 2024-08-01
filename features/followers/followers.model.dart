import 'dart:async';

import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/widgets/list/item_list.model.dart';
import 'package:kwotmusic/events/events.dart';
import 'package:kwotmusic/util/paging_controller.ext.dart';
import 'package:wrapped_infinite_scroll_pagination/infinite_scroll_pagination.dart';

abstract class FollowersModel with ChangeNotifier, ItemListModel<User> {
  //=
  final String userId;
  final String? userName;

  late final StreamSubscription _eventsSubscription;

  FollowersModel({
    required this.userId,
    required this.userName,
  }) {
    _eventsSubscription = _listenToEvents();
  }

  String? _appliedSearchQuery;

  async.CancelableOperation<Result<ListPage<User>>>? _followersOp;
  late final PagingController<int, User> _followersController;

  void init() {
    _followersController = PagingController<int, User>(firstPageKey: 1);

    _followersController.addPageRequestListener((pageKey) {
      _fetchFollowers(pageKey);
    });
  }

  @override
  void dispose() {
    _eventsSubscription.cancel();

    _followersOp?.cancel();
    _followersController.dispose();
    super.dispose();
  }

  /*
   * Search Query
   */

  String? get appliedSearchQuery => _appliedSearchQuery;

  void updateSearchQuery(String text) {
    if (_appliedSearchQuery != text) {
      _appliedSearchQuery = text;
      _followersController.refresh();
      notifyListeners();
    }
  }

  void clearSearchQuery() {
    if (_appliedSearchQuery != null) {
      _appliedSearchQuery = null;
      _followersController.refresh();
      notifyListeners();
    }
  }

  /*
   * API: Follower List
   */

  Future<Result<ListPage<User>>> onCreateFollowersRequest({
    required String userId,
    required String? query,
    required int page,
  });

  Future<void> _fetchFollowers(int pageKey) async {
    try {
      // Cancel current operation (if any)
      _followersOp?.cancel();

      // Create Request
      _followersOp = async.CancelableOperation.fromFuture(
        onCreateFollowersRequest(
          userId: userId,
          query: _appliedSearchQuery,
          page: pageKey,
        ),
        onCancel: () {
          _followersController.error = "Cancelled.";
        },
      );

      // Listen for result
      _followersOp?.value.then((result) {
        if (!result.isSuccess()) {
          _followersController.error = result.error();
          return;
        }

        final page = result.data();
        final currentItemCount = _followersController.itemList?.length ?? 0;
        final isLastPage = page.isLastPage(currentItemCount);
        if (isLastPage) {
          if(page.items != null) {
            _followersController.appendLastPage(page.items!);
          }
        } else {
          final nextPageKey = pageKey + 1;
          if(page.items != null) {
            _followersController.appendPage(page.items!, nextPageKey);
          }
        }
      });
    } catch (error) {
      _followersController.error = error;
    }
  }

  /*
   * ItemListModel<User>
   */

  @override
  PagingController<int, User> controller() => _followersController;

  @override
  void refresh({
    required bool resetPageKey,
    bool isForceRefresh = false,
  }) {
    _followersOp?.cancel();

    if (resetPageKey) {
      _followersController.refresh();
    } else {
      // TODO: @Github/EdsonBueno/infinite_scroll_pagination/issues/106
      _followersController.retryLastFailedRequest();
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
    _followersController.updateItems<User>((index, item) {
      return event.update(item);
    });
  }

  void _handleUserFollowEvent(UserFollowUpdatedEvent event) {
    _followersController.updateItems<User>((index, item) {
      return event.update(item);
    });
  }
}
