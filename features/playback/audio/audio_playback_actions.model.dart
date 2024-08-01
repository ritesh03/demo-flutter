import 'dart:async';

import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/api/audioplayer.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/events/events.dart';
import 'package:kwotmusic/features/playback/playback.dart';

class AudioPlaybackActionsModel {
  //=

  Future<Result> addAlbumToQueue(Album album) {
    _stopVideoPlayback();
    return locator<KwotData>()
        .playQueueRepository
        .playAlbum(request: PlayAlbumRequest.inQueue(albumId: album.id));
  }

  Future<Result> addPlaylistToQueue(Playlist playlist) {
    _stopVideoPlayback();
    return locator<KwotData>().playQueueRepository.playPlaylist(
        request: PlayPlaylistRequest.inQueue(playlistId: playlist.id));
  }

  Future<Result> addPodcastEpisodeToQueue(PodcastEpisode episode) {
    _stopVideoPlayback();
    return locator<KwotData>().playQueueRepository.playPodcastEpisode(
        request: PlayPodcastEpisodeRequest.inQueue(episode: episode));
  }

  Future<Result> addSkitToQueue(Skit skit) {
    _stopVideoPlayback();
    return locator<KwotData>()
        .playQueueRepository
        .playSkit(request: PlaySkitRequest.inQueue(skit: skit));
  }

  Future<Result> addTrackToQueue(Track track) {
    _stopVideoPlayback();
    return locator<KwotData>()
        .playQueueRepository
        .playTrack(request: PlayTrackRequest.inQueue(track: track));
  }

  Future<Result> playAlbum(String albumId) {
    _stopVideoPlayback();
    return locator<KwotData>()
        .playQueueRepository
        .playAlbum(request: PlayAlbumRequest(albumId: albumId));
  }

  Future<Result> playDownloads({
    Track? track,
  }) {
    _stopVideoPlayback();
    return locator<KwotData>()
        .playQueueRepository
        .playDownloads(request: PlayDownloadsRequest(track: track));
  }

  Future<Result> playPlaylist(String playlistId) {
    _stopVideoPlayback();
    return locator<KwotData>()
        .playQueueRepository
        .playPlaylist(request: PlayPlaylistRequest(playlistId: playlistId));
  }

  Future<Result> playPodcastEpisode(PodcastEpisode episode) {
    _stopVideoPlayback();
    return locator<KwotData>().playQueueRepository.playPodcastEpisode(
        request: PlayPodcastEpisodeRequest(episode: episode));
  }

  Future<Result> playRadioStation(RadioStation radioStation) {
    _stopVideoPlayback();
    return locator<KwotData>().playQueueRepository.playRadioStation(
        request: PlayRadioStationRequest(radioStation: radioStation));
  }

  Future<Result> playTrack(Track track) {
    // _stopVideoPlayback(); // handled in playTrackUsingRequest(...)
    stopAudioPlayback();
    return playTrackUsingRequest(PlayTrackRequest(track: track));
  }

  Future<Result> playTrackUsingRequest(PlayTrackRequest request) {
    _stopVideoPlayback();
    return locator<KwotData>().playQueueRepository.playTrack(request: request);
  }

  Future<Result> removePlaybackItem(PlaybackItem playbackItem) async {
    final request = RemovePlayingQueueItemRequest(playbackItem: playbackItem);
    final result = await locator<KwotData>()
        .playQueueRepository
        .removeItem(request: request);

    if (result.isSuccess()) {
      eventBus.fire(PlayingQueueItemRemovedEvent(item: playbackItem));
    }

    return result;
  }

  Future<Result> shuffle() {
    final queueRepository = locator<KwotData>().playQueueRepository;
    final shouldEnableShuffle = !queueRepository.shuffledStream.value;
    final request = ShuffleQueueRequest(enable: shouldEnableShuffle);
    return queueRepository.shuffle(request: request);
  }

  void stopAudioPlayback({bool onlyIfPlaying = false}) {
    try {
      locator<KwotData>().playQueueRepository.clear();
      if (onlyIfPlaying) {
        if (audioPlayerManager.isPlaying) {
          audioPlayerManager.stop();
        }
      } else {
        audioPlayerManager.stop();
      }
    } catch (exception) {
      locator<AnalyticsLogger>()
          .log("Failed to stop audio playback: $exception");
    }
  }

  void _stopVideoPlayback() {
    try {
      videoPlayerManager.stopPlayback();
    } catch (exception) {
      locator<AnalyticsLogger>()
          .log("Failed to stop video playback: $exception");
    }
  }

  void stopPlayback() {
    stopAudioPlayback();
    _stopVideoPlayback();
  }
}
