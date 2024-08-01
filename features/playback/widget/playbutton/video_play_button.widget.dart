import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/features/playback/playback.dart';

class VideoPlayButton extends StatelessWidget {
  const VideoPlayButton({
    Key? key,
    this.compact = false,
    required this.size,
    this.iconSize,
    this.scopeId,
    this.hideOnScopeMismatch = false,
    this.hideIfNotPlaying = false,
    this.onScopedPlayTap,
  }) : super(key: key);

  final bool compact;
  final double size;
  final double? iconSize;
  final String? scopeId;
  final bool hideOnScopeMismatch;
  final bool hideIfNotPlaying;
  final VoidCallback? onScopedPlayTap;

  @override
  Widget build(BuildContext context) {
    return PlayButton(
      notifier: videoPlayerManager.playButtonStateNotifier,
      onPlayTap: videoPlayerManager.play,
      onPauseTap: videoPlayerManager.pause,
      compact: compact,
      size: size,
      iconSize: iconSize,
      scopeId: scopeId,
      hideOnScopeMismatch: hideOnScopeMismatch,
      hideIfNotPlaying: hideIfNotPlaying,
      onScopedPlayTap: onScopedPlayTap,
    );
  }
}