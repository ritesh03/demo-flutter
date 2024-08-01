import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/blocking_progress.dialog.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/list/item_list.widget.dart';
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

import 'find_friends.model.dart';

class FindFriendsPage extends StatefulWidget {
  const FindFriendsPage({Key? key}) : super(key: key);

  @override
  State<FindFriendsPage> createState() => _FindFriendsPageState();
}

class _FindFriendsPageState extends PageState<FindFriendsPage> {
  //=

  FindFriendsModel get findFriendsModel => context.read<FindFriendsModel>();

  @override
  void initState() {
    super.initState();
    findFriendsModel.init();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false,
        child: Scaffold(
            body: ItemListWidget<User, FindFriendsModel>(
                columnItemSpacing: ComponentInset.normal.h,
                padding:
                    EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
                headerSlivers: [
                  _buildSliverAppBar(),
                  SliverToBoxAdapter(
                    child: Column(children: [
                      SizedBox(height: ComponentInset.normal.r),
                      _buildSearchBar(),
                      SizedBox(height: ComponentInset.normal.r),
                      _buildFollowAllButton(),
                    ]),
                  )
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
    return Text(
      LocaleResources.of(context).findFriends,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyles.boldHeading2
          .copyWith(color: DynamicTheme.get(context).white()),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
        child: SearchBar(
          hintText: LocaleResources.of(context).findFriendsSearchHint,
          onQueryChanged: findFriendsModel.updateSearchQuery,
          onQueryCleared: findFriendsModel.clearSearchQuery,
        ));
  }

  Widget _buildFollowAllButton() {
    return Selector<FindFriendsModel, int?>(
        selector: (_, model) => model.suggestedUsersCount,
        builder: (_, suggestedUsersCount, __) {
          if (suggestedUsersCount == null || suggestedUsersCount <= 1) {
            return Container();
          }
          return Button(
            text: LocaleResources.of(context)
                .followAllCountFormat(suggestedUsersCount.prettyCount),
            width: double.infinity,
            margin: EdgeInsets.only(
                left: ComponentInset.normal.r,
                right: ComponentInset.normal.r,
                bottom: ComponentInset.normal.r),
            onPressed: _onFollowAllButtonTapped,
          );
        });
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

  void _onFollowAllButtonTapped() async {
    hideKeyboard(context);

    showBlockingProgressDialog(context);
    final result = await findFriendsModel.followAllSuggestedUsers(context);

    if (!mounted) return;
    hideBlockingProgressDialog(context);

    if (result.isSuccess()) {
      final message = result.message;
      if (message != null) {
        showDefaultNotificationBar(
            NotificationBarInfo.success(message: message));
      }
    } else {
      showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()));
    }
  }
}
