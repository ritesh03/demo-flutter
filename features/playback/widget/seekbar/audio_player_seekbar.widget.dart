import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/features/playback/playback.dart';

class AudioPlayerSeekBar extends StatelessWidget {
  const AudioPlayerSeekBar({
    Key? key,
    this.compact = false,
    this.trackColor,
    this.scopeId,
    this.showTimeLabel,
  }) : super(key: key);

  final bool compact;
  final Color? trackColor;
  final String? scopeId;
  final bool? showTimeLabel;

  @override
  Widget build(BuildContext context) {
    return PlayerSeekBar(
      notifier: audioPlayerManager.seekBarStateNotifier,
      onSeek: audioPlayerManager.seek,
      dragEnabled: !compact,
      trackCapShape: compact ? BarCapShape.square : BarCapShape.round,
      trackBaseColor: trackColor,
      thumbRadius: compact ? 2.r : null,
      thumbColor: compact ? Colors.transparent : null,
      timeLabelLocation:
          (compact || showTimeLabel == false) ? null : TimeLabelLocation.below,
      scopeId: scopeId,
    );
  }
}
