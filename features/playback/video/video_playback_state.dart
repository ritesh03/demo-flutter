import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/features/playback/playback.dart';

import '../dependant_notifier.dart';

/// The duration, current position, buffering state, error state and settings
/// of a [VideoPlayerController].
class VideoPlaybackState {
  /// Constructs a video with the given values. Only [duration] is required. The
  /// rest will initialize with default values when unset.
  VideoPlaybackState({
    required this.duration,
    this.size,
    this.position = const Duration(),
    this.buffered = const Duration(),
    this.isLoading = false,
    this.isPlaying = false,
    this.isLooping = false,
    this.isBuffering = false,
    this.isFinished = false,
    this.isLivestream = false,
    this.videoPlaybackTrack,
    this.errorDescription,
  });

  /// Returns an instance with a `null` [Duration].
  VideoPlaybackState.uninitialized() : this(duration: null);

  /// Returns an instance with a `null` [Duration] and the given
  /// [errorDescription].
  VideoPlaybackState.erroneous(String errorDescription)
      : this(duration: null, errorDescription: errorDescription);

  /// The total duration of the video.
  final Duration? duration;

  /// The current playback position.
  final Duration position;

  /// The currently buffered ranges.
  final Duration buffered;

  /// True if initial buffering duration is not achieved.
  final bool isLoading;

  /// True if the video is playing. False if it's paused.
  final bool isPlaying;

  /// True if the video is looping.
  final bool isLooping;

  /// True if the video is currently buffering.
  final bool isBuffering;

  /// True if video has finished playing.
  final bool isFinished;

  /// True if video is a livestream.
  final bool isLivestream;

  /// Video Playback Track of playback media
  final VideoPlaybackTrack? videoPlaybackTrack;

  /// A description of the error if present.
  ///
  /// If [hasError] is false this is [null].
  final String? errorDescription;

  /// The [size] of the currently loaded video.
  ///
  /// Is null when [initialized] is false.
  final Size? size;

  /// Indicates whether or not the video has been loaded and is ready to play.
  bool get initialized => duration != null;

  /// Indicates whether or not the video is in an error state. If this is true
  /// [errorDescription] should have information about the problem.
  bool get hasError => errorDescription != null;

  /// Returns [size.width] / [size.height] when size is non-null, or `1.0.` when
  /// size is null or the aspect ratio would be less than or equal to 0.0.
  double get aspectRatio {
    if (size == null) {
      return 1.0;
    }
    final double aspectRatio = size!.width / size!.height;
    if (aspectRatio <= 0) {
      return 1.0;
    }
    return aspectRatio;
  }

  /// Returns a new instance that has the same values as this current instance,
  /// except for any overrides passed in as arguments to [copyWidth].
  VideoPlaybackState copyWith({
    Duration? duration,
    Size? size,
    Duration? position,
    Duration? buffered,
    bool? isLoading,
    bool? isPlaying,
    bool? isLooping,
    bool? isBuffering,
    bool? isFinished,
    bool? isLivestream,
    VideoPlaybackTrack? videoPlaybackTrack,
    String? errorDescription,
  }) {
    return VideoPlaybackState(
      duration: duration ?? this.duration,
      size: size ?? this.size,
      position: position ?? this.position,
      buffered: buffered ?? this.buffered,
      isLoading: isLoading ?? this.isLoading,
      isPlaying: isPlaying ?? this.isPlaying,
      isLooping: isLooping ?? this.isLooping,
      isBuffering: isBuffering ?? this.isBuffering,
      isFinished: isFinished ?? this.isFinished,
      isLivestream: isLivestream ?? this.isLivestream,
      videoPlaybackTrack: videoPlaybackTrack ?? this.videoPlaybackTrack,
      errorDescription: errorDescription ?? this.errorDescription,
    );
  }

  @override
  String toString() {
    return '$runtimeType('
        'duration: $duration, '
        'size: $size, '
        'position: $position, '
        'buffered: $buffered, '
        'isLoading: $isLoading, '
        'isPlaying: $isPlaying, '
        'isLooping: $isLooping, '
        'isBuffering: $isBuffering, '
        'isFinished: $isFinished, '
        'isLivestream: $isLivestream, '
        'videoPlaybackTrack: $videoPlaybackTrack, '
        'errorDescription: $errorDescription)';
  }
}

typedef VideoPlaybackStateNotifier = DependantValueNotifier<VideoPlaybackState>;
