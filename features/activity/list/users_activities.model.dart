import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/widgets/list/item_list.model.dart';
import 'package:wrapped_infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'users_activities.args.dart';

class UsersActivitiesModel with ChangeNotifier, ItemListModel<UserActivity> {
  //=
  final Feed<UserActivity>? _initialFeed;
  late UsersActivitiesFilter filter;

  UsersActivitiesModel({
    required UsersActivitiesArgs args,
  }) : _initialFeed = args.availableFeed {
    filter = UsersActivitiesFilter(query: null);
  }

  async.CancelableOperation<Result<ListPage<UserActivity>>>? _activitiesOp;
  late final PagingController<int, UserActivity> _activitiesController;

  void init() {
    _activitiesController =
        PagingController<int, UserActivity>(firstPageKey: 1);
    _activitiesController.addPageRequestListener((pageKey) {
      _fetchUserActivities(pageKey);
    });
  }

  bool get canSearchInFeed => _initialFeed?.searchable ?? false;

  @override
  void dispose() {
    _activitiesOp?.cancel();
    _activitiesController.dispose();
    super.dispose();
  }

  /*
   * Page
   */

  String? get pageTitle {
    if (!canSearchInFeed && filter.hasSearchQuery) {
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

  String? get appliedSearchQuery => filter.query;

  void updateSearchQuery(String text) {
    if (appliedSearchQuery != text) {
      filter = filter.copyWithQuery(query: text);
      _activitiesController.refresh();
      notifyListeners();
    }
  }

  void clearSearchQuery() {
    if (appliedSearchQuery != null) {
      filter = filter.copyWithQuery(query: null);
      _activitiesController.refresh();
      notifyListeners();
    }
  }

  /*
   * API: User Activities List
   */

  Future<void> _fetchUserActivities(int pageKey) async {
    try {
      // Cancel current operation (if any)
      _activitiesOp?.cancel();

      // Create Request
      final request = UsersActivitiesRequest(
        feedId: !canSearchInFeed && filter.hasSearchQuery
            ? null
            : _initialFeed?.id,
        page: pageKey,
        query: filter.query,
      );
      _activitiesOp = async.CancelableOperation.fromFuture(
        locator<KwotData>()
            .userActivityRepository
            .fetchUsersActivities(request),
        onCancel: () => _activitiesController.error = "Cancelled.",
      );

      // Listen for result
      _activitiesOp?.value.then((result) {
        if (!result.isSuccess()) {
          _activitiesController.error = result.error();
          return;
        }

        final page = result.data();
        final currentItemCount = _activitiesController.itemList?.length ?? 0;
        final isLastPage = page.isLastPage(currentItemCount);
        if (isLastPage) {
          if(page.items != null) {
            _activitiesController.appendLastPage(page.items!);
          }
        } else {
          final nextPageKey = pageKey + 1;
          if(page.items != null) {
            _activitiesController.appendPage(page.items!, nextPageKey);
          }
        }
      });
    } catch (error) {
      _activitiesController.error = error;
    }
  }

  /*
   * ItemListModel<UserActivity>
   */

  @override
  PagingController<int, UserActivity> controller() => _activitiesController;

  @override
  void refresh({
    required bool resetPageKey,
    bool isForceRefresh = false,
  }) {
    _activitiesOp?.cancel();

    if (resetPageKey) {
      _activitiesController.refresh();
    } else {
      // TODO: @Github/EdsonBueno/infinite_scroll_pagination/issues/106
      _activitiesController.retryLastFailedRequest();
    }
  }
}
