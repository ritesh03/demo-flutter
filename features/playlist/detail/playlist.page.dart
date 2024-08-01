import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/animation/sonar_animated_widget.dart';
import 'package:kwotmusic/components/widgets/blocking_progress.dialog.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/feed/feed_sliver_list.widget.dart';
import 'package:kwotmusic/components/widgets/indicator/indicators.dart';
import 'package:kwotmusic/components/widgets/notificationbar/notification_bar.dart';
import 'package:kwotmusic/components/widgets/page/page_state.dart';
import 'package:kwotmusic/components/widgets/page/title/page_title_bar_text.widget.dart';
import 'package:kwotmusic/components/widgets/page/title/page_title_bar_wrapper.dart';
import 'package:kwotmusic/components/widgets/photo/blurred_cover_photo.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';
import 'package:kwotmusic/components/widgets/textfield.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/dashboard/dashboard_config.dart';
import 'package:kwotmusic/features/playback/audio/audio_playback_actions.model.dart';
import 'package:kwotmusic/features/playback/widget/playbutton/playlist_play_button.widget.dart';
import 'package:kwotmusic/features/playlist/collaborators/manage/manage_playlist_collaborators.args.dart';
import 'package:kwotmusic/features/playlist/options/playlist_options.bottomsheet.dart';
import 'package:kwotmusic/features/playlist/options/playlist_options.model.dart';
import 'package:kwotmusic/features/playlist/playlist_actions.model.dart';
import 'package:kwotmusic/features/playlist/tracks/add/playlist_add_tracks.args.dart';
import 'package:kwotmusic/features/playlist/tracks/playlist_tracks.args.dart';
import 'package:kwotmusic/features/playlist/tracks/sort/playlist_tracks_sort_options.bottomsheet.dart';
import 'package:kwotmusic/features/playlist/visibility/playlist_visibility_icon_button.widget.dart';
import 'package:kwotmusic/features/track/options/track_options.bottomsheet.dart';
import 'package:kwotmusic/features/track/options/track_options.model.dart';
import 'package:kwotmusic/features/track/widget/track_list_item.widget.dart';
import 'package:kwotmusic/features/user/profile/user_profile.model.dart';
import 'package:kwotmusic/features/user/user_actions.model.dart';
import 'package:kwotmusic/features/user/widget/user_tile_item.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:kwotmusic/util/util.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../../profile/subscriptions/subscription_enforcement.dart';
import 'playlist.model.dart';
import 'playlist.page.actions.dart';

class PlaylistPage extends StatefulWidget {
  const PlaylistPage({Key? key}) : super(key: key);

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends PageState<PlaylistPage>
    implements PlaylistPageActionCallback {
  //=
  late ScrollController _scrollController;

  PlaylistModel get _playlistModel => context.read<PlaylistModel>();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _playlistModel.init();
  }

  @override
  Widget build(BuildContext context) {
    final padding = EdgeInsets.symmetric(horizontal: ComponentInset.normal.r);
    return SafeArea(
      child: Scaffold(
        body: PageTitleBarWrapper(
          barHeight: ComponentSize.large.r,
          title: _PlaylistTitleBar(onTitleTap: _scrollController.animateToTop),
          centerTitle: false,
          actions: const [
            _PlaylistTitleBarPlayButton(),
          ],
          child: RefreshIndicator(
            color: DynamicTheme.get(context).secondary100(),
            backgroundColor: DynamicTheme.get(context).black(),
            onRefresh: () => Future.sync(() => onReloadTap()),
            child: CustomScrollView(controller: _scrollController, slivers: [
              SliverToBoxAdapter(
                child: Column(children: [
                  _PlaylistPageHeader(callback: this),
                  SizedBox(height: ComponentInset.small.r),
                  _PlaylistTitle(padding: padding),
                  _PlaylistDetail(callback: this, padding: padding),
                  SizedBox(height: ComponentInset.normal.r),
                ]),
              ),
              _PlaylistTracksSliver(
                playlistId: _playlistModel.playlistId,
                padding: padding,
                onTrackTap: _onTrackTap,
                onTrackOptionsTap: _onTrackOptionsTap,
              ),
              SliverToBoxAdapter(
                child: _SeeAllPlaylistTracksButton(
                    padding: padding, onTap: onSeeAllTracksTap),
              ),
              const _PlaylistFeedsSliver(),
              DashboardConfigAwareFooter.asSliver(),
            ]),
          ),
        ),
      ),
    );
  }

  @override
  void onUserTap(User user) {
    print("tap on option");
    final args = UserProfileArgs(
        id: user.id, name: user.name, thumbnail: user.thumbnail);
    DashboardNavigation.pushNamed(context, Routes.userProfile, arguments: args);
  }

  @override
  void onBackTap() {
    DashboardNavigation.pop(context);
  }

  @override
  void onDownloadTap() {
    final playlist = _playlistModel.playlist;
    if (playlist == null) return;

    // TODO: implement onDownloadTap
  }

  @override
  void onFollowUserTap(User user) async {
    showBlockingProgressDialog(context);

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

  @override
  void onLikeTap() async {
    final playlist = _playlistModel.playlist;
    if (playlist == null) return;

    showBlockingProgressDialog(context);
    final result = await locator<PlaylistActionsModel>().toggleLike(playlist);

    if (!mounted) return;
    hideBlockingProgressDialog(context);

    if (!result.isSuccess()) {
      showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()));
      return;
    }

    // Alternative handled using Event Bus
  }

  @override
  void onManageCollaboratorsButtonTap() {
    final playlist = _playlistModel.playlist;
    if (playlist == null) return;

    DashboardNavigation.pushNamed(
      context,
      Routes.managePlaylistCollaborators,
      arguments: ManagePlaylistCollaboratorsArgs(playlistId: playlist.id),
    );
  }

  @override
  void onOptionsTap() {

    final playlist = _playlistModel.playlist;
    if (playlist == null) return;

    final args = PlaylistOptionsArgs(playlist: playlist, isOnPlaylistPage: true);
    PlaylistOptionsBottomSheet.show(context, args: args);
  }

  @override
  void onReloadTap() {
    _playlistModel.fetchPlaylist();
  }

  @override
  void onTracksFilterButtonTap() async {
    hideKeyboard(context);

    final selectedSortBy = await PlaylistTracksSortOptionsBottomSheet.show(
        context,
        sortBy: _playlistModel.tracksFilter.sortBy);

    if (!mounted) return;
    if (selectedSortBy != null) {
      _playlistModel.setTracksSortBy(selectedSortBy);
    }
  }

  @override
  void onAddTracksTap() {
    final playlist = _playlistModel.playlist;
    if (playlist == null) return;

    DashboardNavigation.pushNamed(
      context,
      Routes.playlistAddTracks,
      arguments: PlaylistAddTracksArgs(
        playlist: playlist,
        isOnPlaylistPage: true,
      ),
    );
  }

  @override
  void onSeeAllTracksTap() {
    final playlist = _playlistModel.playlist;
    if (playlist == null) return;

    final tracksFilter = _playlistModel.tracksFilter;
    DashboardNavigation.pushNamed(context, Routes.playlistTracks,
        arguments: PlaylistTracksArgs(
          playlist: playlist,
          searchQuery: tracksFilter.query,
          sortBy: tracksFilter.sortBy,
        ));
  }

  bool _onTrackTap(Track track) {
    final fulfilled = SubscriptionEnforcement.fulfilSubscriptionRequirement(
      context,
      feature: "listen-online", text: LocaleResources.of(context).yourSubscriptionDoesNotAllowListenOline,
    );
    if (fulfilled){
      final request = _playlistModel.createPlayTrackRequest(track);
      locator<AudioPlaybackActionsModel>().playTrackUsingRequest(request);
    }
    return true;
  }

  bool _onTrackOptionsTap(Track track) {
    TrackOptionsBottomSheet.show(
      context,
      args: TrackOptionsArgs(track: track, playlist: _playlistModel.playlist),
    );
    return true;
  }
}

class _PlaylistTitleBar extends StatelessWidget {
  const _PlaylistTitleBar({
    Key? key,
    required this.onTitleTap,
  }) : super(key: key);

  final VoidCallback onTitleTap;

  @override
  Widget build(BuildContext context) {
    return Selector<PlaylistModel, String?>(
        selector: (_, model) => model.playlistTitle,
        builder: (_, title, __) {
          return PageTitleBarText(
              text: title ?? LocaleResources.of(context).playlist,
              color: DynamicTheme.get(context).white(),
              onTap: onTitleTap);
        });
  }
}

class _PlaylistTitleBarPlayButton extends StatelessWidget {
  const _PlaylistTitleBarPlayButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<PlaylistModel, bool>(
        selector: (_, model) => model.canShowPlaybackControls,
        builder: (_, canShowPlaybackControls, __) {
          if (!canShowPlaybackControls) return const SizedBox.shrink();

          return Container(
            margin: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
            child: PlaylistPlayButton(
                playlist: context.read<PlaylistModel>().playlist!,
                iconSize: ComponentSize.normal.r,
                size: ComponentSize.normal.r),
          );
        });
  }
}

class _PlaylistPageHeader extends StatelessWidget {
  const _PlaylistPageHeader({
    Key? key,
    required this.callback,
  }) : super(key: key);

  final PlaylistPageActionCallback callback;

  @override
  Widget build(BuildContext context) {
    final appBarSize = 236.r;
    final artworkCoverPhotoHeight = 236.r;
    final artworkPhotoSize = 160.r;

    return Container(
        height: appBarSize,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(ComponentRadius.normal.h),
                bottomRight: Radius.circular(ComponentRadius.normal.h))),
        clipBehavior: Clip.antiAlias,
        child: Stack(children: [
          /// ARTWORK: COVER PHOTO
          _PlaylistArtworkCoverPhoto(height: artworkCoverPhotoHeight),
          Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// TOP BAR ACTIONS: BACK, SHARE, DOWNLOAD, OPTIONS
                Row(children: [
                  const _BackButton(),
                  const Spacer(),
                  _LikeButton(onTap: callback.onLikeTap),
                  const _PlaylistVisibilityButton(),
                  //_DownloadButton(onTap: callback.onDownloadTap),
                  _OptionsButton(onTap: callback.onOptionsTap),
                ]),
                SizedBox(height: ComponentInset.small.h),
                Container(
                    height: artworkPhotoSize,
                    padding: EdgeInsets.symmetric(
                        horizontal: ComponentInset.normal.r),
                    child: Row(children: [
                      /// ARTWORK: PHOTO
                      _PlaylistArtworkPhoto(size: artworkPhotoSize),
                      SizedBox(width: ComponentInset.small.r),

                      /// PLAYBACK CONTROLS
                      const Expanded(child: _PlaylistPlaybackTrigger()),
                    ])),
              ])
        ]));
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppIconButton(
        width: ComponentSize.large.r,
        height: ComponentSize.large.r,
        assetColor: DynamicTheme.get(context).white(),
        assetPath: Assets.iconArrowLeft,
        padding: EdgeInsets.all(ComponentInset.small.r),
        onPressed: () => DashboardNavigation.pop(context));
  }
}

class _LikeButton extends StatelessWidget {
  const _LikeButton({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Selector<PlaylistModel, Tuple2<bool, bool>>(
        selector: (_, model) => Tuple2(model.canShowLikeOption, model.liked),
        builder: (_, tuple, __) {
          final canShow = tuple.item1;
          if (!canShow) return Container();

          final liked = tuple.item2;
          return AppIconButton(
              width: ComponentSize.large.r,
              height: ComponentSize.large.r,
              assetColor: DynamicTheme.get(context).white(),
              assetPath:
                  liked ? Assets.iconHeartFilled : Assets.iconHeartOutline,
              padding: EdgeInsets.all(ComponentInset.small.r),
              onPressed: onTap);
        });
  }
}

class _PlaylistVisibilityButton extends StatelessWidget {
  const _PlaylistVisibilityButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<PlaylistModel, Tuple2<bool, Playlist?>>(
        selector: (_, model) =>
            Tuple2(model.canShowVisibilityOption, model.playlist),
        builder: (_, tuple, __) {
          final canShow = tuple.item1;
          final playlist = tuple.item2;
          if (!canShow || playlist == null) return Container();

          return PlaylistVisibilityIconButton(playlist: playlist);
        });
  }
}

class _DownloadButton extends StatelessWidget {
  const _DownloadButton({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Selector<PlaylistModel, bool>(
        selector: (_, model) => model.canShowOptions,
        builder: (_, canShowOptions, __) {
          if (!canShowOptions) return Container();
          return AppIconButton(
              width: ComponentSize.large.r,
              height: ComponentSize.large.r,
              assetColor: DynamicTheme.get(context).white(),
              assetPath: Assets.iconDownload,
              padding: EdgeInsets.all(ComponentInset.small.r),
              onPressed: onTap);
        });
  }
}

class _OptionsButton extends StatelessWidget {
  const _OptionsButton({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Selector<PlaylistModel, bool>(
        selector: (_, model) => model.canShowOptions,
        builder: (_, canShowOptions, __) {
          if (!canShowOptions) return Container();
          return AppIconButton(
              width: ComponentSize.large.r,
              height: ComponentSize.large.r,
              assetColor: DynamicTheme.get(context).white(),
              assetPath: Assets.iconOptions,
              padding: EdgeInsets.all(ComponentInset.small.r),
              onPressed: onTap);
        });
  }
}

class _PlaylistArtworkPhoto extends StatelessWidget {
  const _PlaylistArtworkPhoto({
    Key? key,
    required this.size,
  }) : super(key: key);

  final double size;

  @override
  Widget build(BuildContext context) {
    return Selector<PlaylistModel, String?>(
        selector: (_, model) => model.playlistArtwork,
        builder: (_, artwork, __) {
          return Photo.playlist(
            artwork,
            options: PhotoOptions(
                width: size,
                height: size,
                borderRadius: BorderRadius.circular(ComponentRadius.normal.r)),
          );
        });
  }
}

class _PlaylistArtworkCoverPhoto extends StatelessWidget {
  const _PlaylistArtworkCoverPhoto({
    Key? key,
    required this.height,
  }) : super(key: key);

  final double height;

  @override
  Widget build(BuildContext context) {
    return Selector<PlaylistModel, String?>(
        selector: (_, model) => model.playlistArtworkCover,
        builder: (_, photoPath, __) {
          return Opacity(
              opacity: 0.6,
              child: BlurredCoverPhoto(
                photoPath: photoPath,
                photoKind: PhotoKind.playlist,
                height: height,
              ));
        });
  }
}

class _PlaylistPlaybackTrigger extends StatelessWidget {
  const _PlaylistPlaybackTrigger({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<PlaylistModel, bool>(
        selector: (_, model) => model.canShowPlaybackControls,
        builder: (_, canShowPlaybackControls, __) {
          if (!canShowPlaybackControls) return const SizedBox.shrink();

          return Sonar(
            duration: const Duration(seconds: 4),
            size: 148.r,
            waveColor: Colors.white.withOpacity(0.2),
            waveStrokeWidth: 2.r,
            child: PlaylistPlayButton(
              playlist: context.read<PlaylistModel>().playlist!,
              iconSize: 40.r,
              size: 72.r,
            ),
          );
        });
  }
}

class _PlaylistTitle extends StatelessWidget {
  const _PlaylistTitle({
    Key? key,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Selector<PlaylistModel, String?>(
        selector: (_, model) => model.playlistTitle,
        builder: (_, title, __) {
          return Container(
              alignment: Alignment.centerLeft,
              padding: padding,
              child: Text(
                title ?? LocaleResources.of(context).playlist,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyles.boldHeading2
                    .copyWith(color: DynamicTheme.get(context).white()),
                textAlign: TextAlign.left,
              ));
        });
  }
}

class _PlaylistDetail extends StatelessWidget {
  const _PlaylistDetail({
    Key? key,
    required this.callback,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  final PlaylistPageActionCallback callback;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Selector<PlaylistModel, Result<Playlist>?>(
        selector: (_, model) => model.playlistResult,
        builder: (_, result, __) {
          if (result == null) {
            return Padding(
              padding: EdgeInsets.only(top: ComponentInset.large.r),
              child: const LoadingIndicator(),
            );
          }

          if (!result.isSuccess()) {
            return Padding(
              padding: EdgeInsets.only(top: ComponentInset.large.r),
              child: ErrorIndicator(
                error: result.error(),
                onTryAgain: callback.onReloadTap,
              ),
            );
          }

          return Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _PlaylistSubtitle(),
                _PlaylistOwner(
                    onFollowTap: callback.onFollowUserTap,
                    onTap: callback.onUserTap),
                SizedBox(height: ComponentInset.normal.r),
                _PlaylistCollaborationNote(
                  margin: EdgeInsets.only(bottom: ComponentInset.normal.r),
                ),
                _PlaylistCollaboratorsNote(
                  margin: EdgeInsets.only(bottom: ComponentInset.normal.r),
                  onTap: callback.onManageCollaboratorsButtonTap,
                ),
                _PlaylistTracksSearchBar(
                    onFilterTap: callback.onTracksFilterButtonTap),
                _PlaylistAddTracksButton(onTap: callback.onAddTracksTap),
                SizedBox(height: ComponentInset.normal.r),
              ],
            ),
          );
        });
  }
}

class _PlaylistSubtitle extends StatelessWidget {
  const _PlaylistSubtitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<PlaylistModel, PlaylistSubtitleInfo?>(
        selector: (_, model) => model.playlistSubtitleInfo,
        builder: (_, info, __) {
          if (info == null) return const SizedBox.shrink();

          final subtitle = locator<PlaylistActionsModel>()
              .generatePlaylistSubtitle(context, info: info);
          return Text(
            subtitle,
            overflow: TextOverflow.ellipsis,
            style: TextStyles.body
                .copyWith(color: DynamicTheme.get(context).neutral20()),
            textAlign: TextAlign.left,
          );
        });
  }
}

class _PlaylistOwner extends StatelessWidget {
  const _PlaylistOwner({
    Key? key,
    required this.onFollowTap,
    required this.onTap,
  }) : super(key: key);

  final Function(User) onFollowTap;
  final Function(User) onTap;

  @override
  Widget build(BuildContext context) {
    return Selector<PlaylistModel, User?>(
        selector: (_, model) => model.playlistOwner,
        builder: (_, owner, __) {
          if (owner == null) return Container();
          return Container(
              margin: EdgeInsets.only(top: ComponentInset.normal.r),
              child: UserTileItem(
                  user: owner,
                  onTap: () => onTap(owner),
                  onFollowTap: () => onFollowTap(owner)));
        });
  }
}

class _PlaylistCollaborationNote extends StatelessWidget {
  const _PlaylistCollaborationNote({
    Key? key,
    required this.margin,
  }) : super(key: key);

  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    return Selector<PlaylistModel, bool>(
        selector: (_, model) => model.isAddedAsCollaborator,
        builder: (_, isAddedAsCollaborator, __) {
          if (!isAddedAsCollaborator) return const SizedBox.shrink();
          return Container(
            margin: margin,
            child: Text(
              LocaleResources.of(context).playlistCollaboratorNote,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.body
                  .copyWith(color: DynamicTheme.get(context).neutral20()),
              textAlign: TextAlign.left,
            ),
          );
        });
  }
}

class _PlaylistCollaboratorsNote extends StatelessWidget {
  const _PlaylistCollaboratorsNote({
    Key? key,
    required this.margin,
    required this.onTap,
  }) : super(key: key);

  final EdgeInsets margin;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Selector<PlaylistModel, int?>(
        selector: (_, model) => model.sharedWithCollaboratorsCount,
        builder: (_, total, __) {
          if (total == null) return const SizedBox.shrink();
          final text = LocaleResources.of(context)
              .playlistSharedWithCollaboratorsButton(total);
          return Container(
            margin: margin,
            child: Button(
              height: ComponentSize.small.r,
              onPressed: onTap,
              text: text,
              type: ButtonType.text,
            ),
          );
        });
  }
}

class _PlaylistTracksSearchBar extends StatelessWidget {
  const _PlaylistTracksSearchBar({
    Key? key,
    required this.onFilterTap,
  }) : super(key: key);

  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    final model = context.read<PlaylistModel>();
    return SearchBar(
        hintText: LocaleResources.of(context).playlistTracksSearchHint,
        onQueryChanged: model.updateTracksSearchQuery,
        onQueryCleared: model.clearTracksSearchQuery,
        suffixes: [
          Selector<PlaylistModel, bool>(
              selector: (_, model) => model.tracksFiltered,
              builder: (_, filtered, __) {
                return FilterIconSuffix(
                    isSelected: filtered, onPressed: onFilterTap);
              }),
        ]);
  }
}

class _PlaylistAddTracksButton extends StatelessWidget {
  const _PlaylistAddTracksButton({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Selector<PlaylistModel, bool>(
        selector: (_, model) => model.canShowAddTracksOption,
        builder: (_, canShowAddTracksOption, __) {
          if (!canShowAddTracksOption) return const SizedBox.shrink();
          return Button(
            width: double.infinity,
            margin: EdgeInsets.only(top: ComponentInset.normal.r),
            onPressed: onTap,
            text: LocaleResources.of(context).playlistAddSongs,
            type: ButtonType.secondary,
          );
        });
  }
}

class _PlaylistTracksSliver extends StatelessWidget {
  const _PlaylistTracksSliver({
    Key? key,
    required this.playlistId,
    this.padding = EdgeInsets.zero,
    required this.onTrackTap,
    required this.onTrackOptionsTap,
  }) : super(key: key);

  final String playlistId;
  final EdgeInsets padding;
  final bool Function(Track) onTrackTap;
  final bool Function(Track) onTrackOptionsTap;

  @override
  Widget build(BuildContext context) {
    return Selector<PlaylistModel, Tuple2<bool, Result<ListPage<Track>>?>>(
        selector: (_, model) =>
            Tuple2(model.canShowOptions, model.tracksResult),
        builder: (_, tuple, __) {
          final canShowOptions = tuple.item1;
          if (!canShowOptions) return const SliverToBoxAdapter();

          final tracksResult = tuple.item2;
          if (tracksResult == null) {
            return SliverToBoxAdapter(
              child: Padding(
                  padding: EdgeInsets.only(top: ComponentInset.larger.r),
                  child: const LoadingIndicator()),
            );
          }

          if (!tracksResult.isSuccess()) {
            return SliverToBoxAdapter(
              child: ErrorIndicator(
                  error: tracksResult.error(),
                  onTryAgain: () {
                    context.read<PlaylistModel>().fetchPlaylistTracks();
                  }),
            );
          }

          if (tracksResult.isEmpty() || tracksResult.data().isEmpty) {
            return SliverToBoxAdapter(
              child: _EmptyPlaylistDeclaration(padding: padding),
            );
          }

          final tracks = tracksResult.data().items??[];
          return SliverList(
            delegate: SliverChildBuilderDelegate((_, index) {
              return Padding(
                padding: EdgeInsets.only(
                    left: padding.left,
                    right: padding.right,
                    bottom: ComponentInset.normal.r),
                child: TrackListItem(
                  track: tracks[index],
                  onTap: onTrackTap,
                  onOptionsButtonTap: onTrackOptionsTap,
                ),
              );
            }, childCount: tracks.length),
          );
        });
  }
}

class _EmptyPlaylistDeclaration extends StatelessWidget {
  const _EmptyPlaylistDeclaration({
    Key? key,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      child: Selector<PlaylistModel, bool>(
          selector: (_, model) => model.hasTracksSearchQuery,
          builder: (_, hasTracksSearchQuery, __) {
            return Text(
              hasTracksSearchQuery
                  ? LocaleResources.of(context)
                      .playlistTracksSearchResultsAreEmpty
                  : LocaleResources.of(context).playlistIsEmpty,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.body
                  .copyWith(color: DynamicTheme.get(context).neutral20()),
              textAlign: TextAlign.left,
            );
          }),
    );
  }
}

class _SeeAllPlaylistTracksButton extends StatelessWidget {
  const _SeeAllPlaylistTracksButton({
    Key? key,
    required this.onTap,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  final EdgeInsets padding;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Selector<PlaylistModel, bool>(
        selector: (_, model) => model.canShowSeeAllSongsOption,
        builder: (_, canShowSeeAllSongsOption, __) {
          if (!canShowSeeAllSongsOption) {
            return const SizedBox.shrink();
          }

          return Container(
              alignment: Alignment.centerLeft,
              padding: padding,
              child: Button(
                height: ComponentSize.smaller.h,
                onPressed: onTap,
                text: LocaleResources.of(context).seeAll,
                type: ButtonType.text,
              ));
        });
  }
}

class _PlaylistFeedsSliver extends StatelessWidget {
  const _PlaylistFeedsSliver({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<PlaylistModel, List<Feed>?>(
        selector: (_, model) => model.feeds,
        builder: (_, feeds, __) {
          if (feeds == null || feeds.isEmpty) {
            return const SliverToBoxAdapter();
          }

          return FeedSliverList(feeds: feeds);
        });
  }
}
