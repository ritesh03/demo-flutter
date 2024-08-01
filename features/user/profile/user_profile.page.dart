import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/blocking_progress.dialog.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/feed/feed_sliver_list.widget.dart';
import 'package:kwotmusic/components/widgets/indicator/indicators.dart';
import 'package:kwotmusic/components/widgets/notificationbar/notification_bar.dart';
import 'package:kwotmusic/components/widgets/page/page_state.dart';
import 'package:kwotmusic/components/widgets/photo/blurred_cover_photo.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/dashboard/dashboard_config.dart';
import 'package:kwotmusic/features/playlist/list/playlists.args.dart';
import 'package:kwotmusic/features/profile/options/self_options.bottomsheet.dart';
import 'package:kwotmusic/features/profile/widget/profile_stat_item.widget.dart';
import 'package:kwotmusic/features/user/followers/user_followers.model.dart';
import 'package:kwotmusic/features/user/followings/user_followings.model.dart';
import 'package:kwotmusic/features/user/profile/options/user_options.bottomsheet.dart';
import 'package:kwotmusic/features/user/user_actions.model.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:kwotmusic/util/util.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import 'user_profile.model.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends PageState<UserProfilePage> {
  //=

  UserProfileModel get userProfileModel => context.read<UserProfileModel>();

  @override
  void initState() {
    super.initState();
    userProfileModel.init();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: RefreshIndicator(
                color: DynamicTheme.get(context).secondary100(),
                backgroundColor: DynamicTheme.get(context).black(),
                onRefresh: () =>
                    Future.sync(() => userProfileModel.fetchUserProfile()),
                child: CustomScrollView(
                  scrollDirection: Axis.vertical,
                  slivers: [
                    SliverToBoxAdapter(child: _buildHeader()),
                    _buildFeedsSliverList(),
                    DashboardConfigAwareFooter.asSliver(),
                  ],
                ))));
  }

  Widget _buildHeader() {
    return Stack(children: <Widget>[
      _buildProfileCoverPhoto(),
      Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileTopBar(),
            SizedBox(height: ComponentInset.normal.h),
            _buildProfileInfo(),
            _buildLoadingProfileWidget(),
            _buildProfileStats(),
          ])
    ]);
  }

  /*
   * PROFILE FOREGROUND & COVER
   */

  Widget _buildProfileTopBar() {
    return Row(children: [
      AppIconButton(
          width: ComponentSize.large.r,
          height: ComponentSize.large.r,
          assetColor: DynamicTheme.get(context).white(),
          assetPath: Assets.iconArrowLeft,
          padding: EdgeInsets.all(ComponentInset.small.r),
          onPressed: () => DashboardNavigation.pop(context)),
      const Spacer(),
      Selector<UserProfileModel, bool>(
          selector: (_, model) => model.canShowOptions,
          builder: (_, canShow, __) {
            if (!canShow) return Container();
            return AppIconButton(
                width: ComponentSize.large.r,
                height: ComponentSize.large.r,
                assetColor: DynamicTheme.get(context).white(),
                assetPath: Assets.iconOptions,
                padding: EdgeInsets.all(ComponentInset.small.r),
                onPressed: _onOptionsButtonTapped);
          })
    ]);
  }

  Widget _buildProfileCoverPhoto() {
    return Selector<UserProfileModel, String?>(
        selector: (_, model) => model.coverPhotoPath,
        builder: (_, photoPath, __) {
          return BlurredCoverPhoto(
              photoPath: photoPath,
              photoKind: PhotoKind.profileCover,
              height: 192.h);
        });
  }

  Widget _buildProfileInfo() {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
        child: Row(children: [
          _buildProfilePhoto(),
          SizedBox(width: ComponentInset.normal.w),
          Expanded(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileName(),
                  _buildEditProfileButton(),
                  _buildFollowButton(),
                  _buildUnblockButton(),
                ]),
          )
        ]));
  }

  Widget _buildProfilePhoto() {
    return Selector<UserProfileModel, String?>(
        selector: (_, model) => model.profilePhotoPath,
        builder: (_, photoPath, __) {
          return Photo.user(photoPath,
              options: PhotoOptions(
                width: 104.r,
                height: 104.r,
                shape: BoxShape.circle,
              ));
        });
  }

  Widget _buildProfileName() {
    return SizedBox(
        height: ComponentSize.small.h,
        child: Selector<UserProfileModel, String?>(
            selector: (_, model) => model.name,
            builder: (_, name, __) {
              return Text(name ?? "",
                  style: TextStyles.boldHeading2,
                  overflow: TextOverflow.ellipsis);
            }));
  }

  Widget _buildEditProfileButton() {
    return Selector<UserProfileModel, bool>(
        selector: (_, model) => model.isSelfProfile,
        builder: (_, isSelfProfile, __) {
          if (!isSelfProfile) return Container();

          return Button(
            width: 112.w,
            height: ComponentSize.smaller.h,
            onPressed: _onEditProfileButtonTapped,
            padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
            text: LocaleResources.of(context).editProfile,
            type: ButtonType.secondary,
          );
        });
  }

  Widget _buildFollowButton() {
    return Selector<UserProfileModel, Tuple2<bool, bool>>(
        selector: (_, model) =>
            Tuple2(model.canShowFollowOption, model.isFollowed),
        builder: (_, tuple, __) {
          final canShow = tuple.item1;
          if (!canShow) return Container();

          final isFollowed = tuple.item2;

          return Button(
            width: 112.w,
            height: ComponentSize.small.h,
            onPressed: _onFollowButtonTapped,
            overriddenBackgroundColor:
                isFollowed ? DynamicTheme.get(context).neutral10() : null,
            padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
            text: isFollowed
                ? LocaleResources.of(context).unfollow
                : LocaleResources.of(context).follow,
            type: ButtonType.secondary,
          );
        });
  }

  Widget _buildUnblockButton() {
    return Selector<UserProfileModel, bool>(
        selector: (_, model) => model.canShowUnblockOption,
        builder: (_, canShow, __) {
          if (!canShow) return Container();

          return Button(
            width: 112.w,
            height: ComponentSize.small.h,
            onPressed: _onUnblockButtonTapped,
            padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
            text: LocaleResources.of(context).unblock,
            type: ButtonType.secondary,
          );
        });
  }

  /*
   * LOADING PROFILE
   */

  Widget _buildLoadingProfileWidget() {
    return Selector<UserProfileModel, Result<User>?>(
        selector: (_, model) => model.userResult,
        builder: (_, result, __) {
          if (result == null) {
            return Container(
              margin: EdgeInsets.only(top: 84.h),
              child: const LoadingIndicator(),
            );
          }

          if (!result.isSuccess()) {
            return Container(
                margin: EdgeInsets.only(top: 84.h),
                child: ErrorIndicator(
                    error: result.error(),
                    onTryAgain: userProfileModel.fetchUserProfile));
          }

          return Container();
        });
  }

  /*
   * STATS: PLAYLISTS, FOLLOWERS, FOLLOWINGS
   */

  Widget _buildProfileStats() {
    return Selector<UserProfileModel, User?>(
        selector: (_, model) => model.user,
        builder: (_, user, __) {
          if (user == null) return Container();
          final blocked = user.isBlocked;
          return Container(
              margin: EdgeInsets.only(
                  top: ComponentInset.normal.r,
                  left: ComponentInset.normal.r,
                  right: ComponentInset.normal.r),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /// PLAYLISTS
                    Expanded(
                        child: ProfileStatItem(
                            title: user.playlistCount.prettyCount,
                            subtitle: LocaleResources.of(context).playlists,
                            onTap: blocked ? null : _onPlaylistsButtonTapped)),
                    SizedBox(width: ComponentInset.normal.w),

                    /// FOLLOWERS
                    Expanded(
                        child: ProfileStatItem(
                            title: user.followerCount.prettyCount,
                            subtitle: LocaleResources.of(context).followers,
                            onTap: blocked ? null : _onFollowersButtonTapped)),
                    SizedBox(width: ComponentInset.normal.w),

                    /// FOLLOWINGS
                    Expanded(
                        child: ProfileStatItem(
                            title: user.followingCount.prettyCount,
                            subtitle: LocaleResources.of(context).followings,
                            onTap: blocked ? null : _onFollowingsButtonTapped))
                  ]));
        });
  }

  /*
   * FEEDS
   */

  Widget _buildFeedsSliverList() {
    return Selector<UserProfileModel, List<Feed>?>(
        selector: (_, model) => model.feeds,
        builder: (_, feeds, __) {
          if (feeds == null || feeds.isEmpty) {
            return SliverToBoxAdapter(child: _buildEmptyFeedsWidget());
          }

          return FeedSliverList(feeds: feeds);
        });
  }

  Widget _buildEmptyFeedsWidget() {
    return Selector<UserProfileModel, bool>(
        selector: (_, model) => model.isBlocked,
        builder: (_, blocked, __) {
          if (blocked) {
            return Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(top: 104.h),
                child:
                    Text(LocaleResources.of(context).blockedUserProfileSummary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyles.body.copyWith(
                          color: DynamicTheme.get(context).neutral10(),
                        )));
          }

          return Container();
        });
  }

  /*
   * ACTIONS
   */

  void _onOptionsButtonTapped() {
    final user = userProfileModel.user;
    if (user == null) return;

    if (userProfileModel.isSelfProfile) {
      SelfOptionsBottomSheet.show(context, user: user);
    } else {
      UserOptionsBottomSheet.show(context, user: user);
    }
  }

  void _onEditProfileButtonTapped() async {
    if (!userProfileModel.isSelfProfile) return;

    final updatedProfile =
        await DashboardNavigation.pushNamed(context, Routes.editProfile);

    if (!mounted) return;
    if (updatedProfile != null && updatedProfile is Profile) {
      userProfileModel.fetchUserProfile();
    }
  }

  void _onFollowButtonTapped() async {
    final user = userProfileModel.user;
    if (user == null) return;

    // Show loading dialog
    showBlockingProgressDialog(context);

    // Call API
    final result = await locator<UserActionsModel>().setIsFollowed(
      id: user.id,
      shouldFollow: !user.isFollowed,
    );

    if (!mounted) return;
    hideBlockingProgressDialog(context);

    if (!result.isSuccess()) {
      showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()));
      return;
    }

    // Alternative handled using Event Bus
  }

  void _onUnblockButtonTapped() async {
    final user = userProfileModel.user;
    if (user == null) return;

    // Show loading dialog
    showBlockingProgressDialog(context);

    // Call API
    final result = await locator<UserActionsModel>().unblockUser(id: user.id);

    if (!mounted) return;
    hideBlockingProgressDialog(context);

    if (!result.isSuccess()) {
      showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()));
      return;
    }

    // Alternative handled using Event Bus
  }

  void _onPlaylistsButtonTapped() {
    final user = userProfileModel.user;
    if (user == null || user.isBlocked) return;

    final args = PlaylistsArgs.user(user);
    DashboardNavigation.pushNamed(context, Routes.playlists, arguments: args);
  }

  void _onFollowersButtonTapped() {
    final user = userProfileModel.user;
    if (user == null || user.isBlocked) return;

    DashboardNavigation.pushNamed(
      context,
      Routes.userFollowers,
      arguments: UserFollowersPageArgs(
        userId: user.id,
        userName: user.firstName,
      ),
    );
  }

  void _onFollowingsButtonTapped() {
    final user = userProfileModel.user;
    if (user == null || user.isBlocked) return;

    DashboardNavigation.pushNamed(
      context,
      Routes.userFollowings,
      arguments: UserFollowingsPageArgs(
        userId: user.id,
        userName: user.firstName,
      ),
    );
  }


}
