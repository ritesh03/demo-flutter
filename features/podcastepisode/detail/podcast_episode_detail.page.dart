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
import 'package:kwotmusic/features/artist/artist_actions.model.dart';
import 'package:kwotmusic/features/artist/profile/artist.model.dart';
import 'package:kwotmusic/features/artist/widget/artist_tile_item.dart';
import 'package:kwotmusic/features/artist/widget/artists_horizontal_compact_list_view.widget.dart';
import 'package:kwotmusic/features/dashboard/dashboard_config.dart';
import 'package:kwotmusic/features/playback/playback.dart';
import 'package:kwotmusic/features/playback/widget/playbutton/podcast_episode_play_button.widget.dart';
import 'package:kwotmusic/features/podcast/detail/podcast_detail.model.dart';
import 'package:kwotmusic/features/podcastepisode/list/option/podcast_episode_options.bottomsheet.dart';
import 'package:kwotmusic/features/podcastepisode/list/option/podcast_episode_options.model.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:kwotmusic/util/util.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:share_plus/share_plus.dart';

import 'podcast_episode_detail.model.dart';

class PodcastEpisodeDetailPage extends StatefulWidget {
  const PodcastEpisodeDetailPage({Key? key}) : super(key: key);

  @override
  State<PodcastEpisodeDetailPage> createState() =>
      _PodcastEpisodeDetailPageState();
}

class _PodcastEpisodeDetailPageState
    extends PageState<PodcastEpisodeDetailPage> {
  //=

  final _appBarSize = 224.h;
  final _episodeBackgroundPhotoSize = 224.h;
  final _episodeForegroundPhotoSize = 160.h;

  @override
  void initState() {
    super.initState();
    episodeDetailModelOf(context).init();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Selector<PodcastEpisodeDetailModel, Result<PodcastEpisode>?>(
            selector: (_, model) => model.episodeResult,
            builder: (_, result, __) {
              if (result == null) {
                final child = Padding(
                    padding: EdgeInsets.only(top: ComponentInset.large.h),
                    child: const LoadingIndicator());
                return _buildHeader(placeholder: child);
              }

              if (!result.isSuccess()) {
                final child = Padding(
                    padding: EdgeInsets.only(top: ComponentInset.large.h),
                    child: ErrorIndicator(
                        error: result.error(),
                        onTryAgain:
                            episodeDetailModelOf(context).fetchEpisodeDetail));
                return _buildHeader(placeholder: child);
              }

              return _buildItemList();
            }),
      ),
    );
  }

  /*
   * HEADER
   */

  Widget _buildHeader({Widget? placeholder}) {
    final padding = EdgeInsets.symmetric(horizontal: ComponentInset.normal.r);
    return Column(children: [
      _buildToolbarContent(),
      SizedBox(height: ComponentInset.small.h),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: padding, child: _buildEpisodeTitle()),
        if (placeholder != null) placeholder,
        if (placeholder == null) ...{
          Padding(padding: padding, child: _buildEpisodeDateAndDuration()),
          SizedBox(height: ComponentInset.small.h),
          _buildEpisodeArtists(padding),
          SizedBox(height: ComponentInset.small.h),
          Padding(padding: padding, child: _buildEpisodeDescription()),
          SizedBox(height: ComponentInset.normal.h),
          Padding(padding: padding, child: _buildSeeAllEpisodesButton()),
        },
      ])
    ]);
  }

  /*
   * TOOLBAR CONTENT
   */

  Widget _buildToolbarContent() {
    return Container(
        height: _appBarSize,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(ComponentRadius.normal.h),
                bottomRight: Radius.circular(ComponentRadius.normal.h))),
        clipBehavior: Clip.antiAlias,
        child: Stack(children: [
          _buildEpisodeBackgroundPhoto(),
          Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildToolbarIcons(),
                SizedBox(height: ComponentInset.small.h),
                Container(
                    height: _episodeForegroundPhotoSize,
                    padding: EdgeInsets.symmetric(
                        horizontal: ComponentInset.normal.r),
                    child: Row(children: [
                      _buildEpisodeForegroundPhoto(),
                      SizedBox(width: ComponentInset.small.r),
                      Expanded(
                        child: Column(children: [
                          const Spacer(),
                          _buildEpisodePlayBar(),
                          _buildEpisodeSeekBar(),
                        ]),
                      ),
                    ])),
              ])
        ]));
  }

  /*
   * TOOLBAR BACKGROUND
   */

  Widget _buildEpisodeBackgroundPhoto() {
    return Selector<PodcastEpisodeDetailModel, String?>(
        selector: (_, model) => model.episodeThumbnail,
        builder: (_, photoPath, __) {
          return Opacity(
              opacity: 0.6,
              child: BlurredCoverPhoto(
                photoPath: photoPath,
                photoKind: PhotoKind.podcastEpisode,
                height: _episodeBackgroundPhotoSize,
              ));
        });
  }

  /*
   * TOOLBAR ICONS: BACK, SHARE, DOWNLOAD, OPTIONS
   */

  Widget _buildToolbarIcons() {
    return Row(children: [
      _buildBackButton(),
      const Spacer(),
      _buildShareButton(),
      // _buildDownloadButton(),
      _buildOptionsButton(),
    ]);
  }

  Widget _buildBackButton() {
    return AppIconButton(
        width: ComponentSize.large.r,
        height: ComponentSize.large.r,
        assetColor: DynamicTheme.get(context).white(),
        assetPath: Assets.iconArrowLeft,
        padding: EdgeInsets.all(ComponentInset.small.r),
        onPressed: () => DashboardNavigation.pop(context));
  }

  Widget _buildShareButton() {
    return Selector<PodcastEpisodeDetailModel, PodcastEpisode?>(
        selector: (_, model) => model.episode,
        builder: (_, episode, __) {
          if (episode == null) return Container();
          return AppIconButton(
              width: ComponentSize.large.r,
              height: ComponentSize.large.r,
              assetColor: DynamicTheme.get(context).white(),
              assetPath: Assets.iconShare,
              padding: EdgeInsets.all(ComponentInset.small.r),
              onPressed: _onSharePodcastEpisodeTapped);
        });
  }

  Widget _buildDownloadButton() {
    return Selector<PodcastEpisodeDetailModel, PodcastEpisode?>(
        selector: (_, model) => model.episode,
        builder: (_, episode, __) {
          if (episode == null) return Container();
          return AppIconButton(
              width: ComponentSize.large.r,
              height: ComponentSize.large.r,
              assetColor: DynamicTheme.get(context).white(),
              assetPath: Assets.iconDownload,
              padding: EdgeInsets.all(ComponentInset.small.r),
              onPressed: _onDownloadPodcastEpisodeTapped);
        });
  }

  Widget _buildOptionsButton() {
    return Selector<PodcastEpisodeDetailModel, PodcastEpisode?>(
        selector: (_, model) => model.episode,
        builder: (_, episode, __) {
          if (episode == null) return Container();
          return AppIconButton(
              width: ComponentSize.large.r,
              height: ComponentSize.large.r,
              assetColor: DynamicTheme.get(context).white(),
              assetPath: Assets.iconOptions,
              padding: EdgeInsets.all(ComponentInset.small.r),
              onPressed: _onPodcastEpisodeOptionsTapped);
        });
  }

  /*
   * TOOLBAR FOREGROUND
   */

  Widget _buildEpisodeForegroundPhoto() {
    return Selector<PodcastEpisodeDetailModel, String?>(
        selector: (_, model) => model.episodeThumbnail,
        builder: (_, photoPath, __) {
          return Photo.podcastEpisode(
            photoPath,
            options: PhotoOptions(
                width: _episodeForegroundPhotoSize,
                height: _episodeForegroundPhotoSize,
                borderRadius: BorderRadius.circular(ComponentRadius.normal.r)),
          );
        });

    // final episodeId = episodeDetailModelOf(context).episode.id;
    // return Hero(tag: PodcastEpisodeHeroTag.photo(episodeId), child: widget);
  }

  Widget _buildEpisodePlayBar() {
    return Selector<PodcastEpisodeDetailModel, PodcastEpisode?>(
        selector: (_, model) => model.episode,
        builder: (_, episode, __) {
          if (episode == null) return Container();

          return Row(children: [
            PodcastEpisodePlayButton(
                episode: episode, size: ComponentSize.normal.r),
            SizedBox(width: ComponentInset.small.w),
            PlaybackRemainingDurationText(scopeId: episode.id),
          ]);
        });
  }

  Widget _buildEpisodeSeekBar() {
    return Container(
      alignment: Alignment.center,
      height: ComponentSize.normal.h,
      child: Selector<PodcastEpisodeDetailModel, PodcastEpisode?>(
          selector: (_, model) => model.episode,
          builder: (_, episode, __) {
            if (episode == null) return Container();

            return AudioPlayerSeekBar(
              scopeId: episode.id,
              compact: false,
              showTimeLabel: false,
            );
          }),
    );
  }

  /*
   * PAGE CONTENT
   */

  Widget _buildEpisodeTitle() {
    return Selector<PodcastEpisodeDetailModel, String?>(
        selector: (_, model) => model.episodeTitle,
        builder: (_, title, __) {
          return Text(title ?? "",
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.boldHeading2.copyWith(
                color: DynamicTheme.get(context).white(),
              ));
        });

    // final episodeId = episodeDetailModelOf(context).episode.id;
    // return Hero(tag: PodcastEpisodeHeroTag.title(episodeId), child: widget);
  }

  Widget _buildEpisodeArtists(EdgeInsets padding) {
    return Selector<PodcastEpisodeDetailModel, List<Artist>?>(
        selector: (_, model) => model.podcastArtists,
        builder: (_, artists, __) {
          if (artists == null || artists.isEmpty) return Container();
          if (artists.length == 1) {
            final artist = artists.first;
            return Padding(
                padding: padding,
                child: ArtistTileItem(
                    artist: artist,
                    onTap: () => _onPodcastArtistTapped(artist),
                    onFollowTap: () => _onFollowPodcastArtistTapped(artist)));
          }

          return ArtistsHorizontalCompactListView(
              artists: artists,
              padding: padding,
              onTap: _onPodcastArtistTapped,
              onFollowTap: _onFollowPodcastArtistTapped);
        });
  }

  Widget _buildEpisodeDateAndDuration() {
    return Selector<PodcastEpisodeDetailModel, PodcastEpisode?>(
        selector: (_, model) => model.episode,
        builder: (_, episode, __) {
          if (episode == null) return Container();
          final dateText = episode.createdAt.toDefaultDateFormat();
          final durationText = episode.duration.toCompactEpisodeDuration();
          return Text("$dateText · $durationText",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.boldBody.copyWith(
                color: DynamicTheme.get(context).white(),
              ));
        });
  }

  Widget _buildEpisodeDescription() {
    return Selector<PodcastEpisodeDetailModel, String?>(
        selector: (_, model) => model.episodeDescription,
        builder: (_, description, __) {
          if (description == null || description.isEmpty) return Container();
          final textColor = DynamicTheme.get(context).neutral10();
          return ReadMoreText(
            description,
            trimLines: 6,
            style: TextStyles.body.copyWith(color: textColor),
            trimMode: TrimMode.Line,
            trimCollapsedText: LocaleResources.of(context).readMore,
            trimExpandedText: LocaleResources.of(context).readLess,
            moreStyle: TextStyles.boldBody.copyWith(color: textColor),
            lessStyle: TextStyles.boldBody.copyWith(color: textColor),
          );
        });
  }

  Widget _buildSeeAllEpisodesButton() {
    return Selector<PodcastEpisodeDetailModel, PodcastEpisode?>(
        selector: (_, model) => model.episode,
        builder: (_, episode, __) {
          if (episode == null) return Container();
          return Button(
            onPressed: _onSeeAllPodcastEpisodesTapped,
            width: MediaQuery.of(context).size.width,
            height: ComponentSize.large.h,
            text: LocaleResources.of(context).seeAllPodcastEpisodes,
            type: ButtonType.secondary,
          );
        });
  }

  /*
   * FEEDS
   */

  Widget _buildFeedSliverList() {
    return Selector<PodcastEpisodeDetailModel, List<Feed>?>(
        selector: (_, model) => model.episodeFeeds,
        builder: (_, feeds, __) {
          if (feeds == null || feeds.isEmpty) {
            return const SliverToBoxAdapter();
          }

          return FeedSliverList(feeds: feeds);
        });
  }

  /*
   * BODY
   */

  Widget _buildItemList() {
    return RefreshIndicator(
      color: DynamicTheme.get(context).secondary100(),
      backgroundColor: DynamicTheme.get(context).black(),
      onRefresh: () =>
          Future.sync(() => episodeDetailModelOf(context).fetchEpisodeDetail()),
      child: CustomScrollView(slivers: [
        SliverToBoxAdapter(child: _buildHeader()),
        _buildFeedSliverList(),
        DashboardConfigAwareFooter.asSliver(),
      ]),
    );
  }

  PodcastEpisodeDetailModel episodeDetailModelOf(BuildContext context) {
    return context.read<PodcastEpisodeDetailModel>();
  }

  void _onSharePodcastEpisodeTapped() {
    final episode = episodeDetailModelOf(context).episode;
    if (episode == null) {
      return;
    }

    Share.share(episode.shareableLink);
  }

  void _onDownloadPodcastEpisodeTapped() {
    final episode = episodeDetailModelOf(context).episode;
    if (episode == null) {
      return;
    }

    // TODO: DOWNLOAD
  }

  void _onPodcastEpisodeOptionsTapped() {
    final episode = episodeDetailModelOf(context).episode;
    if (episode == null) {
      return;
    }

    final args =
        PodcastEpisodeOptionsArgs(episode: episode, isOnEpisodePage: true);
    PodcastEpisodeOptionsBottomSheet.show(context, args: args);
  }

  void _onPodcastArtistTapped(Artist artist) {
    final args = ArtistPageArgs.object(artist: artist);
    DashboardNavigation.pushNamed(context, Routes.artist, arguments: args);
  }

  void _onFollowPodcastArtistTapped(Artist artist) async {
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

  void _onSeeAllPodcastEpisodesTapped() {
    final episode = episodeDetailModelOf(context).episode;
    if (episode == null) return;

    final parentPagePodcastId =
        episodeDetailModelOf(context).parentPagePodcastId;
    if (parentPagePodcastId != null &&
        parentPagePodcastId == episode.podcastId) {
      DashboardNavigation.pop(context);
      return;
    }

    final args = PodcastDetailArgs(
      id: episode.podcastId,
      title: episode.podcastTitle,
      thumbnail: episode.thumbnail,
    );
    DashboardNavigation.pushNamed(context, Routes.podcast, arguments: args);
  }
}
