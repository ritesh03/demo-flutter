import 'dart:async';

import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/widgets/list/item_list.model.dart';
import 'package:kwotmusic/events/events.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/util/paging_controller.ext.dart';
import 'package:wrapped_infinite_scroll_pagination/infinite_scroll_pagination.dart';

class FindFriendsModel with ChangeNotifier, ItemListModel<User> {
  //=
  late final StreamSubscription _eventsSubscription;

  FindFriendsModel() {
    _eventsSubscription = _listenToEvents();
  }

  String? _appliedSearchQuery;

  async.CancelableOperation<Result<ListPage<User>>>? _suggestedUsersOp;
  async.CancelableOperation<Result<ListPage<SearchResultItem>>>? _searchOp;
  late final PagingController<int, User> _usersController;

  void init() {
    _usersController = PagingController<int, User>(firstPageKey: 1);
    _usersController.addPageRequestListener((pageKey) {
      _fetchSuggestedUsers(pageKey);
    });
  }

  @override
  void dispose() {
    _eventsSubscription.cancel();

    _suggestedUsersOp?.cancel();
    _searchOp?.cancel();
    _usersController.dispose();
    super.dispose();
  }

  /*
   * Search Query
   */

  String? get appliedSearchQuery => _appliedSearchQuery;

  void updateSearchQuery(String text) {
    if (_appliedSearchQuery != text) {
      _appliedSearchQuery = text;
      _usersController.refresh();
      notifyListeners();
    }
  }

  void clearSearchQuery() {
    if (_appliedSearchQuery != null) {
      _appliedSearchQuery = null;
      _usersController.refresh();
      notifyListeners();
    }
  }

  /*
   * API: Suggested Users List
   */

  Iterable<User> get _suggestedUsers {
    final users = _usersController.itemList ?? [];
    return users.where((user) {
      return !user.isFollowed && !user.isBlocked;
    });
  }

  int? get suggestedUsersCount {
    return _suggestedUsers.isEmpty ? null : _suggestedUsers.length;
  }

  Future<void> _fetchSuggestedUsers(int pageKey) async {
    try {
      // Cancel current operation (if any)
      _searchOp?.cancel();
      _suggestedUsersOp?.cancel();

      // Create Request
      final request = SuggestedUsersRequest(
        query: _appliedSearchQuery,
        page: pageKey,
      );
      _suggestedUsersOp = async.CancelableOperation.fromFuture(
        locator<KwotData>().accountRepository.fetchSuggestedUsers(request),
        onCancel: () {
          _usersController.error = "Cancelled.";
        },
      );

      // Listen for result
      _suggestedUsersOp?.value.then((result) {
        if (!result.isSuccess()) {
          _usersController.error = result.error();
          return;
        }

        if (pageKey == 1 && result.isEmpty()) {
          _usersController.appendLastPage([]);
          return;
        }

        final page = result.data();
        final currentItemCount = _usersController.itemList?.length ?? 0;
        final isLastPage = page.isLastPage(currentItemCount);
        if (isLastPage) {
          _usersController.appendLastPage(page.items??[]);
        } else {
          final nextPageKey = pageKey + 1;
          _usersController.appendPage(page.items??[], nextPageKey);
        }
        notifyListeners();
      });
    } catch (error) {
      _usersController.error = error;
      notifyListeners();
    }
  }

  /*
   * ItemListModel<User>
   */

  @override
  PagingController<int, User> controller() => _usersController;

  @override
  void refresh({
    required bool resetPageKey,
    bool isForceRefresh = false,
  }) {
    _suggestedUsersOp?.cancel();

    if (resetPageKey) {
      _usersController.refresh();
    } else {
      // TODO: @Github/EdsonBueno/infinite_scroll_pagination/issues/106
      _usersController.retryLastFailedRequest();
    }
  }

  /*
   * API: Follow All Suggested Users
   */

  async.CancelableOperation<Result>? _followSuggestedUsersOp;

  Future<Result> followAllSuggestedUsers(BuildContext context) async {
    final localization = LocaleResources.of(context);

    // Cancel current operation (if any)
    _followSuggestedUsersOp?.cancel();

    final users = _suggestedUsers;
    if (users.isEmpty) {
      return Result.error(localization.somethingWentWrong);
    }

    // Create Request
    final request = FollowSuggestedUsersRequest(
      userIds: users.map((user) => user.id).toList(),
    );

    _followSuggestedUsersOp = async.CancelableOperation.fromFuture(
      locator<KwotData>().accountRepository.followAllSuggestedUsers(request),
      onCancel: () {
        _usersController.error = "Cancelled.";
      },
    );

    return _followSuggestedUsersOp!.value.then((result) {
      if (result.isSuccess()) {
        _usersController.refresh();
        notifyListeners();
      }
      return result;
    });
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
    _usersController.updateItems<User>((index, item) {
      return event.update(item);
    });
    notifyListeners();
  }

  void _handleUserFollowEvent(UserFollowUpdatedEvent event) {
    _usersController.updateItems<User>((index, item) {
      return event.update(item);
    });
    notifyListeners();
  }
}
