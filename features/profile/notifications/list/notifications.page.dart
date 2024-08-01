import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/gradient/foreground_gradient_photo.widget.dart';
import 'package:kwotmusic/components/widgets/list/item_list.widget.dart';
import 'package:kwotmusic/components/widgets/page/page_state.dart';
import 'package:kwotmusic/components/widgets/page/title/page_title_bar_text.widget.dart';
import 'package:kwotmusic/components/widgets/page/title/page_title_bar_wrapper.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/dashboard/dashboard_config.dart';
import 'package:kwotmusic/features/playlist/detail/playlist.args.dart';
import 'package:kwotmusic/features/profile/notifications/ui_notification.dart';
import 'package:kwotmusic/features/profile/notifications/unread_notifications_count_monitor.dart';
import 'package:kwotmusic/features/profile/notifications/widget/mark_all_notifications_as_read_button.widget.dart';
import 'package:kwotmusic/features/profile/notifications/widget/notification_list_item.widget.dart';
import 'package:kwotmusic/features/user/profile/user_profile.model.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:kwotmusic/util/util.dart';
import 'package:provider/provider.dart';

import 'notifications.model.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends PageState<NotificationsPage> {
  //=
  late final ScrollController _scrollController;

  NotificationsModel get _notificationsModel =>
      context.read<NotificationsModel>();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    _notificationsModel.init();
  }

  @override
  Widget build(BuildContext context) {
    final padding = EdgeInsets.symmetric(horizontal: ComponentInset.normal.r);
    final localization = LocaleResources.of(context);

    return SafeArea(
      child: Scaffold(
        body: PageTitleBarWrapper(
          barHeight: ComponentSize.large.r,
          title: PageTitleBarText(
              text: localization.notificationsPageTitle,
              color: DynamicTheme.get(context).white(),
              onTap: _scrollController.animateToTop),
          centerTitle: true,
          actions: const [],
          child: _PageItemsList(
            controller: _scrollController,
            localeResource: localization,
            onNotificationTap: _onNotificationTap,
            onUserTap: _onUserTap,
            padding: padding,
          ),
        ),
      ),
    );
  }

  void _onNotificationTap(InAppNotification notification) {
    _notificationsModel.markNotificationAsRead(notification);

    notification.data.when(
      newFollower: _onUserTap,
      information: (_, __) {},
      playlistLiked: (_, id, name) => _onOpenPlaylist(id: id, name: name),
      playlistCollaboratorAdded: (_, id, name, __) =>
          _onOpenPlaylist(id: id, name: name),
    );
  }

  void _onUserTap(User user) {
    DashboardNavigation.pushNamed(
      context,
      Routes.userProfile,
      arguments: UserProfileArgs(
        id: user.id,
        name: user.name,
        thumbnail: user.thumbnail,
      ),
    );
  }

  void _onOpenPlaylist({
    required String id,
    required String name,
  }) {
    DashboardNavigation.pushNamed(
      context,
      Routes.playlist,
      arguments: PlaylistArgs(id: id, title: name),
    );
  }
}

class _PageTopBar extends StatelessWidget {
  const _PageTopBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      AppIconButton(
          width: ComponentSize.large.r,
          height: ComponentSize.large.r,
          assetColor: DynamicTheme.get(context).neutral20(),
          assetPath: Assets.iconArrowLeft,
          padding: EdgeInsets.all(ComponentInset.small.r),
          onPressed: () => DashboardNavigation.pop(context)),
      const Spacer(),
      const MarkAllNotificationsAsReadButton(),
      SizedBox(width: ComponentInset.normal.r),
    ]);
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    Key? key,
    required this.padding,
  }) : super(key: key);

  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const _PageTopBar(),
      Padding(padding: padding, child: const _PageTitle()),
      SizedBox(height: ComponentInset.normal.r),
      Padding(padding: padding, child: const _PageSubtitle()),
      SizedBox(height: ComponentInset.normal.r),
    ]);
  }
}

class _PageTitle extends StatelessWidget {
  const _PageTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(LocaleResources.of(context).notificationsPageTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.boldHeading2
            .copyWith(color: DynamicTheme.get(context).white()),
        textAlign: TextAlign.left);
  }
}

class _PageSubtitle extends StatelessWidget {
  const _PageSubtitle({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
        stream: locator<UnreadNotificationsCountMonitor>().stream,
        builder: (_, snapshot) {
          final count = snapshot.data;
          if (count == null) return SizedBox(height: ComponentSize.small.r);
          return SizedBox(
            height: ComponentSize.small.r,
            child: Text(
                LocaleResources.of(context).notificationsPageSubtitle(count),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyles.heading5
                    .copyWith(color: DynamicTheme.get(context).neutral10()),
                textAlign: TextAlign.left),
          );
        });
  }
}

class _PageItemsList extends StatelessWidget {
  const _PageItemsList({
    Key? key,
    required this.controller,
    required this.localeResource,
    required this.onNotificationTap,
    required this.onUserTap,
    required this.padding,
  }) : super(key: key);

  final ScrollController controller;
  final TextLocaleResource localeResource;
  final Function(InAppNotification) onNotificationTap;
  final Function(User) onUserTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ItemListWidget<InAppNotification, NotificationsModel>(
        controller: controller,
        headerSlivers: [
          SliverToBoxAdapter(child: _PageHeader(padding: padding)),
        ],
        footerSlivers: [DashboardConfigAwareFooter.asSliver()],
        emptyFirstPageIndicator: const _EmptyNotificationsPage(),
        itemBuilder: (context, notification, index) {
          final uiNotification =
              UINotification(notification, localeResource: localeResource);
          return NotificationListItem(
            notification: uiNotification,
            onUserTap: onUserTap,
            onNotificationTap: onNotificationTap,
          );
        });
  }
}

class _EmptyNotificationsPage extends StatelessWidget {
  const _EmptyNotificationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        ForegroundGradientPhoto(
          photoPath: Assets.backgroundEmptyState,
          height: 0.4.sh,
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          SizedBox(height: 48.h),
          Text(LocaleResources.of(context).notificationsEmptyTitle,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: TextStyles.boldHeading2
                  .copyWith(color: DynamicTheme.get(context).white())),
          const Spacer(),
        ]),
      ],
    );
  }
}
