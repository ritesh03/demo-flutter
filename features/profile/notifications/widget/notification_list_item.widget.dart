import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button/buttons.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';
import 'package:kwotmusic/features/profile/notifications/ui_notification.dart';
import 'package:kwotmusic/util/util.dart';

class NotificationListItem extends StatelessWidget {
  const NotificationListItem({
    Key? key,
    required this.notification,
    required this.onUserTap,
    required this.onNotificationTap,
  }) : super(key: key);

  final UINotification notification;
  final Function(User) onUserTap;
  final Function(InAppNotification) onNotificationTap;

  @override
  Widget build(BuildContext context) {
    final horizontalPadding =
        EdgeInsets.symmetric(horizontal: ComponentInset.normal.r);

    return Stack(children: [
      TappableButton(
        onTap: () => onNotificationTap(notification.inAppNotification),
        borderRadius: BorderRadius.zero,
        padding: horizontalPadding,
        child: _DefaultNotificationLayout(
          notification: notification,
          onUserTap: onUserTap,
        ),
      ),
      Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _Divider(padding: horizontalPadding)),
    ]);
  }
}

/// ///////////////////////////////////////
/// /////  DEFAULT LAYOUT  ////////////////
/// ///////////////////////////////////////

class _DefaultNotificationLayout extends StatelessWidget {
  const _DefaultNotificationLayout({
    Key? key,
    required this.notification,
    required this.onUserTap,
  }) : super(key: key);

  final UINotification notification;
  final Function(User) onUserTap;

  @override
  Widget build(BuildContext context) {
    final spacing = 12.r;

    final title = notification.title;
    final subtitle = notification.subtitle;
    final user = notification.user;

    return Container(
        constraints: BoxConstraints(minHeight: 56.r),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: spacing),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (!notification.read) const _UnreadIndicator(),
            if (!notification.read) SizedBox(width: spacing),
            if (user != null) _UserAvatar(user: user, onTap: onUserTap),
            if (user != null) SizedBox(width: spacing),
            Expanded(
              child: _TitleAndSubtitle(title: title, subtitle: subtitle),
            ),
            SizedBox(width: spacing),
            _Timestamp(dateTime: notification.date),
          ],
        ));
  }
}

/// ///////////////////////////////////////
/// /////  COMPONENTS  ////////////////////
/// ///////////////////////////////////////

class _UnreadIndicator extends StatelessWidget {
  const _UnreadIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final indicatorSize = 8.r;
    return Container(
      width: indicatorSize,
      height: indicatorSize,
      decoration: BoxDecoration(
        color: DynamicTheme.get(context).secondary100(),
        borderRadius: BorderRadius.circular(indicatorSize),
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({
    Key? key,
    required this.user,
    required this.onTap,
  }) : super(key: key);

  final User user;
  final Function(User) onTap;

  @override
  Widget build(BuildContext context) {
    final size = ComponentSize.small.r;
    return ScaleTap(
        onPressed: () => onTap(user),
        child: Photo.user(
          user.thumbnail,
          options: PhotoOptions(
            width: size,
            height: size,
            shape: BoxShape.circle,
          ),
        ));
  }
}

class _TitleAndSubtitle extends StatelessWidget {
  const _TitleAndSubtitle({
    Key? key,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyles.boldHeading6
              .copyWith(color: DynamicTheme.get(context).white())),
      Text(subtitle,
          maxLines: 7,
          overflow: TextOverflow.ellipsis,
          style: TextStyles.heading6
              .copyWith(color: DynamicTheme.get(context).neutral10())),
    ]);
  }
}

class _Timestamp extends StatelessWidget {
  const _Timestamp({
    Key? key,
    required this.dateTime,
  }) : super(key: key);

  final DateTime dateTime;

  @override
  Widget build(BuildContext context) {
    return Text(dateTime.toTimeAgoString(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.caption
            .copyWith(color: DynamicTheme.get(context).white()));
  }
}

class _Divider extends StatelessWidget {
  const _Divider({
    Key? key,
    required this.padding,
  }) : super(key: key);

  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final dividerHeight = 2.r;
    return Padding(
      padding: padding,
      child: Container(
        height: dividerHeight,
        decoration: BoxDecoration(
          color: DynamicTheme.get(context).black(),
          borderRadius: BorderRadius.circular(dividerHeight),
        ),
      ),
    );
  }
}
