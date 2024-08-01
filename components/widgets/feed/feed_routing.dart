import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/api/audioplayer.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/activity/list/users_activities.args.dart';
import 'package:kwotmusic/features/album/detail/album.args.dart';
import 'package:kwotmusic/features/album/list/albums.args.dart';
import 'package:kwotmusic/features/artist/list/artists.model.dart';
import 'package:kwotmusic/features/artist/profile/artist.model.dart';
import 'package:kwotmusic/features/music/browsekind/list/music_browse_kinds.args.dart';
import 'package:kwotmusic/features/music/browsekindoptions/list/music_browse_kind_options.args.dart';
import 'package:kwotmusic/features/music/browser/music_browser.args.dart';
import 'package:kwotmusic/features/playback/audio/audio_playback_actions.model.dart';
import 'package:kwotmusic/features/playlist/detail/playlist.args.dart';
import 'package:kwotmusic/features/playlist/list/playlists.args.dart';
import 'package:kwotmusic/features/podcast/detail/podcast_detail.model.dart';
import 'package:kwotmusic/features/podcast/list/podcasts.model.dart';
import 'package:kwotmusic/features/podcastcategory/list/podcast_categories.model.dart';
import 'package:kwotmusic/features/podcastepisode/detail/podcast_episode_detail.model.dart';
import 'package:kwotmusic/features/podcastepisode/list/podcast_episodes.model.dart';
import 'package:kwotmusic/features/radiostation/list/radio_stations.model.dart';
import 'package:kwotmusic/features/show/countdown/live_show_countdown.model.dart';
import 'package:kwotmusic/features/show/detail/show_detail.bottomsheet.dart';
import 'package:kwotmusic/features/show/detail/show_detail.model.dart';
import 'package:kwotmusic/features/show/list/shows.model.dart';
import 'package:kwotmusic/features/show/options/purchase_show.bottomsheet.dart';
import 'package:kwotmusic/features/skit/detail/skit_detail.bottomsheet.dart';
import 'package:kwotmusic/features/skit/detail/skit_detail.model.dart';
import 'package:kwotmusic/features/skit/list/skits.model.dart';
import 'package:kwotmusic/features/track/list/tracks.args.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';

import '../../../features/artist/fanclubviews/activediscounts/active_discounts_view.dart';
import '../../../features/artist/fanclubviews/eventMeetGreetView/event_meet_view.dart';
import '../../../features/artist/fanclubviews/liveshowsview/live_show_view.dart';
import '../../../features/profile/subscriptions/subscription_enforcement.dart';

class FeedRouting {
  //=

  void handleItemTap(
    BuildContext context, {
    required Feed feed,
    required dynamic item,
  }) {
    print("This is the feed on tap ${feed.type}");
    switch (feed.type) {
      case FeedType.artist:
      case FeedType.musician:
        DashboardNavigation.pushNamed(
          context,
          Routes.artist,
          arguments: ArtistPageArgs.object(artist: item as Artist),
        );
        break;
      case FeedType.album:
        showAlbumDetailPage(context, album: item as Album);
        break;
      case FeedType.musicBrowseKind:
        final kind = item as MusicBrowseKind;
        DashboardNavigation.pushNamed(
          context,
          Routes.musicBrowser,
          arguments: MusicBrowserArgs(browseKindId: kind.id),
        );
        break;
      case FeedType.musicBrowseKindOption:
        final browseKindOption = item as MusicBrowseKindOption;
        final args = MusicBrowserArgs(
            browseKindId: browseKindOption.kindId,
            browseKindOptionId: browseKindOption.id);
        DashboardNavigation.pushNamed(context, Routes.musicBrowser,
            arguments: args);
        break;
      case FeedType.playlist:
        showPlaylistDetailPage(context, playlist: item as Playlist);
        break;
      case FeedType.podcast:
        final podcast = item as Podcast;
        final args = PodcastDetailArgs(
          id: podcast.id,
          title: podcast.title,
          thumbnail: podcast.thumbnail,
        );
        DashboardNavigation.pushNamed(context, Routes.podcast, arguments: args);
        break;
      case FeedType.podcastCategory:
        DashboardNavigation.pushNamed(
          context,
          Routes.podcasts,
          arguments: PodcastListArgs(selectedCategory: item as PodcastCategory),
        );
        break;
      case FeedType.podcastEpisode:
        DashboardNavigation.pushNamed(
          context,
          Routes.podcastEpisode,
          arguments:
              PodcastEpisodeDetailArgs.object(episode: item as PodcastEpisode),
        );
        break;
      case FeedType.radioStation:
        final fulfilled = SubscriptionEnforcement.fulfilSubscriptionRequirement(
          context,
          feature: "radio",
          text:
              LocaleResources.of(context).yourSubscriptionDoesNotAllowUserRadio,
        );
        if (!fulfilled) return;
        final radioStation = item as RadioStation;
        locator<AudioPlaybackActionsModel>().playRadioStation(radioStation);
        break;
      case FeedType.show:
        showShowDetailPage(context, show: item as Show);
        break;
      case FeedType.skit:
        final fulfilled = SubscriptionEnforcement.fulfilSubscriptionRequirement(
          context,
          feature: "video-songs",
          text:
              LocaleResources.of(context).yourSubscriptionDoesNotAllowPlayVideo,
        );
        if (!fulfilled) return;
        showSkitDetailPage(context, skit: item as Skit);
        break;
      case FeedType.track:
        final fulfilled = SubscriptionEnforcement.fulfilSubscriptionRequirement(
          context,
          feature: "listen-online",
          text: LocaleResources.of(context)
              .yourSubscriptionDoesNotAllowListenOline,
        );
        if (!fulfilled) return;
        final track = item as Track;
        locator<AudioPlaybackActionsModel>().playTrackUsingRequest(
          PlayTrackRequest.feed(feed.id, track: track),
        );
        break;
      case FeedType.userActivity:
        final activity = item as UserActivity;
        locator<AudioPlaybackActionsModel>().playTrack(activity.track);
        break;
    }
  }

  void handleSeeAllTap(
    BuildContext context, {
    required Feed feed,
  }) {
    switch (feed.type) {
      case FeedType.album:
        DashboardNavigation.pushNamed(
          context,
          Routes.albums,
          arguments: AlbumsListArgs(availableFeed: feed as Feed<Album>),
        );
        break;
      case FeedType.artist:
      case FeedType.musician:
        DashboardNavigation.pushNamed(
          context,
          Routes.artists,
          arguments: ArtistListArgs(
            availableFeed: feed as Feed<Artist>,
            enableGenreFilter: feed.type == FeedType.musician,
          ),
        );
        break;
      case FeedType.musicBrowseKind:
        DashboardNavigation.pushNamed(
          context,
          Routes.musicBrowseKinds,
          arguments: MusicBrowseKindsArgs(
              availableFeed: feed as Feed<MusicBrowseKind>),
        );
        break;
      case FeedType.musicBrowseKindOption:
        DashboardNavigation.pushNamed(
          context,
          Routes.musicBrowseKindOptions,
          arguments: MusicBrowseKindOptionsArgs(
              availableFeed: feed as Feed<MusicBrowseKindOption>),
        );
        break;
      case FeedType.playlist:
        DashboardNavigation.pushNamed(
          context,
          Routes.playlists,
          arguments: PlaylistsArgs.feed(feed as Feed<Playlist>),
        );
        break;
      case FeedType.podcast:
        DashboardNavigation.pushNamed(
          context,
          Routes.podcasts,
          arguments: PodcastListArgs(availableFeed: feed as Feed<Podcast>),
        );
        break;
      case FeedType.podcastCategory:
        DashboardNavigation.pushNamed(
          context,
          Routes.podcastCategories,
          arguments: PodcastCategoryListArgs(
              availableFeed: feed as Feed<PodcastCategory>),
        );
        break;
      case FeedType.podcastEpisode:
        DashboardNavigation.pushNamed(
          context,
          Routes.podcastEpisodes,
          arguments: PodcastEpisodeListArgs(
              availableFeed: feed as Feed<PodcastEpisode>),
        );
        break;
      case FeedType.radioStation:
        DashboardNavigation.pushNamed(
          context,
          Routes.radioStations,
          arguments:
              RadioStationListArgs(availableFeed: feed as Feed<RadioStation>),
        );
        break;
      case FeedType.show:
        DashboardNavigation.pushNamed(
          context,
          Routes.shows,
          arguments: ShowListArgs(availableFeed: feed as Feed<Show>),
        );
        break;
      case FeedType.skit:
        DashboardNavigation.pushNamed(
          context,
          Routes.skits,
          arguments: SkitListArgs(availableFeed: feed as Feed<Skit>),
        );
        break;
      case FeedType.track:
        DashboardNavigation.pushNamed(
          context,
          Routes.tracks,
          arguments: TrackListArgs(availableFeed: feed as Feed<Track>),
        );
        break;
      case FeedType.userActivity:
        DashboardNavigation.pushNamed(
          context,
          Routes.usersActivities,
          arguments:
              UsersActivitiesArgs(availableFeed: feed as Feed<UserActivity>),
        );
        break;
      case FeedType.upcomingEvents:
        DashboardNavigation.pushNamed(context, Routes.eventMeetView,
            arguments: EventMeetView(
              artistId: feed.id.replaceAll("artist_id:", ""),
            ));
        break;

      case FeedType.discount:
        DashboardNavigation.pushNamed(context, Routes.activeDiscountsView,
            arguments: ActiveDiscountsView(
              artistId: feed.id.replaceAll("artist_id:", ""),
            ));
        break;

      case FeedType.fanConnect:
        DashboardNavigation.pushNamed(context, Routes.liveShowView,
            arguments: LiveShowView(
              artistId: feed.id.replaceAll("artist_id:", ""),
            ));
        break;
    }
  }

  void showAlbumDetailPage(BuildContext context, {required Album album}) {
    final thumbnail = album.images.isEmpty ? null : album.images.first;
    final args =
        AlbumArgs(id: album.id, thumbnail: thumbnail, title: album.title);
    DashboardNavigation.pushNamed(context, Routes.album, arguments: args);
  }

  void showPlaylistDetailPage(
    BuildContext context, {
    required Playlist playlist,
  }) {
    final thumbnail = playlist.images.isEmpty ? null : playlist.images.first;
    final args = PlaylistArgs(
        id: playlist.id, thumbnail: thumbnail, title: playlist.name);
    DashboardNavigation.pushNamed(context, Routes.playlist, arguments: args);
  }

  void showShowDetailPage(BuildContext context, {required Show show}) {
    RootNavigation.popUntilRoot(context);
    if (show.isFreeOrPurchased) {
      if (show.hasNotStarted) {
        /*DashboardNavigation.pushNamed(
          context,
          Routes.liveShowCountdown,
          arguments: LiveShowCountdownArgs(show: show),
        );*/
      } else {
        ShowDetailBottomSheet.showBottomSheet(context,
            args: ShowDetailArgs(
              id: show.id,
              title: show.title,
              thumbnail: show.thumbnail,
            ));
      }
    } else {
      PurchaseShowBottomSheet.showBottomSheet(context, show: show);
    }
  }

  void showSkitDetailPage(BuildContext context, {required Skit skit}) {
    RootNavigation.popUntilRoot(context);
    SkitDetailBottomSheet.showBottomSheet(context,
        args: SkitDetailArgs(
          id: skit.id,
          title: skit.title,
          thumbnail: skit.thumbnail,
        ));
  }
}
