import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/blocking_progress.dialog.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/list/item_list.widget.dart';
import 'package:kwotmusic/components/widgets/marquee/simple_marquee.dart';
import 'package:kwotmusic/components/widgets/notificationbar/notification_bar.dart';
import 'package:kwotmusic/components/widgets/page/page_state.dart';
import 'package:kwotmusic/components/widgets/sliverheader/sliver_header.dart';
import 'package:kwotmusic/components/widgets/textfield.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/dashboard/dashboard_config.dart';
import 'package:kwotmusic/features/user/profile/user_profile.model.dart';
import 'package:kwotmusic/features/user/user_actions.model.dart';
import 'package:kwotmusic/features/user/widget/user_list_item.widget.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:kwotmusic/util/util.dart';
import 'package:provider/provider.dart';

import 'followings.model.dart';

class FollowingsPage extends StatefulWidget {
  const FollowingsPage({Key? key}) : super(key: key);

  @override
  State<FollowingsPage> createState() => _FollowingsPageState();
}

class _FollowingsPageState extends PageState<FollowingsPage> {
  //=

  @override
  void initState() {
    super.initState();
    followingsModelOf(context).init();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false,
        child: Scaffold(
            body: ItemListWidget<User, FollowingsModel>(
                columnItemSpacing: ComponentInset.normal.h,
                padding:
                    EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
                headerSlivers: [
                  _buildSliverAppBar(),
                  SliverToBoxAdapter(child: _buildSearchBar()),
                ],
                footerSlivers: [DashboardConfigAwareFooter.asSliver()],
                itemBuilder: (context, user, index) {
                  return UserListItem(
                    user: user,
                    onTap: () => _onUserTapped(user),
                    onFollowTap: () => _onUserFollowTapped(user),
                  );
                })));
  }

  SliverPersistentHeader _buildSliverAppBar() {
    final toolbarHeight = ComponentSize.large.h;
    final expandedHeight = toolbarHeight * 2;
    return SliverPersistentHeader(
        pinned: true,
        delegate: BasicSliverHeaderDelegate(
          context,
          toolbarHeight: toolbarHeight,
          expandedHeight: expandedHeight,
          topBar: Row(children: [
            AppIconButton(
                width: ComponentSize.large.r,
                height: ComponentSize.large.r,
                assetColor: DynamicTheme.get(context).neutral20(),
                assetPath: Assets.iconArrowLeft,
                padding: EdgeInsets.all(ComponentInset.small.r),
                onPressed: () => DashboardNavigation.pop(context)),
          ]),
          horizontalTitlePadding: ComponentInset.normal.w,
          title: _buildTitle(),
        ));
  }

  Widget _buildTitle() {
    return Selector<FollowingsModel, String?>(
        selector: (_, model) => model.userName,
        builder: (_, userName, __) {
          final title = (userName != null && userName.isNotEmpty)
              ? LocaleResources.of(context).followingsOfUserFormat(userName)
              : LocaleResources.of(context).followings;
          return SimpleMarquee(
              text: title,
              textStyle: TextStyles.boldHeading2.copyWith(
                color: DynamicTheme.get(context).white(),
              ));
        });
  }

  Widget _buildSearchBar() {
    return Padding(
        padding: EdgeInsets.all(ComponentInset.normal.r),
        child: SearchBar(
          hintText: LocaleResources.of(context).search,
          onQueryChanged: followingsModelOf(context).updateSearchQuery,
          onQueryCleared: followingsModelOf(context).clearSearchQuery,
        ));
  }

  FollowingsModel followingsModelOf(BuildContext context) {
    return context.read<FollowingsModel>();
  }

  void _onUserTapped(User user) {
    hideKeyboard(context);
    Navigator.pushNamed(context, Routes.userProfile,
        arguments: UserProfileArgs(
          id: user.id,
          name: user.name,
          thumbnail: user.thumbnail,
        ));
  }

  void _onUserFollowTapped(User user) async {
    hideKeyboard(context);

    // Show loading dialog
    showBlockingProgressDialog(context);

    // Call API
    final result = await locator<UserActionsModel>().setIsFollowed(
      id: user.id,
      shouldFollow: !user.isFollowed,
    );

    // Close loading dialog
    if (!mounted) return;
    hideBlockingProgressDialog(context);

    if (!result.isSuccess()) {
      showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()));
      return;
    }

    // Alternative handled using Event Bus
  }
}
