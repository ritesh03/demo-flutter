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
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/album/album_actions.model.dart';
import 'package:kwotmusic/features/album/options/album_options.bottomsheet.dart';
import 'package:kwotmusic/features/album/options/album_options.model.dart';
import 'package:kwotmusic/features/artist/artist_actions.model.dart';
import 'package:kwotmusic/features/artist/profile/artist.model.dart';
import 'package:kwotmusic/features/artist/widget/artist_tile_item.dart';
import 'package:kwotmusic/features/artist/widget/artists_horizontal_compact_list_view.widget.dart';
import 'package:kwotmusic/features/dashboard/dashboard_config.dart';
import 'package:kwotmusic/features/playback/audio/audio_playback_actions.model.dart';
import 'package:kwotmusic/features/playback/widget/playbutton/album_play_button.widget.dart';
import 'package:kwotmusic/features/track/list/tracks.args.dart';
import 'package:kwotmusic/features/track/options/track_options.bottomsheet.dart';
import 'package:kwotmusic/features/track/options/track_options.model.dart';
import 'package:kwotmusic/features/track/widget/track_list_item.widget.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:kwotmusic/util/util.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../../profile/subscriptions/subscription_enforcement.dart';
import 'album.model.dart';
import 'album.page.actions.dart';

class AlbumPage extends StatefulWidget {
  const AlbumPage({Key? key}) : super(key: key);

  @override
  State<AlbumPage> createState() => _AlbumPageState();
}

class _AlbumPageState extends PageState<AlbumPage>
    implements AlbumPageActionCallback {
  //=
  late ScrollController _scrollController;

  AlbumModel get _albumModel => context.read<AlbumModel>();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    _albumModel.init();
  }

  @override
  Widget build(BuildContext context) {
    final padding = EdgeInsets.symmetric(horizontal: ComponentInset.normal.r);
    return SafeArea(
      child: Scaffold(
        body: PageTitleBarWrapper(
          barHeight: ComponentSize.large.r,
          title: _AlbumTitleBar(onTitleTap: _scrollController.animateToTop),
          centerTitle: false,
          actions: const [
            _AlbumTitleBarPlayButton(),
          ],
          child: RefreshIndicator(
            color: DynamicTheme.get(context).secondary100(),
            backgroundColor: DynamicTheme.get(context).black(),
            onRefresh: () => Future.sync(() => onReloadAlbumTap()),
            child: CustomScrollView(controller: _scrollController, slivers: [
              SliverToBoxAdapter(
                child: Column(children: [
                  _AlbumPageHeader(callback: this),
                  SizedBox(height: ComponentInset.small.r),
                  _AlbumTitle(padding: padding),
                  _AlbumDetail(callback: this, padding: padding),
                  SizedBox(height: ComponentInset.normal.r),
                ]),
              ),
              _AlbumTracksSliver(
                albumId: _albumModel.albumId,
                padding: padding,
                onTrackTap: _onTrackTap,
                onTrackOptionsTap: _onTrackOptionsTap,
              ),
              SliverToBoxAdapter(
                child: _SeeAllAlbumTracksButton(
                  padding: padding,
                  onTap: onSeeAllTracksTap,
                ),
              ),
              const _AlbumFeedsSliver(),
              DashboardConfigAwareFooter.asSliver(),
            ]),
          ),
        ),
      ),
    );
  }

  @override
  void onArtistTap(Artist artist) {
    final args = ArtistPageArgs.object(artist: artist);
    DashboardNavigation.pushNamed(context, Routes.artist, arguments: args);
  }

  @override
  void onBackTap() {
    DashboardNavigation.pop(context);
  }

  @override
  void onDownloadTap() {
    final album = _albumModel.album;
    if (album == null) return;

    // TODO: implement onDownloadTap
  }

  @override
  void onFollowArtistTap(Artist artist) async {
    showBlockingProgressDialog(context);

    final result = await locator<ArtistActionsModel>().setIsFollowed(
      id: artist.id,
      shouldFollow: !artist.isFollowed,
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
    final album = _albumModel.album;
    if (album == null) return;

    showBlockingProgressDialog(context);
    final result = await locator<AlbumActionsModel>().toggleLike(album);

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
  void onOptionsTap() {
    final album = _albumModel.album;
    if (album == null) return;

    final args = AlbumOptionsArgs(album: album, isOnAlbumPage: true);
    AlbumOptionsBottomSheet.show(context, args: args);
  }

  @override
  void onReloadAlbumTap() {
    _albumModel.fetchAlbum();
  }

  @override
  void onSeeAllTracksTap() {
    final album = _albumModel.album;
    if (album == null) return;

    DashboardNavigation.pushNamed(context, Routes.tracks,
        arguments: TrackListArgs(albumId: album.id));
  }

  bool _onTrackTap(Track track) {
    final fulfilled = SubscriptionEnforcement.fulfilSubscriptionRequirement(
      context,
      feature: "listen-online", text: LocaleResources.of(context).yourSubscriptionDoesNotAllowListenOline,
    );
   if(fulfilled){
     final request = _albumModel.createPlayTrackRequest(track);
     locator<AudioPlaybackActionsModel>().playTrackUsingRequest(request);
   }
    return true;
  }

  bool _onTrackOptionsTap(Track track) {
    final album = _albumModel.album;
    if (album == null) return false;

    final args = TrackOptionsArgs(track: track, album: album);
    TrackOptionsBottomSheet.show(context, args: args);
    return true;
  }
}

class _AlbumTitleBar extends StatelessWidget {
  const _AlbumTitleBar({
    Key? key,
    required this.onTitleTap,
  }) : super(key: key);

  final VoidCallback onTitleTap;

  @override
  Widget build(BuildContext context) {
    return Selector<AlbumModel, String?>(
        selector: (_, model) => model.albumTitle,
        builder: (_, title, __) {
          return PageTitleBarText(
              text: title ?? LocaleResources.of(context).album,
              color: DynamicTheme.get(context).white(),
              onTap: onTitleTap);
        });
  }
}

class _AlbumTitleBarPlayButton extends StatelessWidget {
  const _AlbumTitleBarPlayButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<AlbumModel, bool>(
        selector: (_, model) => model.canShowPlaybackControls,
        builder: (_, canShowPlaybackControls, __) {
          if (!canShowPlaybackControls) return const SizedBox.shrink();

          return Container(
            margin: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
            child: AlbumPlayButton(
                album: context.read<AlbumModel>().album!,
                iconSize: ComponentSize.normal.r,
                size: ComponentSize.normal.r),
          );
        });
  }
}

class _AlbumPageHeader extends StatelessWidget {
  const _AlbumPageHeader({
    Key? key,
    required this.callback,
  }) : super(key: key);

  final AlbumPageActionCallback callback;

  @override
  Widget build(BuildContext context) {
    final appBarSize = 236.r;
    final albumArtworkCoverPhotoHeight = 236.r;
    final albumArtworkPhotoSize = 160.r;

    return Container(
        height: appBarSize,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(ComponentRadius.normal.h),
                bottomRight: Radius.circular(ComponentRadius.normal.h))),
        clipBehavior: Clip.antiAlias,
        child: Stack(children: [
          /// ARTWORK: COVER PHOTO
          _AlbumArtworkCoverPhoto(height: albumArtworkCoverPhotoHeight),
          Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// TOP BAR ACTIONS: BACK, SHARE, DOWNLOAD, OPTIONS
                Row(children: [
                  const _BackButton(),
                  const Spacer(),
                  _LikeButton(onTap: callback.onLikeTap),
                  // _DownloadButton(onTap: callback.onDownloadTap),
                  _OptionsButton(onTap: callback.onOptionsTap),
                ]),
                SizedBox(height: ComponentInset.small.h),
                Container(
                    height: albumArtworkPhotoSize,
                    padding: EdgeInsets.symmetric(
                        horizontal: ComponentInset.normal.r),
                    child: Row(children: [
                      /// ARTWORK: PHOTO
                      _AlbumArtworkPhoto(size: albumArtworkPhotoSize),
                      SizedBox(width: ComponentInset.small.r),

                      /// PLAYBACK CONTROLS
                      const Expanded(child: _AlbumPlaybackTrigger()),
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
    return Selector<AlbumModel, Tuple2<bool, bool>>(
        selector: (_, model) => Tuple2(model.canShowOptions, model.liked),
        builder: (_, tuple, __) {
          final canShowOptions = tuple.item1;
          if (!canShowOptions) return Container();

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

class _DownloadButton extends StatelessWidget {
  const _DownloadButton({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Selector<AlbumModel, bool>(
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
    return Selector<AlbumModel, bool>(
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

class _AlbumArtworkPhoto extends StatelessWidget {
  const _AlbumArtworkPhoto({
    Key? key,
    required this.size,
  }) : super(key: key);

  final double size;

  @override
  Widget build(BuildContext context) {
    return Selector<AlbumModel, String?>(
        selector: (_, model) => model.albumArtwork,
        builder: (_, artwork, __) {
          return Photo.album(
            artwork,
            options: PhotoOptions(
                width: size,
                height: size,
                borderRadius: BorderRadius.circular(ComponentRadius.normal.r)),
          );
        });
  }
}

class _AlbumArtworkCoverPhoto extends StatelessWidget {
  const _AlbumArtworkCoverPhoto({
    Key? key,
    required this.height,
  }) : super(key: key);

  final double height;

  @override
  Widget build(BuildContext context) {
    return Selector<AlbumModel, String?>(
        selector: (_, model) => model.albumArtworkCover,
        builder: (_, photoPath, __) {
          return Opacity(
              opacity: 0.6,
              child: BlurredCoverPhoto(
                photoPath: photoPath,
                photoKind: PhotoKind.album,
                height: height,
              ));
        });
  }
}

class _AlbumPlaybackTrigger extends StatelessWidget {
  const _AlbumPlaybackTrigger({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<AlbumModel, bool>(
        selector: (_, model) => model.canShowPlaybackControls,
        builder: (_, canShowPlaybackControls, __) {
          if (!canShowPlaybackControls) return const SizedBox.shrink();

          return Sonar(
            duration: const Duration(seconds: 4),
            size: 148.r,
            waveColor: Colors.white.withOpacity(0.2),
            waveStrokeWidth: 2.r,
            child: AlbumPlayButton(
              album: context.read<AlbumModel>().album!,
              iconSize: 40.r,
              size: 72.r,
            ),
          );
        });
  }
}

class _AlbumTitle extends StatelessWidget {
  const _AlbumTitle({
    Key? key,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Selector<AlbumModel, String?>(
        selector: (_, model) => model.albumTitle,
        builder: (_, title, __) {
          return Container(
              alignment: Alignment.centerLeft,
              padding: padding,
              child: Text(
                title ?? LocaleResources.of(context).album,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyles.boldHeading2
                    .copyWith(color: DynamicTheme.get(context).white()),
                textAlign: TextAlign.left,
              ));
        });
  }
}

class _AlbumDetail extends StatelessWidget {
  const _AlbumDetail({
    Key? key,
    required this.callback,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  final AlbumPageActionCallback callback;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Selector<AlbumModel, Result<Album>?>(
        selector: (_, model) => model.albumResult,
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
                onTryAgain: callback.onReloadAlbumTap,
              ),
            );
          }

          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AlbumSubtitle(padding: padding),
                SizedBox(height: ComponentInset.normal.r),
                _AlbumArtists(
                    onFollowTap: callback.onFollowArtistTap,
                    onTap: callback.onArtistTap,
                    padding: padding),
                SizedBox(height: ComponentInset.small.r),
              ]);
        });
  }
}

class _AlbumSubtitle extends StatelessWidget {
  const _AlbumSubtitle({
    Key? key,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Selector<AlbumModel, AlbumSubtitleInfo?>(
        selector: (_, model) => model.albumSubtitleInfo,
        builder: (context, info, __) {
          if (info == null) return const SizedBox.shrink();

          final subtitle = locator<AlbumActionsModel>()
              .generateAlbumSubtitle(context, info: info);
          return Container(
              alignment: Alignment.centerLeft,
              padding: padding,
              child: Text(
                subtitle,
                overflow: TextOverflow.ellipsis,
                style: TextStyles.body
                    .copyWith(color: DynamicTheme.get(context).neutral20()),
                textAlign: TextAlign.left,
              ));
        });
  }
}

class _AlbumArtists extends StatelessWidget {
  const _AlbumArtists({
    Key? key,
    required this.onFollowTap,
    required this.onTap,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  final Function(Artist) onFollowTap;
  final Function(Artist) onTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Selector<AlbumModel, List<Artist>?>(
        selector: (_, model) => model.albumArtists,
        builder: (_, artists, __) {
          if (artists == null || artists.isEmpty) return Container();
          if (artists.length == 1) {
            final artist = artists.first;
            return Padding(
                padding: padding,
                child: ArtistTileItem(
                    artist: artist,
                    onTap: () => onTap(artist),
                    onFollowTap: () => onFollowTap(artist)));
          }

          return ArtistsHorizontalCompactListView(
              artists: artists,
              padding: padding,
              onTap: onTap,
              onFollowTap: onFollowTap);
        });
  }
}

class _AlbumTracksSliver extends StatelessWidget {
  const _AlbumTracksSliver({
    Key? key,
    required this.albumId,
    this.padding = EdgeInsets.zero,
    required this.onTrackTap,
    required this.onTrackOptionsTap,
  }) : super(key: key);

  final String albumId;
  final EdgeInsets padding;
  final bool Function(Track) onTrackTap;
  final bool Function(Track) onTrackOptionsTap;

  @override
  Widget build(BuildContext context) {
    return Selector<AlbumModel, Tuple2<bool, List<Track>?>>(
        selector: (_, model) => Tuple2(model.canShowOptions, model.tracks),
        builder: (_, tuple, __) {
          final canShowOptions = tuple.item1;
          if (!canShowOptions) return const SliverToBoxAdapter();

          final tracks = tuple.item2;
          if (tracks == null || tracks.isEmpty) {
            return SliverToBoxAdapter(
              child: _EmptyAlbumDeclaration(padding: padding),
            );
          }

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

class _EmptyAlbumDeclaration extends StatelessWidget {
  const _EmptyAlbumDeclaration({
    Key? key,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      child: Text(
        LocaleResources.of(context).albumIsEmpty,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.body
            .copyWith(color: DynamicTheme.get(context).neutral20()),
        textAlign: TextAlign.left,
      ),
    );
  }
}

class _SeeAllAlbumTracksButton extends StatelessWidget {
  const _SeeAllAlbumTracksButton({
    Key? key,
    required this.onTap,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  final EdgeInsets padding;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Selector<AlbumModel, bool>(
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

class _AlbumFeedsSliver extends StatelessWidget {
  const _AlbumFeedsSliver({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<AlbumModel, List<Feed>?>(
        selector: (_, model) => model.feeds,
        builder: (_, feeds, __) {
          if (feeds == null || feeds.isEmpty) {
            return const SliverToBoxAdapter();
          }

          return FeedSliverList(feeds: feeds);
        });
  }
}
