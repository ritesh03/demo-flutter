import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/events/events.dart';
import 'package:kwotmusic/features/profile/notifications/unread_notifications_count_monitor.dart';
import 'package:kwotmusic/features/profile/subscriptions/subscription_detail.model.dart';

class SessionModel {
  //=

  String? get currentUserId {
    return locator<KwotData>().storageRepository.getUserId();
  }

  bool get hasSession {
    return currentUserId != null;
  }

  bool isSelfUser(String userId) {
    return currentUserId == userId;
  }

  Future<Result> deleteAccount() async {
    final result = await locator<KwotData>().accountRepository.deleteAccount();
    if (result.isSuccess()) {
      eventBus.fire(LogoutEvent());
    }

    return result;
  }

  Future<Result> logout() async {
    final result = await locator<KwotData>().accountRepository.logout();
    if (result.isSuccess()) {
      locator<SubscriptionDetailModel>().recheck();
      locator<UnreadNotificationsCountMonitor>().clearAndCheck();
      eventBus.fire(LogoutEvent());
    }

    return result;
  }
}
