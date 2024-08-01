import 'dart:async';

import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/features/auth/session/session.model.dart';
import 'package:rxdart/rxdart.dart';

class UnreadNotificationsCountMonitor {
  late final Timer _timer;
  final _totalUnreadNotificationsSubject = BehaviorSubject<int>();

  UnreadNotificationsCountMonitor() {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkTotalUnreadNotifications();
    });
  }

  ValueStream<int> get stream => _totalUnreadNotificationsSubject.stream;

  void _checkTotalUnreadNotifications() {
    if (!locator<SessionModel>().hasSession) return;

    locator<KwotData>()
        .accountRepository
        .fetchUnreadNotificationsCount()
        .then((result) {
      if (!result.isSuccess() || result.isEmpty()) return;

      final total = result.data();
      _totalUnreadNotificationsSubject.add(total);
    });
  }

  void clearAndCheck() {
    _totalUnreadNotificationsSubject.add(0);
    _checkTotalUnreadNotifications();
  }

  void updateIfMissing(int unreadCount) {
    final currentUnreadCount = stream.valueOrNull;
    if (currentUnreadCount == null) {
      _totalUnreadNotificationsSubject.add(unreadCount);
    }
  }

  void dispose() {
    _timer.cancel();
  }
}
