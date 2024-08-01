import 'dart:async';

import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/widgets/list/item_list.model.dart';
import 'package:kwotmusic/events/events.dart';
import 'package:kwotmusic/util/paging_controller.ext.dart';
import 'package:kwotmusic/util/util.dart';
import 'package:wrapped_infinite_scroll_pagination/infinite_scroll_pagination.dart';

class BlockedUsersModel with ChangeNotifier, ItemListModel<User> {
  //=

  String? _appliedSearchQuery;

  late final StreamSubscription _eventsSubscription;

  async.CancelableOperation<Result<ListPage<User>>>? _blockedUsersOp;
  late final PagingController<int, User> _blockedUsersController;

  BlockedUsersModel() {
    _eventsSubscription = _listenToEvents();
  }

  void init() {
    _blockedUsersController = PagingController<int, User>(firstPageKey: 1);
    _blockedUsersController.addPageRequestListener((pageKey) {
      _fetchBlockedUsers(pageKey);
    });
  }

  @override
  void dispose() {
    _eventsSubscription.cancel();
    _blockedUsersOp?.cancel();
    _blockedUsersController.dispose();
    super.dispose();
  }

  /*
   * Search Query
   */

  String? get appliedSearchQuery => _appliedSearchQuery;

  void updateSearchQuery(String text) {
    if (_appliedSearchQuery != text) {
      _appliedSearchQuery = text;
      _blockedUsersController.refresh();
      notifyListeners();
    }
  }

  void clearSearchQuery() {
    if (_appliedSearchQuery != null) {
      _appliedSearchQuery = null;
      _blockedUsersController.refresh();
      notifyListeners();
    }
  }

  /*
   * API: Blocked User List
   */

  bool _isBlockedUserListEmpty = false;

  bool get isBlockedUserListEmpty => _isBlockedUserListEmpty;

  int? _blockedUserCount;

  String? get blockedUserCount {
    final count = _blockedUserCount;
    if (count == null || count <= 0) return null;
    return count.prettyCount;
  }

  Future<void> _fetchBlockedUsers(int pageKey) async {
    try {
      // Cancel current operation (if any)
      _blockedUsersOp?.cancel();

      if (pageKey == 1) {
        _blockedUserCount = null;
      }

      if (_isBlockedUserListEmpty) {
        _isBlockedUserListEmpty = false;
        notifyListeners();
      }

      // Create Request
      final request = BlockedUsersRequest(
        page: pageKey,
        query: _appliedSearchQuery,
      );
      final blockedUsersOp = async.CancelableOperation.fromFuture(
        locator<KwotData>().accountRepository.fetchBlockedUsers(request),
        onCancel: () {
          _blockedUsersController.error = "Cancelled.";
        },
      );
      _blockedUsersOp = blockedUsersOp;

      // Listen for result
      final result = await blockedUsersOp.value;
      if (!result.isSuccess()) {
        _blockedUsersController.error = result.error();
        return;
      }

      if (request.query == null && result.isEmpty()) {
        _isBlockedUserListEmpty = true;
        notifyListeners();
      }

      final page = result.data();
      if (request.query == null && page.totalItems == 0) {
        _isBlockedUserListEmpty = true;
        notifyListeners();
      }

      if (_blockedUserCount == null) {
        _blockedUserCount = page.totalItems;
        notifyListeners();
      }

      final currentItemCount = _blockedUsersController.itemList?.length ?? 0;
      final isLastPage = page.isLastPage(currentItemCount);
      if (isLastPage) {
        if(page.items != null) {
          _blockedUsersController.appendLastPage(page.items??[]);
        }
      } else {
        final nextPageKey = pageKey + 1;
        if(page.items != null) {
          _blockedUsersController.appendPage(page.items??[], nextPageKey);
        }
      }
    } catch (error) {
      _blockedUsersController.error = error;
    }
  }

  /*
   * ItemListModel<User>
   */

  @override
  PagingController<int, User> controller() => _blockedUsersController;

  @override
  void refresh({
    required bool resetPageKey,
    bool isForceRefresh = false,
  }) {
    _blockedUsersOp?.cancel();

    if (resetPageKey) {
      _blockedUsersController.refresh();
    } else {
      // TODO: @Github/EdsonBueno/infinite_scroll_pagination/issues/106
      _blockedUsersController.retryLastFailedRequest();
    }
  }

  /*
   * EVENT: UserBlockUpdatedEvent
   */

  StreamSubscription _listenToEvents() {
    return eventBus.on().listen((event) {
      if (event is UserBlockUpdatedEvent) {
        return _handleUserBlockEvent(event);
      }
    });
  }

  void _handleUserBlockEvent(UserBlockUpdatedEvent event) {
    // update list of blocked-users
    _blockedUsersController.updateItems<User>((index, item) {
      return event.update(item);
    });

    // update number/count of blocked users
    final blockedUserCount = _blockedUserCount;
    if (blockedUserCount != null) {
      _blockedUserCount =
          event.blocked ? (blockedUserCount + 1) : (blockedUserCount - 1);
      notifyListeners();
    }
  }
}
