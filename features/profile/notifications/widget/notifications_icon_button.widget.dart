import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/features/profile/notifications/unread_notifications_count_monitor.dart';

class NotificationsIconButton extends StatelessWidget {
  const NotificationsIconButton({
    Key? key,
    required this.iconPadding,
    required this.onTap,
    required this.size,
  }) : super(key: key);

  final EdgeInsets iconPadding;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
        stream: locator<UnreadNotificationsCountMonitor>().stream,
        builder: (_, snapshot) {
          final hasUnreadNotifications = (snapshot.data ?? 0) > 0;
          return AppIconButton(
              width: size,
              height: size,
              assetColor: hasUnreadNotifications
                  ? DynamicTheme.get(context).secondary100()
                  : DynamicTheme.get(context).white(),
              assetPath: hasUnreadNotifications
                  ? Assets.iconNotificationFilled
                  : Assets.iconNotification,
              padding: iconPadding,
              onPressed: onTap);
        });
  }
}
