import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/features/profile/notifications/unread_notifications_count_monitor.dart';

class UnreadNotificationIndicator extends StatelessWidget {
  const UnreadNotificationIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = 6.r;
    return StreamBuilder<int>(
        stream: locator<UnreadNotificationsCountMonitor>().stream,
        builder: (_, snapshot) {
          final hasUnreadNotifications = (snapshot.data ?? 0) > 0;
          if (!hasUnreadNotifications) return const SizedBox.shrink();
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
                color: DynamicTheme.get(context).secondary100(),
                borderRadius: BorderRadius.circular(size)),
          );
        });
  }
}
