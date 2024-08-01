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
import 'package:kwotmusic/components/widgets/segmented_control_tabs.widget.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/artist/artist_actions.model.dart';
import 'package:kwotmusic/features/artist/followers/artist_followers.model.dart';
import 'package:kwotmusic/features/artist/followings/artist_followings.model.dart';
import 'package:kwotmusic/features/artist/options/artist_options.bottomsheet.dart';
import 'package:kwotmusic/features/artist/tip/artist_tip.args.dart';
import 'package:kwotmusic/features/dashboard/dashboard_config.dart';
import 'package:kwotmusic/features/profile/widget/profile_stat_item.widget.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:kwotmusic/util/util.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import '../../fans/fans_page.dart';
import '../widget/join_fan_club_bottomsheet.dart';
import 'artist.model.dart';

class ArtistPage extends StatefulWidget {
  const ArtistPage({Key? key}) : super(key: key);

  @override
  State<ArtistPage> createState() => _ArtistPageState();
}

class _ArtistPageState extends PageState<ArtistPage>
    with TickerProviderStateMixin {
  //=

  ArtistModel get artistModel => context.read<ArtistModel>();
  late final TabController _fanClubStepBarController;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    artistModel.init();
    _fanClubStepBarController = TabController(
      length: FanClubSteps.values.length,
      vsync: this,
    );
    _fanClubStepBarController.addListener(() {
      if (_fanClubStepBarController.index == 0) {
        artistModel.showTabBar = false;
        artistModel.isArtist = false;
        artistModel.init();
      } else {
        artistModel.showTabBar = true;
        artistModel.isArtist = true;
        artistModel.init();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final edgeInsets =
        EdgeInsets.symmetric(horizontal: ComponentInset.normal.r);

    return SafeArea(
        child: Scaffold(
            key: _scaffoldKey,
            body: RefreshIndicator(
                color: DynamicTheme.get(context).secondary100(),
                backgroundColor: DynamicTheme.get(context).black(),
                onRefresh: () => Future.sync(() => artistModel.fetchArtist()),
                child: CustomScrollView(
                  scrollDirection: Axis.vertical,
                  slivers: [
                    SliverToBoxAdapter(child: _buildHeader(edgeInsets)),
                    _buildFeedsSliverList(),
                    DashboardConfigAwareFooter.asSliver(),
                  ],
                ))));
  }

  Widget _buildHeader(EdgeInsets edge) {
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
            //_buildFanClubToggle(),
            SizedBox(
              height: ComponentInset.medium.h,
            ),
            _buildFanClubStepBar(),
            _buildProfileStats(),
            _buildJoinFanClubButton(),
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
      Selector<ArtistModel, bool>(
          selector: (_, model) => model.canShowOptions,
          builder: (_, canShow, __) {
            if (!canShow) return Container();
            return AppIconButton(
                width: ComponentSize.large.r,
                height: ComponentSize.large.r,
                assetColor: DynamicTheme.get(context).white(),
                assetPath: Assets.iconOptions,
                padding: EdgeInsets.all(ComponentInset.small.r),
                onPressed: _onProfileOptionsButtonTapped);
          })
    ]);
  }

  Widget _buildProfileCoverPhoto() {
    return Selector<ArtistModel, String?>(
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
                  Row(children: [
                    _buildFollowButton(),
                    SizedBox(width: ComponentInset.normal.r),
                    _buildTipButton(),
                  ]),
                ]),
          )
        ]));
  }

  Widget _buildProfilePhoto() {
    return Selector<ArtistModel, String?>(
        selector: (_, model) => model.profilePhotoPath,
        builder: (_, photoPath, __) {
          return Photo.artist(photoPath,
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
        child: Selector<ArtistModel, String?>(
            selector: (_, model) => model.name,
            builder: (_, name, __) {
              return Text(name ?? "",
                  style: TextStyles.boldHeading2,
                  overflow: TextOverflow.ellipsis);
            }));
  }

  Widget _buildFollowButton() {
    return Selector<ArtistModel, Tuple2<bool, bool>>(
        selector: (_, model) =>
            Tuple2(model.canShowFollowOption, model.isFollowed),
        builder: (_, tuple, __) {
          final canShow = tuple.item1;
          if (!canShow) return Container();

          final isFollowed = tuple.item2;

          return Button(
            width: 96.w,
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

  Widget _buildTipButton() {
    return Selector<ArtistModel, bool>(
        selector: (_, model) => model.canShowTipOption,
        builder: (_, canShow, __) {
          if (!canShow) return Container();
          return Button(
            width: 96.w,
            height: ComponentSize.small.h,
            onPressed: _onTipButtonTapped,
            padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
            text: LocaleResources.of(context).tip,
            type: ButtonType.secondary,
          );
        });
  }

  /*
   * LOADING PROFILE
   */

  Widget _buildLoadingProfileWidget() {
    return Selector<ArtistModel, Result<Artist>?>(
        selector: (_, model) => model.artistResult,
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
                    onTryAgain: artistModel.fetchArtist));
          }

          return Container();
        });
  }

  /*
   * Toggle: To switch between Artist Profile and Fan Page
   */

  Widget _buildFanClubToggle() {
    final localeResource = LocaleResources.of(context);
    return Selector<ArtistModel, Tuple3<Artist?, bool, ArtistPageContentType>>(
        selector: (_, model) => Tuple3(
              model.artist,
              model.hasJoinedFanClub,
              model.selectedPageContentType,
            ),
        builder: (_, tuple, __) {
          final artist = tuple.item1;
          final hasJoinedFanClub = tuple.item2;
          if (artist == null || !hasJoinedFanClub) return Container();

          final selectedPageContentType = tuple.item3;
          final selectedPageContentIndex =
              ArtistPageContentType.values.indexOf(selectedPageContentType);

          return SegmentedControlTabsWidget<ArtistPageContentType>(
            height: ComponentSize.normal.h,
            items: ArtistPageContentType.values.toList(),
            itemTitle: (type) {
              switch (type) {
                case ArtistPageContentType.profile:
                  return localeResource.artistPageContentTypeProfile;
                case ArtistPageContentType.fanPage:
                  return localeResource.artistPageContentTypeFanClub;
              }
            },
            onChanged: artistModel.setSelectedPageContentType,
            margin: EdgeInsets.only(
                top: ComponentInset.normal.r,
                left: ComponentInset.normal.r,
                right: ComponentInset.normal.r),
            selectedItemIndex: selectedPageContentIndex,
          );
        });
  }

  /*
   * STATS: FOLLOWERS, FOLLOWINGS
   */

  Widget _buildProfileStats() {
    return Selector<ArtistModel, Artist?>(
        selector: (_, model) => model.artist,
        builder: (_, artist, __) {
          if (artist == null) return Container();
          return Container(
              margin: EdgeInsets.only(
                  top: ComponentInset.normal.r,
                  left: ComponentInset.normal.r,
                  right: ComponentInset.normal.r),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /// FOLLOWERS
                    artistModel.showTabBar
                        ? Expanded(
                            child: ProfileStatItem(
                                title: artist.fans!.prettyCount,
                                subtitle: LocaleResources.of(context).fans,
                                onTap: _onFansButtonTapped))
                        : Expanded(
                            child: ProfileStatItem(
                                title: artist.followerCount.prettyCount,
                                subtitle: LocaleResources.of(context).followers,
                                onTap: _onFollowersButtonTapped)),
                    SizedBox(width: ComponentInset.normal.w),

                    /// FOLLOWINGS
                    Expanded(
                        child: ProfileStatItem(
                            title: artistModel.showTabBar
                                ? artist.followerCount.prettyCount
                                : artist.followingCount.prettyCount,
                            subtitle: artistModel.showTabBar
                                ? "Followers"
                                : LocaleResources.of(context).followings,
                            onTap: artistModel.showTabBar
                                ? _onFollowersButtonTapped
                                : _onFollowingsButtonTapped)),
                  ]));
        });
  }

  /*
   * Fan Club
   */

  Widget _buildJoinFanClubButton() {
    return Selector<ArtistModel, bool>(
        selector: (_, model) => model.canJoinArtistFanClub,
        builder: (_, canJoin, __) {
          if (!canJoin) return Container();
          return Button(
            margin: EdgeInsets.only(
              top: ComponentInset.medium.r,
              left: ComponentInset.normal.r,
              right: ComponentInset.normal.r,
            ),
            text: LocaleResources.of(context).joinFanClub,
            height: ComponentSize.large.h,
            type: ButtonType.primary,
            width: MediaQuery.of(context).size.width,
            onPressed: _onJoinFanClubButtonTapped,
          );
        });
  }

  Widget _buildFanClubStepBar() {
    return Selector<ArtistModel, bool>(
        selector: (_, model) => model.showFanClub,
        builder: (_, showStepBar, __) {
          if (!showStepBar) return Container();
          return _ArtistFanClubStepBar(
            controller: _fanClubStepBarController,
            height: ComponentInset.larger.h,
            localeResource: LocaleResources.of(context),
            margin: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
          );
        });
  }

  /*
   * FEEDS
   */

  Widget _buildFeedsSliverList() {
    return Selector<ArtistModel, List<Feed>?>(
        selector: (_, model) => model.feeds,
        builder: (_, feeds, __) {
          if (feeds == null || feeds.isEmpty) {
            return SliverToBoxAdapter(child: Container());
          }
          return FeedSliverList(feeds: feeds);
        });
  }

  /*
   * ACTIONS
   */

  void _onProfileOptionsButtonTapped() {
    final artist = artistModel.artist;
    final model = artistModel;
    if (artist == null) return;
    ArtistOptionsBottomSheet.show(context, artist: artist, onTapCancel: () {
      model.leaveFanClub(context).then((value) {
        if (value) {
          setState(() {
            model.isArtist = false;
            model.showTabBar = false;
            _fanClubStepBarController.index = 0;
          });
          model.fetchArtist().then((value) {
            model.fetchSubscription();
          });
          model.fetchProfile();
          showDefaultNotificationBar(
            const NotificationBarInfo.success(
                message: "Fan plan cancelled successfully!"),
          );
          RootNavigation.pop(context);
        }
      });
    }, model: model);
  }

  void _onFollowButtonTapped() async {
    final artist = artistModel.artist;
    if (artist == null) return;

    // Show loading dialog
    showBlockingProgressDialog(context);

    // Call API
    final result = await locator<ArtistActionsModel>().setIsFollowed(
      id: artist.id,
      shouldFollow: !artist.isFollowed,
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

  void _onTipButtonTapped() async {
    final artist = artistModel.artist;
    if (artist == null) return;
    DashboardNavigation.pushNamed(
      context,
      Routes.artistTipPage,
      arguments: ArtistTipArgs(
          artist: artist,
          haveToken: artistModel.profileResult!.data().tokens == 0 && (artistModel.profileResult!.data().tokens??0) < 0? false : true),
    );
  }
  void _onFollowersButtonTapped() {
    final artist = artistModel.artist;
    if (artist == null) return;
    DashboardNavigation.pushNamed(
      context,
      Routes.artistFollowers,
      arguments: ArtistFollowersPageArgs(
        artistId: artist.id,
        artistName: artist.name,
      ),
    );
  }

  void _onFansButtonTapped() {
    final artist = artistModel.artist;
    if (artist == null) return;
    DashboardNavigation.pushNamed(context, Routes.fansViewPage,
        arguments: FansPageView(
          artistId: artist.id,
          artistName: artist.name,
        ));
  }

  void _onFollowingsButtonTapped() {
    final artist = artistModel.artist;
    if (artist == null) return;

    DashboardNavigation.pushNamed(
      context,
      Routes.artistFollowings,
      arguments: ArtistFollowingsPageArgs(
        artistId: artist.id,
        artistName: artist.name,
      ),
    );
  }

  void _onJoinFanClubButtonTapped() {
    final artist = artistModel.artist;
    JoinFanClubBottomSheet.show(
      _scaffoldKey.currentState!.context,
      artistName: artist!.name,
      subscriptionPlans: artistModel.subscriptionResult!,
      artistModel: artistModel,
      isFromUpgrade: false,
    ).then((value) {
      if (value == true) {
        artistModel.fetchArtist();
      }
    });

    // TODO: SHOW FAN CLUBS
  }
}

class _ArtistFanClubStepBar extends StatelessWidget {
  const _ArtistFanClubStepBar({
    Key? key,
    required this.controller,
    required this.height,
    required this.localeResource,
    required this.margin,
  }) : super(key: key);

  final TabController controller;
  final double height;
  final EdgeInsets margin;
  final TextLocaleResource localeResource;

  @override
  Widget build(BuildContext context) {
    return ControlledSegmentedControlTabBar<FanClubSteps>(
        controller: controller,
        height: height,
        items: FanClubSteps.values,
        margin: margin,
        itemTitle: (step) {
          switch (step) {
            case FanClubSteps.artist:
              return localeResource.artist;
            case FanClubSteps.fanClub:
              return localeResource.fanClub;
          }
        });
  }
}

enum FanClubSteps {
  artist(position: 0),
  fanClub(position: 1);

  final int position;
  const FanClubSteps({
    required this.position,
  });
}
