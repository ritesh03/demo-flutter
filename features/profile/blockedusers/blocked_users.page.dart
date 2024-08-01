import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/blocking_progress.dialog.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/gradient/foreground_gradient_photo.widget.dart';
import 'package:kwotmusic/components/widgets/list/item_list.widget.dart';
import 'package:kwotmusic/components/widgets/notificationbar/notification_bar.dart';
import 'package:kwotmusic/components/widgets/page/page_state.dart';
import 'package:kwotmusic/components/widgets/textfield.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/dashboard/dashboard_config.dart';
import 'package:kwotmusic/features/user/profile/block/block_user_confirmation.bottomsheet.dart';
import 'package:kwotmusic/features/user/profile/user_profile.model.dart';
import 'package:kwotmusic/features/user/user_actions.model.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:kwotmusic/util/util.dart';
import 'package:provider/provider.dart';

import 'blocked_users.model.dart';
import 'widget/blocked_user_list_item.widget.dart';

class BlockedUsersPage extends StatefulWidget {
  const BlockedUsersPage({Key? key}) : super(key: key);

  @override
  State<BlockedUsersPage> createState() => _BlockedUsersPageState();
}

class _BlockedUsersPageState extends PageState<BlockedUsersPage> {
  //=

  BlockedUsersModel get blockedUsersModel => context.read<BlockedUsersModel>();

  @override
  void initState() {
    super.initState();
    blockedUsersModel.init();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: PreferredSize(
                child: _buildAppBar(),
                preferredSize: Size.fromHeight(ComponentSize.large.h)),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitle(),
                SizedBox(height: ComponentInset.medium.h),
                Expanded(child: _buildContent())
              ],
            )));
  }

  /*
   * APP BAR
   */

  Widget _buildAppBar() {
    return Row(children: [
      AppIconButton(
          width: ComponentSize.large.r,
          height: ComponentSize.large.r,
          assetColor: DynamicTheme.get(context).neutral20(),
          assetPath: Assets.iconArrowLeft,
          padding: EdgeInsets.all(ComponentInset.small.r),
          onPressed: () => DashboardNavigation.pop(context)),
    ]);
  }

  /*
   * TITLE
   */

  Widget _buildTitle() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
        child: Selector<BlockedUsersModel, String?>(
            selector: (_, model) => model.blockedUserCount,
            builder: (_, blockedUserCount, __) {
              return Text(
                (blockedUserCount != null)
                    ? LocaleResources.of(context)
                        .blockedUserCountTitleFormat(blockedUserCount)
                    : LocaleResources.of(context).blockedUsers,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyles.boldHeading2
                    .copyWith(color: DynamicTheme.get(context).white()),
              );
            }));
  }

  Widget _buildContent() {
    return Selector<BlockedUsersModel, bool>(
        selector: (_, model) => model.isBlockedUserListEmpty,
        builder: (_, isBlockedUserListEmpty, __) {
          if (isBlockedUserListEmpty) {
            return _buildEmptyBlockedUsersWidget();
          }
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchBar(),
                SizedBox(height: ComponentInset.normal.h),
                Expanded(child: _buildBlockedUsersWidget())
              ]);
        });
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
      child: SearchBar(
          hintText: LocaleResources.of(context).blockedUsersSearchHint,
          onQueryChanged: blockedUsersModel.updateSearchQuery,
          onQueryCleared: blockedUsersModel.clearSearchQuery),
    );
  }

  Widget _buildBlockedUsersWidget() {
    return ItemListWidget<User, BlockedUsersModel>(
        footerSlivers: [DashboardConfigAwareFooter.asSliver()],
        columnItemSpacing: ComponentInset.normal.r,
        itemBuilder: (context, blockedUser, index) {
          return BlockedUserListItem(
              user: blockedUser,
              onTap: () => _onBlockedUserTap(blockedUser),
              onBlockStatusButtonTap: () =>
                  _onBlockStatusButtonTap(blockedUser));
        });
  }

  Widget _buildEmptyBlockedUsersWidget() {
    return Stack(alignment: Alignment.bottomCenter, children: [
      ForegroundGradientPhoto(
        photoPath: Assets.backgroundEmptyState,
        height: 0.4.sh,
      ),
      Container(
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          SizedBox(height: 48.h),
          Text(LocaleResources.of(context).blockedUsersEmptyTitle,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: TextStyles.boldHeading2
                  .copyWith(color: DynamicTheme.get(context).white())),
          SizedBox(height: ComponentInset.small.h),
          Text(LocaleResources.of(context).blockedUsersEmptySubtitle,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: TextStyles.body
                  .copyWith(color: DynamicTheme.get(context).neutral10())),
          const Spacer(),
        ]),
      ),
    ]);
  }

  void _onBlockedUserTap(User user) {
    hideKeyboard(context);
    Navigator.pushNamed(context, Routes.userProfile,
        arguments: UserProfileArgs(
          id: user.id,
          name: user.name,
          thumbnail: user.thumbnail,
        ));
  }

  void _onBlockStatusButtonTap(User user) async {
    bool? shouldContinue =
        await BlockUserConfirmationBottomSheet.show(context, user: user);
    if (shouldContinue == null || !shouldContinue) {
      return;
    }

    // Show progress
    showBlockingProgressDialog(context);

    final Result<User> result;
    if (user.isBlocked) {
      result = await locator<UserActionsModel>().unblockUser(id: user.id);
    } else {
      result = await locator<UserActionsModel>().blockUser(id: user.id);
    }

    // Hide progress
    hideBlockingProgressDialog(context);

    if (!result.isSuccess()) {
      showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()));
    } else {
      final message = result.message;
      if (message != null) {
        showDefaultNotificationBar(
            NotificationBarInfo.success(message: message));
      }
    }
  }
}
