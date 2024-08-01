import 'package:flutter/material.dart'  hide SearchBar;

class VideoControlsState {
  final bool isLoading;
  final bool isPlaying;
  final bool isFinished;
  final bool isLivestream;
  final String? error;

  VideoControlsState({
    required this.isLoading,
    required this.isPlaying,
    required this.isFinished,
    required this.isLivestream,
    this.error,
  });

  VideoControlsState.error({
    required this.error,
  })  : isLoading = false,
        isPlaying = false,
        isFinished = false,
        isLivestream = false;

  bool get hasError => error != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoControlsState &&
          runtimeType == other.runtimeType &&
          isLoading == other.isLoading &&
          isPlaying == other.isPlaying &&
          isFinished == other.isFinished &&
          isLivestream == other.isLivestream &&
          error == other.error;

  @override
  int get hashCode => hashValues(
        isLoading,
        isPlaying,
        isFinished,
        isLivestream,
        error,
      );
}
