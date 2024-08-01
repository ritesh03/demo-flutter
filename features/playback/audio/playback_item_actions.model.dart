import 'dart:async';

import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/api/audioplayer.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/events/events.dart';
import 'package:kwotmusic/features/playback/playback.dart';
import 'package:kwotmusic/features/podcastepisode/podcast_episode_actions.model.dart';
import 'package:kwotmusic/features/radiostation/radio_station_actions.model.dart';
import 'package:kwotmusic/features/skit/skit_actions.model.dart';
import 'package:kwotmusic/features/track/track_actions.model.dart';
import 'package:kwotmusic/l10n/localizations.dart';

class PlaybackItemActionsModel {
  //=

  /// TODO: Register when playback starts; Dispose when playback stops;
  StreamSubscription? _eventsSubscription;
  final _playbackKindsDisplayTextMap = <PlaybackKind, String>{};

  PlaybackItemActionsModel() {
    _eventsSubscription = _listenToEvents();
  }

  String getPlaybackKindDisplayText(BuildContext context, PlaybackKind kind) {
    if (_playbackKindsDisplayTextMap.isEmpty) {
      final localization = LocaleResources.of(context);
      for (final kind in PlaybackKind.values) {
        switch (kind) {
          case PlaybackKind.podcastEpisode:
            _playbackKindsDisplayTextMap[kind] = localization.podcastEpisode;
            break;
          case PlaybackKind.radioStation:
            _playbackKindsDisplayTextMap[kind] = localization.radioStation;
            break;
          case PlaybackKind.skit:
            _playbackKindsDisplayTextMap[kind] = localization.skit;
            break;
          case PlaybackKind.track:
            _playbackKindsDisplayTextMap[kind] = localization.song;
            break;
        }
      }
    }

    return _playbackKindsDisplayTextMap[kind]!;
  }

  /*
   * LIKE
   */

  Future<Result<PlaybackItem>> onLikeButtonTapped(
    PlaybackItem playbackItem,
  ) async {
    switch (playbackItem.kind) {
      case PlaybackKind.podcastEpisode:
        return _togglePodcastEpisodeLike(playbackItem: playbackItem);
      case PlaybackKind.radioStation:
        return _toggleRadioStationLike(playbackItem: playbackItem);
      case PlaybackKind.skit:
        return _toggleSkitLike(playbackItem: playbackItem);
      case PlaybackKind.track:
        return _toggleTrackLike(playbackItem: playbackItem);
    }
  }

  Future<Result<PlaybackItem>> _togglePodcastEpisodeLike({
    required PlaybackItem playbackItem,
  }) async {
    final episode = playbackItem.data as PodcastEpisode;

    final shouldLike = !episode.liked;
    final result = await locator<PodcastEpisodeActionsModel>().setIsLiked(
        podcastId: episode.podcastId,
        episodeId: episode.id,
        shouldLike: shouldLike);

    if (!result.isSuccess() || result.isEmpty()) {
      return result.replaceData(null);
    }

    final data = result.data();
    final updatedEpisode = PodcastEpisodeLikeUpdatedEvent(
      episodeId: data.id,
      liked: data.liked,
      likes: data.likes,
    ).update(episode);

    return result.replaceData(
      playbackItem.copyPodcastEpisode(updatedEpisode),
    );
  }

  Future<Result<PlaybackItem>> _toggleRadioStationLike({
    required PlaybackItem playbackItem,
  }) async {
    final radioStation = playbackItem.data as RadioStation;

    final result =
        await locator<RadioStationActionsModel>().toggleLike(radioStation);

    if (!result.isSuccess() || result.isEmpty()) {
      return result.replaceData(null);
    }

    final data = result.data();
    final updatedRadioStation = RadioStationLikeUpdatedEvent(
      id: data.id,
      liked: data.liked,
      likes: data.likes,
    ).update(radioStation);

    return result.replaceData(
      playbackItem.copyRadioStation(updatedRadioStation),
    );
  }

  Future<Result<PlaybackItem>> _toggleSkitLike({
    required PlaybackItem playbackItem,
  }) async {
    final skit = playbackItem.data as Skit;

    final result = await locator<SkitActionsModel>().toggleSkitLike(
      id: skit.id,
      liked: skit.liked,
    );

    if (!result.isSuccess() || result.isEmpty()) {
      return result.replaceData(null);
    }

    final data = result.data();
    final updatedSkit = SkitLikeUpdatedEvent(
      skitId: data.id,
      disliked: data.disliked,
      dislikes: data.dislikes,
      liked: data.liked,
      likes: data.likes,
    ).update(skit);

    return result.replaceData(
      playbackItem.copySkit(updatedSkit),
    );
  }

  Future<Result<PlaybackItem>> _toggleTrackLike({
    required PlaybackItem playbackItem,
  }) async {
    final track = playbackItem.data as Track;

    final result = await locator<TrackActionsModel>().toggleLike(track);

    if (!result.isSuccess() || result.isEmpty()) {
      return result.replaceData(null);
    }

    final data = result.data();
    final updatedTrack = TrackLikeUpdatedEvent(
      id: data.id,
      liked: data.liked,
      likes: data.likes,
    ).update(track);

    return result.replaceData(
      playbackItem.copyTrack(updatedTrack),
    );
  }

  /*
   * EVENT:
   *  PodcastEpisodeLikeUpdatedEvent
   *  RadioStationLikeUpdatedEvent
   *  SkitLikeUpdatedEvent
   *  TrackLikeUpdatedEvent
   */

  StreamSubscription _listenToEvents() {
    return eventBus.on().listen((event) {
      if (event is PodcastEpisodeLikeUpdatedEvent) {
        return _handlePodcastEpisodeLikeEvent(event);
      } else if (event is RadioStationLikeUpdatedEvent) {
        return _handleRadioStationLikeEvent(event);
      } else if (event is SkitLikeUpdatedEvent) {
        return _handleSkitLikeEvent(event);
      } else if (event is TrackLikeUpdatedEvent) {
        return _handleTrackLikeEvent(event);
      }
    });
  }

  void _handlePodcastEpisodeLikeEvent(PodcastEpisodeLikeUpdatedEvent event) {
    final playbackItem = audioPlayerManager.playbackItemNotifier.value;
    if (playbackItem == null || playbackItem.contentId != event.episodeId) {
      return;
    }

    final data = playbackItem.data;
    if (data is PodcastEpisode) {
      final updatedData = event.update(data);
      final updatedPlaybackItem = playbackItem.copyPodcastEpisode(updatedData);
      audioPlayerManager.updatePlaybackInfo(updatedPlaybackItem);
    }
  }

  void _handleRadioStationLikeEvent(RadioStationLikeUpdatedEvent event) {
    final playbackItem = audioPlayerManager.playbackItemNotifier.value;
    if (playbackItem == null || playbackItem.contentId != event.id) return;

    final data = playbackItem.data;
    if (data is RadioStation) {
      final updatedData = event.update(data);
      final updatedPlaybackItem = playbackItem.copyRadioStation(updatedData);
      audioPlayerManager.updatePlaybackInfo(updatedPlaybackItem);
    }
  }

  void _handleSkitLikeEvent(SkitLikeUpdatedEvent event) {
    final playbackItem = audioPlayerManager.playbackItemNotifier.value;
    if (playbackItem == null || playbackItem.contentId != event.skitId) return;

    final data = playbackItem.data;
    if (data is Skit) {
      final updatedData = event.update(data);
      final updatedPlaybackItem = playbackItem.copySkit(updatedData);
      audioPlayerManager.updatePlaybackInfo(updatedPlaybackItem);
    }
  }

  void _handleTrackLikeEvent(TrackLikeUpdatedEvent event) {
    final playbackItem = audioPlayerManager.playbackItemNotifier.value;
    if (playbackItem == null || playbackItem.contentId != event.id) return;

    final data = playbackItem.data;
    if (data is Track) {
      final updatedData = event.update(data);
      final updatedPlaybackItem = playbackItem.copyTrack(updatedData);
      audioPlayerManager.updatePlaybackInfo(updatedPlaybackItem);
    }
  }
}
