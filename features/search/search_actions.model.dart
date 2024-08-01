import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/events/events.dart';
import 'package:kwotmusic/features/album/detail/album.args.dart';
import 'package:kwotmusic/features/album/options/album_options.bottomsheet.dart';
import 'package:kwotmusic/features/album/options/album_options.model.dart';
import 'package:kwotmusic/features/artist/options/artist_options.bottomsheet.dart';
import 'package:kwotmusic/features/artist/profile/artist.model.dart';
import 'package:kwotmusic/features/playback/audio/audio_playback_actions.model.dart';
import 'package:kwotmusic/features/playlist/detail/playlist.args.dart';
import 'package:kwotmusic/features/playlist/options/playlist_options.bottomsheet.dart';
import 'package:kwotmusic/features/playlist/options/playlist_options.model.dart';
import 'package:kwotmusic/features/podcast/detail/podcast_detail.model.dart';
import 'package:kwotmusic/features/podcastepisode/detail/podcast_episode_detail.model.dart';
import 'package:kwotmusic/features/podcastepisode/list/option/podcast_episode_options.bottomsheet.dart';
import 'package:kwotmusic/features/podcastepisode/list/option/podcast_episode_options.model.dart';
import 'package:kwotmusic/features/radiostation/option/radiostation_options.bottomsheet.dart';
import 'package:kwotmusic/features/skit/detail/skit_detail.bottomsheet.dart';
import 'package:kwotmusic/features/skit/detail/skit_detail.model.dart';
import 'package:kwotmusic/features/skit/options/skit_options.bottomsheet.dart';
import 'package:kwotmusic/features/skit/options/skit_options.model.dart';
import 'package:kwotmusic/features/track/options/track_options.bottomsheet.dart';
import 'package:kwotmusic/features/track/options/track_options.model.dart';
import 'package:kwotmusic/features/user/profile/options/user_options.bottomsheet.dart';
import 'package:kwotmusic/features/user/profile/user_profile.model.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:kwotmusic/util/util.dart';
import 'package:wrapped_infinite_scroll_pagination/infinite_scroll_pagination.dart';

class SearchActionsModel {
  //=

  /// LOGIC: Get displayable text for [SearchKind]
  String getSearchKindText(
    BuildContext context, {
    required SearchKind? kind,
    bool plural = false,
  }) {
    final localization = LocaleResources.of(context);
    switch (kind) {
      case null:
        return localization.all;
      case SearchKind.album:
        return plural ? localization.albums : localization.album;
      case SearchKind.artist:
        return plural ? localization.artists : localization.artist;
      case SearchKind.playlist:
        return plural ? localization.playlists : localization.playlist;
      case SearchKind.podcast:
        return plural ? localization.podcasts : localization.podcast;
      case SearchKind.podcastEpisode:
        return plural
            ? localization.podcastEpisodes
            : localization.podcastEpisode;
      case SearchKind.radioStation:
        return plural ? localization.radioStations : localization.radioStation;
      case SearchKind.show:
        return plural ? localization.shows : localization.show;
      case SearchKind.skit:
        return plural ? localization.skits : localization.skit;
      case SearchKind.track:
        return plural ? localization.songs : localization.song;
      case SearchKind.user:
        return plural ? localization.users : localization.user;
    }
  }

  /// LOGIC: Get search-place text for [SearchPlace]
  String getSearchPlaceText(BuildContext context, SearchPlace searchPlace) {
    final localization = LocaleResources.of(context);
    switch (searchPlace) {
      case SearchPlace.kwot:
        return localization.searchPlaceKwotMusic;
      case SearchPlace.library:
        return localization.searchPlaceLibrary;
    }
  }

  /// LOGIC: Get subtitle name for [SearchResultItem]
  String getSubtitleFromSearchResultItem(
    BuildContext context, {
    required SearchResultItem item,
  }) {
    final localization = LocaleResources.of(context);
    final kindText = getSearchKindText(context, kind: item.kind, plural: false);
    final String? creditText;
    switch (item.kind) {
      case SearchKind.album:
        creditText = (item.data as Album).subtitle;
        break;
      case SearchKind.artist:
        final artist = item.data as Artist;
        creditText = localization.followerCountFormat(
            artist.followerCount, artist.followerCount.prettyCount);
        break;
      case SearchKind.playlist:
        creditText = (item.data as Playlist).owner.name;
        break;
      case SearchKind.podcast:
        creditText = (item.data as Podcast).subtitle;
        break;
      case SearchKind.podcastEpisode:
        creditText = (item.data as PodcastEpisode).subtitle;
        break;
      case SearchKind.radioStation:
        creditText = null;
        break;
      case SearchKind.show:
        creditText = (item.data as Show).artist.name;
        break;
      case SearchKind.skit:
        creditText = (item.data as Skit).artist.name;
        break;
      case SearchKind.track:
        creditText = (item.data as Track).subtitle;
        break;
      case SearchKind.user:
        final user = item.data as User;
        creditText = localization.followerCountFormat(
            user.followerCount, user.followerCount.prettyCount);
        break;
    }

    return (creditText == null) ? kindText : "$kindText · $creditText";
  }

  /// LOGIC: handle tap on [SearchResultItem]
  Future? handleSearchResultItemTap(
    BuildContext context, {
    required SearchResultItem item,
  }) {
    switch (item.kind) {

      /// ALBUM
      case SearchKind.album:
        final album = item.data as Album;
        return Navigator.pushNamed(
          context,
          Routes.album,
          arguments: AlbumArgs(
            id: album.id,
            title: album.title,
            thumbnail: album.images.isEmpty ? null : album.images.first,
          ),
        );

      /// ARTIST
      case SearchKind.artist:
        return Navigator.pushNamed(context, Routes.artist,
            arguments: ArtistPageArgs.object(artist: item.data as Artist));

      /// PLAYLIST
      case SearchKind.playlist:
        final playlist = item.data as Playlist;
        return Navigator.pushNamed(
          context,
          Routes.playlist,
          arguments: PlaylistArgs(
            id: playlist.id,
            title: playlist.name,
            thumbnail: playlist.images.isEmpty ? null : playlist.images.first,
          ),
        );

      /// PODCAST
      case SearchKind.podcast:
        final podcast = item.data as Podcast;
        return Navigator.pushNamed(context, Routes.podcast,
            arguments: PodcastDetailArgs(
                id: podcast.id,
                title: podcast.title,
                thumbnail: podcast.thumbnail));

      /// PODCAST EPISODE
      case SearchKind.podcastEpisode:
        final episode = item.data as PodcastEpisode;
        return Navigator.pushNamed(
          context,
          Routes.podcastEpisode,
          arguments: PodcastEpisodeDetailArgs(
              podcastId: episode.podcastId,
              episodeId: episode.id,
              title: episode.title,
              thumbnail: episode.thumbnail),
        );

      /// RADIO STATION
      case SearchKind.radioStation:
        final radioStation = item.data as RadioStation;
        locator<AudioPlaybackActionsModel>().playRadioStation(radioStation);
        return null;

      /// SHOW
      case SearchKind.show:
        // final show = item.data as Show;
        // return ShowDetailBottomSheet.showBottomSheet(context,
        //     args: ShowDetailArgs(
        //         id: show.id, title: show.title, thumbnail: show.thumbnail));
        return null;

      /// SKIT
      case SearchKind.skit:
        final skit = item.data as Skit;
        return SkitDetailBottomSheet.showBottomSheet(context,
            args: SkitDetailArgs(
                id: skit.id, title: skit.title, thumbnail: skit.thumbnail));

      /// SONG
      case SearchKind.track:
        final track = item.data as Track;
        locator<AudioPlaybackActionsModel>().playTrack(track);
        return null;

      /// USER
      case SearchKind.user:
        final user = item.data as User;

        Navigator.pushNamed(context, Routes.userProfile,
            arguments: UserProfileArgs(
              id: user.id,
              name: user.name,
              thumbnail: user.thumbnail,
            ));
        return null;
    }
  }

  /// LOGIC: handle showing options of [SearchResultItem]
  void handleSearchResultItemOptionsTap(
    BuildContext context, {
    required SearchResultItem item,
  }) {
    switch (item.kind) {

      /// ALBUM
      case SearchKind.album:
        final album = item.data as Album;
        AlbumOptionsBottomSheet.show(context,
            args: AlbumOptionsArgs(album: album));
        break;

      /// ARTIST
      case SearchKind.artist:
        final artist = item.data as Artist;
        ArtistOptionsBottomSheet.show(context, artist: artist, onTapCancel: () {  });
        break;

      /// PLAYLIST
      case SearchKind.playlist:
        final playlist = item.data as Playlist;
        PlaylistOptionsBottomSheet.show(context,
            args: PlaylistOptionsArgs(playlist: playlist));
        break;

      /// PODCAST
      case SearchKind.podcast:
        return;

      /// PODCAST EPISODE
      case SearchKind.podcastEpisode:
        final episode = item.data as PodcastEpisode;
        PodcastEpisodeOptionsBottomSheet.show(context,
            args: PodcastEpisodeOptionsArgs(episode: episode));
        break;

      /// RADIO STATION
      case SearchKind.radioStation:
        final radioStation = item.data as RadioStation;
        RadioStationOptionsBottomSheet.show(context,
            radioStation: radioStation);
        break;

      /// SHOW
      case SearchKind.show:
        // final show = item.data as Show;
        // ShowOptionsBottomSheet.show(
        //   context,
        //   args: ShowOptionsArgs(show: show),
        // );
        // break;
        return;

      /// SKIT
      case SearchKind.skit:
        final skit = item.data as Skit;
        SkitOptionsBottomSheet.show(
          context,
          args: SkitOptionsArgs(skit: skit),
        );
        break;

      /// TRACK
      case SearchKind.track:
        final track = item.data as Track;
        TrackOptionsBottomSheet.show(
          context,
          args: TrackOptionsArgs(track: track),
        );
        break;

      /// USER
      case SearchKind.user:
        final user = item.data as User;
        UserOptionsBottomSheet.show(context, user: user);
        break;
    }
  }

  /*
   * API: Add Search Result Item to Recent Searches
   */

  async.CancelableOperation<Result>? _addSearchResultToRecentSearchOp;

  Future<Result> addSearchResultToRecentSearch({
    required SearchResultItem item,
  }) async {
    try {
      // Cancel current operation (if any)
      _addSearchResultToRecentSearchOp?.cancel();

      // Create Request
      final request = AddRecentSearchItemRequest(id: item.id, kind: item.kind);
      _addSearchResultToRecentSearchOp = async.CancelableOperation.fromFuture(
          locator<KwotData>().searchRepository.addRecentSearchItem(request));

      // Wait for result
      final result = await _addSearchResultToRecentSearchOp!.value;
      if (result.isSuccess()) {
        eventBus.fire(RecentSearchItemAddedEvent(item: item));
      }

      return result;
    } catch (error) {
      return Result.error("Error: $error");
    }
  }

  /*
   * API: Remove Recent Search Result Item
   */

  async.CancelableOperation<Result>? _removeRecentSearchResultItemOp;

  Future<Result> removeRecentSearchResultItem({
    required SearchResultItem item,
  }) async {
    try {
      // Cancel current operation (if any)
      _removeRecentSearchResultItemOp?.cancel();

      // Create Request
      final request = RemoveRecentSearchResultItemRequest(
        id: item.id,
        kind: item.kind,
      );
      _removeRecentSearchResultItemOp = async.CancelableOperation.fromFuture(
          locator<KwotData>().searchRepository.removeRecentSearchItem(request));

      // Wait for result
      final result = await _removeRecentSearchResultItemOp!.value;
      if (result.isSuccess()) {
        eventBus.fire(RecentSearchItemRemovedEvent(item: item));
      }

      return result;
    } catch (error) {
      return Result.error("Error: $error");
    }
  }

  /*
   * API: Clear Recent Searches
   */

  async.CancelableOperation<Result>? _clearRecentSearchesOp;

  Future<Result> clearRecentSearches() async {
    try {
      // Cancel current operation (if any)
      _clearRecentSearchesOp?.cancel();

      // Create Request
      _clearRecentSearchesOp = async.CancelableOperation.fromFuture(
          locator<KwotData>().searchRepository.clearRecentSearches());

      // Wait for result
      final result = await _clearRecentSearchesOp!.value;
      if (result.isSuccess()) {
        eventBus.fire(RecentSearchesClearedEvent());
      }

      return result;
    } catch (error) {
      return Result.error("Error: $error");
    }
  }
}

extension SearchResultItemExt on SearchResultItem {
  /// LOGIC: should show option-button for [SearchResultItem]
  bool get hasOptions {
    switch (kind) {
      case SearchKind.podcast:
        return false;

      case SearchKind.album:
      case SearchKind.artist:
      case SearchKind.playlist:
      case SearchKind.podcastEpisode:
      case SearchKind.radioStation:
      case SearchKind.show:
      case SearchKind.skit:
      case SearchKind.track:
      case SearchKind.user:
        return true;
    }
  }

  /// LOGIC: Get thumbnail name for [SearchResultItem]
  String? get thumbnail {
    switch (kind) {
      case SearchKind.album:
        final images = (data as Album).images;
        return images.isEmpty ? null : images.first;
      case SearchKind.artist:
        return (data as Artist).thumbnail;
      case SearchKind.playlist:
        final images = (data as Playlist).images;
        return images.isEmpty ? null : images.first;
      case SearchKind.podcast:
        return (data as Podcast).thumbnail;
      case SearchKind.podcastEpisode:
        return (data as PodcastEpisode).thumbnail;
      case SearchKind.radioStation:
        return (data as RadioStation).thumbnail;
      case SearchKind.show:
        return (data as Show).thumbnail;
      case SearchKind.skit:
        return (data as Skit).thumbnail;
      case SearchKind.track:
        final images = (data as Track).images;
        return images.isEmpty ? null : images.first;
      case SearchKind.user:
        return (data as User).thumbnail;
    }
  }

  /// LOGIC: Get title name for [SearchResultItem]
  String get title {
    switch (kind) {
      case SearchKind.album:
        return (data as Album).title;
      case SearchKind.artist:
        return (data as Artist).name;
      case SearchKind.playlist:
        return (data as Playlist).name;
      case SearchKind.podcast:
        return (data as Podcast).title;
      case SearchKind.podcastEpisode:
        return (data as PodcastEpisode).title;
      case SearchKind.radioStation:
        return (data as RadioStation).title;
      case SearchKind.show:
        return (data as Show).title;
      case SearchKind.skit:
        return (data as Skit).title;
      case SearchKind.track:
        return (data as Track).name;
      case SearchKind.user:
        return (data as User).name;
    }
  }
}

typedef SearchResultsController = PagingController<int, SearchResultItem>;
