import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/api/audioplayer.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/features/playback/playback.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/util/tuple_value_notifier.dart';

class PlaybackRemainingDurationText extends StatelessWidget {
  const PlaybackRemainingDurationText({
    Key? key,
    this.scopeId,
    this.style,
    this.durationFormatter,
  }) : super(key: key);

  final String? scopeId;
  final TextStyle? style;
  final String Function(Duration remainingDuration)? durationFormatter;

  @override
  Widget build(BuildContext context) {
    return Tuple2ValueListenableBuilder<String?, PlayerSeekBarState>(
        valueListenable: audioPlayerManager.seekBarStateNotifier,
        builder: (_, tuple, __) {
          final identifier = tuple.item1;
          final state = tuple.item2;

          if (scopeId != null && scopeId != identifier) {
            return Container();
          }

          final String text;
          if (state.livestream || state.total == Duration.zero) {
            text = obtainFormattedDuration(
              context,
              state.current,
              remaining: false,
            );
          } else {
            final remaining = state.total - state.current;
            text = obtainFormattedDuration(
              context,
              remaining,
              remaining: true,
            );
          }

          return Text(text, style: style ?? TextStyles.heading6);
        });
  }

  String obtainFormattedDuration(
    BuildContext context,
    Duration? duration, {
    required bool remaining,
  }) {
    final localization = LocaleResources.of(context);

    final targetDuration = duration ?? Duration.zero;
    final formatter = durationFormatter;
    if (formatter != null) {
      return formatter.call(targetDuration);
    }

    final String text;
    final minuteCount = targetDuration.inMinutes;
    final secondCount = targetDuration.inSeconds;
    if (minuteCount >= 1) {
      text = localization.integerMinutesCompactFormat(minuteCount);
    } else {
      text = localization.playbackSecondsFormat(secondCount);
    }

    if (remaining && text.isNotEmpty) {
      return localization.timeLeftFormat(text);
    } else {
      return text;
    }
  }
}
