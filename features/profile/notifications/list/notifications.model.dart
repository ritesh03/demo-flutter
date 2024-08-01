import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/widgets/list/item_list.model.dart';
import 'package:kwotmusic/features/profile/notifications/unread_notifications_count_monitor.dart';
import 'package:kwotmusic/util/paging_controller.ext.dart';
import 'package:wrapped_infinite_scroll_pagination/infinite_scroll_pagination.dart';

typedef InAppNotificationsResult = Result<ListPage<InAppNotification>>;
typedef InAppNotificationsController = PagingController<int, InAppNotification>;

class NotificationsModel with ChangeNotifier, ItemListModel<InAppNotification> {
  //=

  async.CancelableOperation<InAppNotificationsResult>? _notificationsOp;
  late final InAppNotificationsController _notificationsController;

  int? _totalNotifications;

  void init() {
    _notificationsController = InAppNotificationsController(firstPageKey: 1);
    _notificationsController.addPageRequestListener((pageKey) {
      _fetchNotifications(pageKey);
    });
  }

  int get totalNotificationsCount => _totalNotifications ?? 0;

  @override
  void dispose() {
    _notificationsOp?.cancel();
    _notificationsController.dispose();
    super.dispose();
  }

  /*
   * API: IN-APP NOTIFICATIONS LIST
   */

  Future<void> _fetchNotifications(int pageKey) async {
    try {
      // Cancel current operation (if any)
      _notificationsOp?.cancel();

      if (_totalNotifications != null) {
        _totalNotifications = null;
        notifyListeners();
      }

      // Create Request
      final request = InAppNotificationsRequest(page: pageKey);
      _notificationsOp = async.CancelableOperation.fromFuture(
        locator<KwotData>().accountRepository.fetchNotifications(request),
        onCancel: () {
          _notificationsController.error = "Cancelled.";
        },
      );

      // Listen for result
      final result = await _notificationsOp!.value;
      if (!result.isSuccess()) {
        _notificationsController.error = result.error();
        return;
      }

      final page = result.data();
      _totalNotifications = page.totalItems;
      if (totalNotificationsCount > 0) {
        notifyListeners();
      }

      final currentItemCount = _notificationsController.itemList?.length ?? 0;
      final isLastPage = page.isLastPage(currentItemCount);
      if (isLastPage) {
        _notificationsController.appendLastPage(page.items??[]);
      } else {
        final nextPageKey = pageKey + 1;
        _notificationsController.appendPage(page.items??[], nextPageKey);
      }
    } catch (error) {
      _notificationsController.error = error;
    }

    _updateUnreadNotificationsMonitorIfNeeded();
  }

  /*
   * ItemListModel<InAppNotification>
   */

  @override
  InAppNotificationsController controller() => _notificationsController;

  @override
  void refresh({
    required bool resetPageKey,
    bool isForceRefresh = false,
  }) {
    _notificationsOp?.cancel();

    if (resetPageKey) {
      _notificationsController.refresh();
    } else {
      // TODO: @Github/EdsonBueno/infinite_scroll_pagination/issues/106
      _notificationsController.retryLastFailedRequest();
    }
  }

  /*
   * API: Mark Notification as Read
   */

  Future<Result> markNotificationAsRead(InAppNotification notification) {
    final request = InAppNotificationRequest(notificationId: notification.id);
    return locator<KwotData>()
        .accountRepository
        .markNotificationAsRead(request)
        .then((result) {
      if (result.isSuccess()) {
        _onNotificationMarkedAsRead(notification.id);
      }

      return result;
    });
  }

  void _onNotificationMarkedAsRead(String notificationId) {
    int unreadCount = 0;
    _notificationsController.updateItems<InAppNotification>((index, item) {
      if (item.id != notificationId) {
        if (!item.read) unreadCount++;
        return item;
      }
      return item.copyWith(read: true);
    });

    if (unreadCount == 0) {
      locator<UnreadNotificationsCountMonitor>().clearAndCheck();
    }
  }

  /*
   * API: Mark All Notifications as Read
   */

  Future<Result> markAllNotificationAsRead() {
    return locator<KwotData>()
        .accountRepository
        .markAllNotificationsAsRead()
        .then((result) {
      if (result.isSuccess()) {
        _onAllNotificationsMarkedAsRead();
      }

      return result;
    });
  }

  void _onAllNotificationsMarkedAsRead() {
    locator<UnreadNotificationsCountMonitor>().clearAndCheck();
    _notificationsController.updateItems<InAppNotification>((index, item) {
      return item.copyWith(read: true);
    });
  }

  void _updateUnreadNotificationsMonitorIfNeeded() {
    final items = _notificationsController.itemList ?? <InAppNotification>[];
    final unreadCount = items.where((item) => !item.read).length;

    locator<UnreadNotificationsCountMonitor>().updateIfMissing(unreadCount);
  }
}
