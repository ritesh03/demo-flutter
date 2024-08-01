import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/api/audioplayer.dart';
import 'package:kwotmusic/features/playback/audio/audio_playback_actions.model.dart';
import 'package:kwotmusic/features/playback/playback.dart';

/// TODO: TEST OUT OF CREATE/DESTROY CYCLE
class VideoPlaybackManager {
  final _quickSeekDuration = const Duration(seconds: 15);

  final videoItemNotifier = VideoItemNotifier();
  final playButtonStateNotifier = PlayerPlayStateNotifier();
  final controlsStateNotifier = ValueNotifier<VideoControlsState?>(null);
  final canSeekBackwardNotifier = ValueNotifier<bool?>(false);
  final canSeekForwardNotifier = ValueNotifier<bool?>(false);
  final seekBarStateNotifier = PlayerSeekBarStateNotifier();
  final playbackPositionNotifier = ValueNotifier<Duration?>(Duration.zero);
  final playbackDurationNotifier = ValueNotifier<Duration?>(Duration.zero);

  final isCaptionsOptionEnabledNotifier = ValueNotifier<bool>(false);
  final canChangeLoopVideoOptionNotifier = ValueNotifier<bool>(false);
  final isLoopVideoOptionEnabledNotifier = ValueNotifier<bool>(false);

  final selectedVideoTrackNotifier = VideoPlaybackTrackNotifier();
  final availableVideoTracksNotifier = VideoPlaybackTracksNotifier();

  final currentSubtitleNotifier = VideoPlaybackSubtitleNotifier();
  final availableSubtitleTracksNotifier = VideoPlaybackSubtitleTracksNotifier();

  VideoHandler? _videoHandler;

  VideoItem? get videoItem => videoItemNotifier.value;

  BetterPlayerController? get controller => _videoHandler?.controller;

  bool startPlayback({
    required VideoItem videoItem,
    bool forceLoad = false,
  }) {
    locator<AudioPlaybackActionsModel>().stopAudioPlayback();
    final loadedVideoItem = this.videoItem;
    if (!forceLoad &&
        loadedVideoItem != null &&
        loadedVideoItem.id == videoItem.id) {
      videoItemNotifier.value = videoItem;
      return false;
    }

    _videoHandler?.dispose();
    _videoHandler = VideoHandler(
      config: VideoHandlerConfig(
        videoItem: videoItem,
        isLivestream: videoItem.isLivestream,
      ),
    );
    videoItemNotifier.value = videoItem;

    _listenToVideoPlaybackState();
    _listenToSelectedVideoTrack();
    _listenToAvailableVideoTracks();
    _listenToCurrentSubtitle();
    _listenToAvailableSubtitleTracks();
    return true;
  }

  void stopPlayback() {
    videoItemNotifier.value = null;
    _videoHandler?.dispose();
    _videoHandler = null;
  }

  void dispose() {
    playButtonStateNotifier.dispose();
    controlsStateNotifier.dispose();
    canSeekBackwardNotifier.dispose();
    canSeekForwardNotifier.dispose();
    seekBarStateNotifier.dispose();
    playbackPositionNotifier.dispose();
    playbackDurationNotifier.dispose();
    selectedVideoTrackNotifier.dispose();
    availableVideoTracksNotifier.dispose();
    isCaptionsOptionEnabledNotifier.dispose();
    canChangeLoopVideoOptionNotifier.dispose();
    isLoopVideoOptionEnabledNotifier.dispose();
    currentSubtitleNotifier.dispose();
    availableSubtitleTracksNotifier.dispose();
  }

  void play() {
    _videoHandler?.play();
  }

  void pause() {
    _videoHandler?.pause();
  }

  void pauseUntil(Function() work) async {
    final state = controlsStateNotifier.value;
    final isPlaying = state?.isPlaying ?? false;
    if (isPlaying) {
      pause();
    }

    await work();

    final wasPlaying = isPlaying;
    if (wasPlaying) {
      play();
    }
  }

  void seek(Duration duration) {
    _videoHandler?.seekTo(duration);
  }

  void quickSeekBackward() {
    _videoHandler?.seekBackwardBy(_quickSeekDuration);
  }

  void quickSeekForward() {
    _videoHandler?.seekForwardBy(_quickSeekDuration);
  }

  void selectVideoTrack(VideoPlaybackTrack track) {
    _videoHandler?.selectVideoTrack(track);
  }

  void enableCaptions() {
    /// TODO: User cannot choose subtitle tracks from UI yet
    final availableSubtitleTracks = availableSubtitleTracksNotifier.value;
    if (availableSubtitleTracks.isEmpty) {
      isCaptionsOptionEnabledNotifier.value = false;
      return;
    }

    final firstSubtitleTrack = availableSubtitleTracks.first;
    _videoHandler?.selectSubtitleTrack(firstSubtitleTrack);
    isCaptionsOptionEnabledNotifier.value = true;
  }

  void disableCaptions() {
    _videoHandler?.selectSubtitleTrack(null);
    isCaptionsOptionEnabledNotifier.value = false;
  }

  void enableLooping() {
    controller?.setLooping(true);
    isLoopVideoOptionEnabledNotifier.value = true;
  }

  void disableLooping() {
    controller?.setLooping(false);
    isLoopVideoOptionEnabledNotifier.value = false;
  }

  void retryPlaying() {
    _videoHandler?.retryPlaying();
  }

  void replay() {
    _videoHandler?.replay();
  }

  Future<void> enterPresentationMode() {
    return _videoHandler?.enterPresentationMode() ??
        Future.delayed(Duration.zero);
  }

  Future<void> exitPresentationMode() {
    return _videoHandler?.exitPresentationMode() ??
        Future.delayed(Duration.zero);
  }

  void toggleFullScreen() {
    controller?.toggleFullScreen();
  }

  void _listenToVideoPlaybackState() {
    _videoHandler!.playbackStateNotifier.addValueListener((value) {
      final state = _videoHandler?.playbackStateNotifier.value;
      if (state == null) {
        return;
      }

      if (state.hasError) {
        controlsStateNotifier.value =
            VideoControlsState.error(error: state.errorDescription);
        return;
      }

      if (!state.initialized) {
        controlsStateNotifier.value = null;
        return;
      }

      playButtonStateNotifier.set(
        videoItem!.id,
        state.isPlaying ? PlayerPlayState.playing : PlayerPlayState.paused,
      );

      controlsStateNotifier.value = VideoControlsState(
        isLoading: state.isLoading,
        isPlaying: state.isPlaying,
        isFinished: state.isFinished,
        isLivestream: state.isLivestream,
        error: state.errorDescription,
      );

      canChangeLoopVideoOptionNotifier.value = !state.isLivestream;

      final currentPosition = state.position;
      final totalDuration = state.duration ?? Duration.zero;

      canSeekBackwardNotifier.value = state.isLivestream ? null : true;
      canSeekForwardNotifier.value = state.isLivestream ? null : true;

      seekBarStateNotifier.set(
        videoItem!.id,
        state.isLivestream
            ? PlayerSeekBarState.fixed(
                duration: currentPosition, livestream: state.isLivestream)
            : PlayerSeekBarState(
                buffered: state.buffered,
                current: currentPosition,
                total: totalDuration,
                livestream: state.isLivestream),
      );

      if (state.isLivestream) {
        playbackPositionNotifier.value = null;
        playbackDurationNotifier.value = null;
      } else {
        // Facilitates one update per seconds
        final recentlyNotifiedPosition = playbackPositionNotifier.value;
        if (recentlyNotifiedPosition != null &&
            (recentlyNotifiedPosition.inSeconds == currentPosition.inSeconds)) {
          playbackPositionNotifier.value = recentlyNotifiedPosition;
        } else {
          playbackPositionNotifier.value = currentPosition;
        }

        playbackDurationNotifier.value = state.duration;
      }
    });
  }

  void _listenToSelectedVideoTrack() {
    _videoHandler!.selectedVideoTrackNotifier.addValueListener((value) {
      selectedVideoTrackNotifier.value = value;
    });
  }

  void _listenToAvailableVideoTracks() {
    _videoHandler!.availableVideoTracksNotifier.addValueListener((tracks) {
      final trackHeightsMap = <int, VideoPlaybackTrack>{};
      for (final track in tracks) {
        final trackHeight = track.height;
        if (trackHeight == null) continue;
        if (trackHeightsMap.containsKey(trackHeight)) continue;

        trackHeightsMap[trackHeight] = track;
      }

      final uniqueTracks = trackHeightsMap.values.toList();
      uniqueTracks.sort((track1, track2) {
        final track1Height = track1.height!;
        final track2Height = track2.height!;
        if (track1Height == 0) return -1;
        if (track2Height == 0) return 1;
        return -(track1.height!.compareTo(track2.height!));
      });
      availableVideoTracksNotifier.value = uniqueTracks;
    });
  }

  void _listenToCurrentSubtitle() {
    _videoHandler!.videoPlaybackSubtitleNotifier.addValueListener((value) {
      currentSubtitleNotifier.value = value;
    });
  }

  void _listenToAvailableSubtitleTracks() {
    _videoHandler!.availableSubtitleTracksNotifier.addValueListener((tracks) {
      availableSubtitleTracksNotifier.value = tracks;
      if (tracks.isEmpty) {
        isCaptionsOptionEnabledNotifier.value = false;
      }
    });
  }
}
