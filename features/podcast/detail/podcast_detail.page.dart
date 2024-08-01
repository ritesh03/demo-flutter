import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/blocking_progress.dialog.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/button/buttons.dart';
import 'package:kwotmusic/components/widgets/feed/feed_sliver_list.widget.dart';
import 'package:kwotmusic/components/widgets/indicator/indicators.dart';
import 'package:kwotmusic/components/widgets/list/item_list.widget.dart';
import 'package:kwotmusic/components/widgets/marquee/simple_marquee.dart';
import 'package:kwotmusic/components/widgets/notificationbar/notification_bar.dart';
import 'package:kwotmusic/components/widgets/page/page_state.dart';
import 'package:kwotmusic/components/widgets/photo/blurred_cover_photo.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';
import 'package:kwotmusic/components/widgets/textfield.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/artist/artist_actions.model.dart';
import 'package:kwotmusic/features/artist/profile/artist.model.dart';
import 'package:kwotmusic/features/artist/widget/artist_tile_item.dart';
import 'package:kwotmusic/features/artist/widget/artists_horizontal_compact_list_view.widget.dart';
import 'package:kwotmusic/features/dashboard/dashboard_config.dart';
import 'package:kwotmusic/features/podcast/filter/podcast_detail_episodes_filter.bottomsheet.dart';
import 'package:kwotmusic/features/podcast/filter/podcast_detail_episodes_filter_layout.widget.dart';
import 'package:kwotmusic/features/podcast/list/podcasts.model.dart';
import 'package:kwotmusic/features/podcast/widget/podcast_category_chip.dart';
import 'package:kwotmusic/features/podcast/widget/podcast_description.widget.dart';
import 'package:kwotmusic/features/podcastepisode/detail/podcast_episode_detail.model.dart';
import 'package:kwotmusic/features/podcastepisode/list/option/podcast_episode_options.bottomsheet.dart';
import 'package:kwotmusic/features/podcastepisode/list/option/podcast_episode_options.model.dart';
import 'package:kwotmusic/features/podcastepisode/widget/podcast_episode_detail_item.widget.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:kwotmusic/util/util.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tuple/tuple.dart';

import 'podcast_detail.model.dart';

class PodcastDetailPage extends StatefulWidget {
  const PodcastDetailPage({Key? key}) : super(key: key);

  @override
  State<PodcastDetailPage> createState() => _PodcastDetailPageState();
}

class _PodcastDetailPageState extends PageState<PodcastDetailPage> {
  //=

  final _appBarSize = 232.h;
  final _podcastBackgroundPhotoSize = 232.h;
  final _podcastForegroundPhotoSize = 160.h;

  @override
  void initState() {
    super.initState();
    podcastDetailModelOf(context).init();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Selector<PodcastDetailModel, Result<Podcast>?>(
            selector: (_, model) => model.podcastResult,
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
                            podcastDetailModelOf(context).fetchPodcast));
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
    return Column(children: [
      _buildAppBar(),
      _buildPodcastTitle(),
      if (placeholder != null) placeholder,
      if (placeholder == null) ...{
        _buildPodcastInfo(),
        SizedBox(height: ComponentInset.medium.h),
        _buildEpisodesHeader(),
      },
    ]);
  }

  Widget _buildAppBar() {
    return Container(
        height: _appBarSize,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(ComponentRadius.normal.h),
                bottomRight: Radius.circular(ComponentRadius.normal.h))),
        clipBehavior: Clip.antiAlias,
        child: Stack(children: [
          _buildPodcastBackgroundPhoto(),
          Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Row(children: [_buildBackButton()]),
            SizedBox(height: ComponentInset.small.h),
            _buildPodcastForegroundPhoto(),
          ]),
        ]));
  }

  Widget _buildPodcastBackgroundPhoto() {
    return Selector<PodcastDetailModel, String?>(
        selector: (_, model) => model.podcastPhotoPath,
        builder: (_, photoPath, __) {
          return Opacity(
              opacity: 0.6,
              child: BlurredCoverPhoto(
                photoPath: photoPath,
                photoKind: PhotoKind.podcast,
                height: _podcastBackgroundPhotoSize,
              ));
        });
  }

  Widget _buildPodcastForegroundPhoto() {
    return Selector<PodcastDetailModel, String?>(
        selector: (_, model) => model.podcastPhotoPath,
        builder: (_, photoPath, __) {
          return Photo.podcast(
            photoPath,
            options: PhotoOptions(
                width: _podcastForegroundPhotoSize,
                height: _podcastForegroundPhotoSize,
                borderRadius: BorderRadius.circular(ComponentRadius.normal.r)),
          );
        });
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

  Widget _buildPodcastTitle() {
    return Container(
        height: ComponentSize.large.h,
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
        alignment: Alignment.centerLeft,
        child: Selector<PodcastDetailModel, String?>(
            selector: (_, model) => model.podcastTitle,
            builder: (_, title, __) {
              return SimpleMarquee(
                  text: title ?? LocaleResources.of(context).podcast,
                  textStyle: TextStyles.boldHeading2.copyWith(
                    color: DynamicTheme.get(context).white(),
                  ));
            }));

    // final podcastId = podcastModelOf(context).podcast.id;
    // return Hero(tag: PodcastHeroTag.title(podcastId), child: widget);
  }

  Widget _buildPodcastInfo() {
    final padding = EdgeInsets.symmetric(horizontal: ComponentInset.normal.r);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: padding, child: _buildPodcastCategories()),
      SizedBox(height: ComponentInset.normal.h),
      _buildPodcastArtists(padding),
      SizedBox(height: ComponentInset.normal.h),
      Padding(padding: padding, child: _buildPodcastDescription()),
      SizedBox(height: ComponentInset.small.h),
      Padding(
          padding: padding,
          child: Row(children: [
            _buildLikePodcastButton(),
            const Spacer(),
            _buildSharePodcastButton()
          ])),
    ]);
  }

  Widget _buildPodcastCategories() {
    return Selector<PodcastDetailModel, List<PodcastCategory>?>(
        selector: (_, model) => model.podcastCategories,
        builder: (_, categories, __) {
          if (categories == null || categories.isEmpty) return Container();
          return Wrap(
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.start,
            runAlignment: WrapAlignment.spaceBetween,
            runSpacing: ComponentInset.small,
            spacing: ComponentInset.small,
            children: categories.map((category) {
              return PodcastCategoryChip(
                category: category,
                onTap: () => _onPodcastCategoryTapped(category),
              );
            }).toList(),
          );
        });
  }

  Widget _buildPodcastArtists(EdgeInsets padding) {
    return Selector<PodcastDetailModel, List<Artist>?>(
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
            onFollowTap: _onFollowPodcastArtistTapped,
          );
        });
  }

  Widget _buildPodcastDescription() {
    return Selector<PodcastDetailModel, String?>(
        selector: (_, model) => model.podcastDescription,
        builder: (_, description, __) {
          if (description == null || description.isEmpty) return Container();
          return PodcastDescription(text: description);
        });
  }

  Widget _buildLikePodcastButton() {
    return Selector<PodcastDetailModel, Tuple2<bool, int>>(
        selector: (_, model) =>
            Tuple2(model.isPodcastLiked, model.podcastLikeCount),
        builder: (_, tuple, __) {
          final isLiked = tuple.item1;
          final likeCount = tuple.item2;

          String text;
          if (isLiked) {
            text = LocaleResources.of(context).unlikeUppercase;
          } else {
            text = LocaleResources.of(context).likeUppercase;
          }
          text = "$text · ${likeCount.prettyCount}";

          return VerticalIconTextButton(
              color: DynamicTheme.get(context).white(),
              crossAxisAlignment: CrossAxisAlignment.start,
              height: ComponentSize.normal.h,
              iconPath:
                  isLiked ? Assets.iconHeartFilled : Assets.iconHeartOutline,
              text: text,
              onIconTap: _onLikePodcastTapped,
              onTextTap: _onShowPodcastLikesButtonTapped);
        });
  }

  Widget _buildSharePodcastButton() {
    return VerticalIconTextButton(
        color: DynamicTheme.get(context).white(),
        crossAxisAlignment: CrossAxisAlignment.end,
        height: ComponentSize.normal.h,
        iconPath: Assets.iconShare,
        text: LocaleResources.of(context).shareUppercase,
        onTap: _onSharePodcastTapped);
  }

  Widget _buildEpisodesHeader() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildEpisodesLabel(),
      SizedBox(height: ComponentInset.normal.h),
      _buildEpisodeSearchBar(),
      _buildSelectedFilterRow(),
      SizedBox(height: ComponentInset.normal.h),
    ]);
  }

  Widget _buildEpisodesLabel() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
        height: ComponentSize.smaller.h,
        child: Text(LocaleResources.of(context).episodes,
            style: TextStyles.boldHeading3
                .copyWith(color: DynamicTheme.get(context).white())));
  }

  Widget _buildEpisodeSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
      child: SearchBar(
          hintText: LocaleResources.of(context).podcastEpisodesSearchHint,
          onQueryChanged: podcastDetailModelOf(context).updateSearchQuery,
          onQueryCleared: podcastDetailModelOf(context).clearSearchQuery,
          suffixes: [_buildFilterIconWidget()]),
    );
  }

  Widget _buildFilterIconWidget() {
    return Selector<PodcastDetailModel, bool>(
        selector: (_, model) => model.isEpisodeFilterApplied,
        builder: (_, areFiltersApplied, __) {
          return FilterIconSuffix(
            isSelected: areFiltersApplied,
            onPressed: _onFilterButtonTapped,
          );
        });
  }

  Widget _buildSelectedFilterRow() {
    return Selector<PodcastDetailModel, PodcastEpisodeFilter>(
        selector: (_, model) => model.episodeFilter,
        builder: (_, episodeFilter, __) {
          if (episodeFilter.isDefault) {
            return Container();
          }

          return PodcastDetailEpisodesFilterLayout(
            margin: EdgeInsets.only(top: ComponentInset.normal.h),
            episodeFilter: episodeFilter,
            onResetDownloadedOnly:
                podcastDetailModelOf(context).resetDownloadedOnly,
            onResetUnplayedOnly:
                podcastDetailModelOf(context).resetUnplayedOnly,
            onResetSortOrder: podcastDetailModelOf(context).resetSortOrder,
          );
        });
  }

  /*
   * BODY
   */

  Widget _buildItemList() {
    return ItemListWidget<PodcastEpisode, PodcastDetailModel>(
        columnItemSpacing: ComponentInset.normal.h,
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
        headerSlivers: [SliverToBoxAdapter(child: _buildHeader())],
        footerSlivers: [
          _buildFeedSliverList(),
          DashboardConfigAwareFooter.asSliver(),
        ],
        itemBuilder: (context, episode, index) {
          return PodcastEpisodeDetailItem(
              episode: episode,
              onTap: () => _onPodcastEpisodeTapped(episode),
              onOptionsTap: () => _onPodcastEpisodeOptionsTapped(episode),
              onDownloadTap: () {},
              onShareTap: () => _onSharePodcastEpisodeTapped(episode));
        });
  }

  Widget _buildFeedSliverList() {
    return Selector<PodcastDetailModel, List<Feed>?>(
        selector: (_, model) => model.podcastFeeds,
        builder: (_, feeds, __) {
          if (feeds == null || feeds.isEmpty) return const SliverToBoxAdapter();
          return FeedSliverList(feeds: feeds);
        });
  }

  PodcastDetailModel podcastDetailModelOf(BuildContext context) {
    return context.read<PodcastDetailModel>();
  }

  void _onPodcastCategoryTapped(PodcastCategory category) {
    DashboardNavigation.pushNamed(
      context,
      Routes.podcasts,
      arguments: PodcastListArgs(selectedCategory: category),
    );
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

  void _onLikePodcastTapped() async {
    // Show loading dialog
    showBlockingProgressDialog(context);

    // Call API
    final result = await podcastDetailModelOf(context).toggleLikePodcast();

    // Close loading dialog
    if (!mounted) return;
    hideBlockingProgressDialog(context);

    if (!result.isSuccess()) {
      showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()));
      return;
    }
  }

  void _onShowPodcastLikesButtonTapped() {}

  void _onSharePodcastTapped() {
    final shareLink = podcastDetailModelOf(context).podcastShareableLink;
    if (shareLink == null) return;

    Share.share(shareLink);
  }

  void _onFilterButtonTapped() async {
    hideKeyboard(context);

    final updatedEpisodeFilter =
        await PodcastDetailEpisodesFilterBottomSheet.show(
      context,
      filter: podcastDetailModelOf(context).episodeFilter,
    );

    if (!mounted) return;
    if (updatedEpisodeFilter != null) {
      podcastDetailModelOf(context).setEpisodeFilter(updatedEpisodeFilter);
    }
  }

  void _onPodcastEpisodeTapped(PodcastEpisode episode) {
    final podcast = podcastDetailModelOf(context).detailedPodcast;
    if (podcast == null) return;

    final args = PodcastEpisodeDetailArgs.object(
      episode: episode,
      parentPagePodcastId: podcast.id,
    );
    DashboardNavigation.pushNamed(context, Routes.podcastEpisode,
        arguments: args);
  }

  void _onPodcastEpisodeOptionsTapped(PodcastEpisode episode) {
    final podcast = podcastDetailModelOf(context).detailedPodcast;
    if (podcast == null) {
      return;
    }

    final args = PodcastEpisodeOptionsArgs(episode: episode);
    PodcastEpisodeOptionsBottomSheet.show(context, args: args);
  }

  void _onSharePodcastEpisodeTapped(PodcastEpisode episode) {
    Share.share(episode.shareableLink);
  }
}
