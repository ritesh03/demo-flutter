import 'dart:math' as math;

import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter/services.dart';
import 'package:kwotmusic/app_config.dart';
import 'package:kwotmusic/features/playback/playback.dart';

class VideoHandler {
  late final BetterPlayerPlaylistController _playlistController;
  final _playlist = List<BetterPlayerDataSource>.empty(growable: true);

  late final VideoHandlerConfigNotifier configurationNotifier;
  late final VideoPlaybackStateNotifier playbackStateNotifier;
  late final VideoPlaybackTrackNotifier selectedVideoTrackNotifier;
  late final VideoPlaybackTracksNotifier availableVideoTracksNotifier;
  late final VideoPlaybackSubtitleNotifier videoPlaybackSubtitleNotifier;
  late final VideoPlaybackResolutionsNotifier playbackResolutionsNotifier;
  late final VideoPlaybackSubtitleTrackNotifier selectedSubtitleTrackNotifier;
  late final VideoPlaybackSubtitleTracksNotifier
      availableSubtitleTracksNotifier;

  BetterPlayerController? get controller =>
      _playlistController.betterPlayerController;

  VideoHandler({
    required VideoHandlerConfig config,
  }) {
    configurationNotifier = VideoHandlerConfigNotifier(config);
    playbackStateNotifier =
        VideoPlaybackStateNotifier(VideoPlaybackState.uninitialized());
    selectedVideoTrackNotifier = VideoPlaybackTrackNotifier();
    availableVideoTracksNotifier = VideoPlaybackTracksNotifier();

    playbackResolutionsNotifier =
        VideoPlaybackResolutionsNotifier(List.empty());

    videoPlaybackSubtitleNotifier = VideoPlaybackSubtitleNotifier();
    selectedSubtitleTrackNotifier = VideoPlaybackSubtitleTrackNotifier();
    availableSubtitleTracksNotifier = VideoPlaybackSubtitleTracksNotifier();

    final videoItem = config.videoItem;

    final playerConfiguration = BetterPlayerConfiguration(
      autoPlay: config.autoPlay,
      autoDispose: false,
      autoDetectFullscreenDeviceOrientation: false,
      controlsConfiguration: const BetterPlayerControlsConfiguration(
        showControlsOnInitialize: false,
        showControls: false,
      ),
      deviceOrientationsAfterFullScreen: AppConfig.allowedDeviceOrientations,
      deviceOrientationsOnFullScreen: DeviceOrientation.values,
      fit: BoxFit.contain,
    );

    const playlistConfiguration = BetterPlayerPlaylistConfiguration(
      nextVideoDelay: Duration(milliseconds: 0),
      loopVideos: false,
    );

    final dataSource = BetterPlayerDataSource(
        // TODO: TAG with MEDIA_ITEM
        BetterPlayerDataSourceType.network,
        videoItem.url,
        liveStream: videoItem.isLivestream,
        bufferingConfiguration: BetterPlayerBufferingConfiguration(
          minBufferMs: const Duration(seconds: 10).inMilliseconds,
          maxBufferMs: const Duration(seconds: 60).inMilliseconds,
        ));

    _playlist.clear();
    _playlist.add(dataSource);

    _playlistController = BetterPlayerPlaylistController(_playlist,
        betterPlayerConfiguration: playerConfiguration,
        betterPlayerPlaylistConfiguration: playlistConfiguration);

    final videoPlayerController = controller?.videoPlayerController;
    videoPlayerController?.addListener(_listenToVideoPlayerValue);

    controller?.asmsTracksNotifier.addListener(_listenToVideoTracksNotifier);
    controller?.resolutionsNotifier.addListener(_listenToResolutionsNotifier);
    controller?.subtitleTracksNotifier.addListener(_listenToSubtitleTracksNotifier);
  }

  Future<void> play() async {
    // TODO: restart from current-position if livestream (ignore buffering)
    controller?.play();
  }

  Future<void> pause() async {
    controller?.pause();
  }

  // TODO https://github.com/jhomlala/betterplayer/issues/308
  // TODO https://github.com/jhomlala/betterplayer/issues/654
  Future<void> selectVideoTrack(VideoPlaybackTrack track) async {
    final asmsTracks = controller?.betterPlayerAsmsTracks ?? [];
    for (final asmsTrack in asmsTracks) {
      if (asmsTrack.height == track.height &&
          asmsTrack.bitrate == track.bitrate) {
        controller?.setTrack(asmsTrack);
        selectedVideoTrackNotifier.value = track;
        break;
      }
    }
  }

  Future<void> selectSubtitleTrack(VideoPlaybackSubtitleTrack? track) async {
    if (track == null) {
      final subtitleTrack = BetterPlayerSubtitlesSource.none();
      controller?.setupSubtitleSource(subtitleTrack);
      selectedSubtitleTrackNotifier.value = null;
      return;
    }

    final subtitleTracks = controller?.betterPlayerSubtitlesSourceList ?? [];
    for (final subtitleTrack in subtitleTracks) {
      if (subtitleTrack.identifier == track.identifier) {
        controller?.setupSubtitleSource(subtitleTrack);
        selectedSubtitleTrackNotifier.value = track;
        break;
      }
    }
  }

  Future<void> seekTo(Duration duration) async {
    final state = playbackStateNotifier.value;
    if (state.isLivestream) {
      return;
    }
    controller?.seekTo(duration);
  }

  Future<void> seekBackwardBy(Duration seekDuration) async {
    final state = playbackStateNotifier.value;
    if (state.isLivestream) {
      return;
    }

    final currentPositionSeconds = state.position.inSeconds;
    final newPositionSeconds = currentPositionSeconds - seekDuration.inSeconds;

    final newPosition = Duration(seconds: math.max(0, newPositionSeconds));
    seekTo(newPosition);
  }

  Future<void> seekForwardBy(Duration seekDuration) async {
    final state = playbackStateNotifier.value;
    if (state.isLivestream) {
      return;
    }

    final currentPositionSeconds = state.position.inSeconds;
    final totalDurationSeconds = (state.duration ?? Duration.zero).inSeconds;
    if (totalDurationSeconds == 0 ||
        currentPositionSeconds >= totalDurationSeconds) {
      return;
    }

    final newPositionSeconds = currentPositionSeconds + seekDuration.inSeconds;
    final newPosition =
        Duration(seconds: math.min(newPositionSeconds, totalDurationSeconds));
    seekTo(newPosition);
  }

  void retryPlaying() {
    controller?.retryDataSource();
  }

  void replay() {
    controller?.seekTo(Duration.zero);
    controller?.play();
  }

  Future<void> enterPresentationMode() {
    return controller?.enterPresentationMode() ?? Future.delayed(Duration.zero);
  }

  Future<void> exitPresentationMode() {
    return controller?.exitPresentationMode() ?? Future.delayed(Duration.zero);
  }

  void _listenToVideoPlayerValue() {
    final value = controller!.videoPlayerController!.value;

    final Duration buffered;
    final bufferedRanges = value.buffered;
    if (bufferedRanges.isNotEmpty) {
      buffered = bufferedRanges.first.end;
    } else {
      buffered = Duration.zero;
    }

    final config = configurationNotifier.value;

    final currentState = playbackStateNotifier.value;
    playbackStateNotifier.value = currentState.copyWith(
      duration: value.duration,
      size: value.size,
      position: value.position,
      buffered: buffered,
      isLoading: value.isLoading(),
      isPlaying: value.isPlaying,
      isLooping: value.isLooping,
      isBuffering: value.isBuffering,
      isFinished: value.isFinished(),
      isLivestream: config.isLivestream,
      videoPlaybackTrack: selectedVideoTrackNotifier.value,
      errorDescription: value.errorDescription,
    );

    final selectedSubtitleTrack = selectedSubtitleTrackNotifier.value;
    final subtitleLines = controller?.subtitlesLines ?? [];
    if (selectedSubtitleTrack == null || subtitleLines.isEmpty) {
      videoPlaybackSubtitleNotifier.value = null;
    } else {
      final currentPosition = value.position;
      bool isSubtitleNotified = false;
      for (final subtitle in subtitleLines) {
        final subtitleStartPosition = subtitle.start;
        final subtitleEndPosition = subtitle.end;
        if (subtitleStartPosition == null || subtitleEndPosition == null) {
          continue;
        }
        if (subtitleStartPosition <= currentPosition &&
            subtitleEndPosition >= currentPosition) {
          videoPlaybackSubtitleNotifier.value = VideoPlaybackSubtitle(
              start: subtitleStartPosition,
              end: subtitleEndPosition,
              texts: subtitle.texts ?? []);
          isSubtitleNotified = true;
        }
      }

      if (!isSubtitleNotified) {
        videoPlaybackSubtitleNotifier.value = null;
      }
    }
  }

  void _listenToVideoTracksNotifier() {
    final asmsTracks = controller?.asmsTracksNotifier.value ?? [];
    final tracks = asmsTracks.map((asmsTrack) {
      return VideoPlaybackTrack(
          id: asmsTrack.id,
          width: asmsTrack.width,
          height: asmsTrack.height,
          bitrate: asmsTrack.bitrate);
    }).toList();
    tracks.sort((track1, track2) {
      final height1 = track1.height;
      final height2 = track2.height;
      if (height1 == null || height2 == null) {
        return 0;
      }

      return height1.compareTo(height2);
    });
    availableVideoTracksNotifier.value = tracks;
  }

  void _listenToResolutionsNotifier() {
    final resolutionsMap = controller?.resolutionsNotifier.value ?? {};
    playbackResolutionsNotifier.value = resolutionsMap.entries.map((entry) {
      return VideoPlaybackResolution(name: entry.key, url: entry.value);
    }).toList();
  }

  void _listenToSubtitleTracksNotifier() {
    final subtitleTracks = controller?.subtitleTracksNotifier.value ?? [];
    availableSubtitleTracksNotifier.value = subtitleTracks
        .where((subtitleTrack) => !subtitleTrack.isTypeNone)
        .map((subtitleTrack) {
      return VideoPlaybackSubtitleTrack(
        identifier: subtitleTrack.identifier,
        name: subtitleTrack.name,
      );
    }).toList();
  }

  void dispose() {
    final videoPlayerController = controller?.videoPlayerController;
    videoPlayerController?.removeListener(_listenToVideoPlayerValue);

    controller?.asmsTracksNotifier.removeListener(_listenToVideoTracksNotifier);
    controller?.resolutionsNotifier
        .removeListener(_listenToResolutionsNotifier);
    controller?.subtitleTracksNotifier
        .removeListener(_listenToSubtitleTracksNotifier);

    configurationNotifier.dispose();
    playbackStateNotifier.dispose();
    availableVideoTracksNotifier.dispose();
    playbackResolutionsNotifier.dispose();
    videoPlaybackSubtitleNotifier.dispose();
    selectedSubtitleTrackNotifier.dispose();
    availableSubtitleTracksNotifier.dispose();

    controller?.dispose(forceDispose: true);
  }
}

extension VideoPlayerValueExtension on VideoPlayerValue {
  bool isLoading() {
    final value = this;
    if (!value.isPlaying && value.duration == null) {
      return true;
    }

    final position = value.position;

    final bufferedEndPosition =
        value.buffered.isNotEmpty ? value.buffered.last.end : null;
    if (bufferedEndPosition == null) {
      return false;
    }

    final difference = bufferedEndPosition - position;
    if (value.isPlaying &&
        value.isBuffering &&
        difference.inMilliseconds < 20000) {
      return true;
    }

    return false;
  }

  bool isFinished() {
    final value = this;
    final duration = value.duration;
    final position = value.position;

    if (duration == null) return false;
    if (duration.inMilliseconds == 0) return false;
    if (position.inMilliseconds == 0) return false;
    return position >= duration;
  }
}
