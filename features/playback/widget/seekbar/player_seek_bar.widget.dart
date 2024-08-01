import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/api/audioplayer.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/features/playback/playback.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/util/tuple_value_notifier.dart';

class PlayerSeekBar extends StatelessWidget {
  const PlayerSeekBar({
    Key? key,
    required this.notifier,
    required this.onSeek,
    this.dragEnabled = true,
    this.onDragging,
    this.thumbColor,
    this.thumbRadius,
    this.timeLabelFormat,
    this.timeLabelFormatForLivestream,
    this.timeLabelLocation = TimeLabelLocation.below,
    this.trackBaseColor,
    this.trackBufferedColor,
    this.trackCapShape = BarCapShape.round,
    this.trackHeight,
    this.trackProgressColor,
    this.trackProgressGradient,
    this.scopeId,
  }) : super(key: key);

  final PlayerSeekBarStateNotifier notifier;
  final Function(Duration duration) onSeek;

  final bool dragEnabled;
  final Function(Duration duration)? onDragging;
  final Color? thumbColor;
  final double? thumbRadius;
  final TimeLabelFormat? timeLabelFormat;
  final TimeLabelFormat? timeLabelFormatForLivestream;
  final TimeLabelLocation? timeLabelLocation;
  final Color? trackBaseColor;
  final Color? trackBufferedColor;
  final BarCapShape trackCapShape;
  final double? trackHeight;
  final Color? trackProgressColor;
  final LinearGradient? trackProgressGradient;
  final String? scopeId;

  @override
  Widget build(BuildContext context) {
    final localization = LocaleResources.of(context);

    /// TRACK HEIGHT
    final trackHeight = this.trackHeight ?? 4.r;

    /// TRACK COLOR (BASE)
    final trackBaseColor =
        this.trackBaseColor ?? DynamicTheme.get(context).black();

    /// TRACK COLOR (BUFFERED)
    final trackBufferedColor =
        this.trackBufferedColor ?? DynamicTheme.get(context).primary20();

    /// TRACK COLOR (PROGRESS)
    final trackProgressColor = this.trackProgressColor;

    /// TRACK GRADIENT (PROGRESS)
    final trackProgressGradient = this.trackProgressGradient ??
        LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: DynamicTheme.get(context).primaryGradient().colors);

    /// THUMB COLOR
    final thumbColor =
        this.thumbColor ?? DynamicTheme.get(context).primary120();

    /// THUMB SIZE
    final thumbRadius = this.thumbRadius ?? 8.r;

    return Tuple2ValueListenableBuilder<String?, PlayerSeekBarState>(
        valueListenable: notifier,
        builder: (_, tuple, __) {
          //=

          final identifier = tuple.item1;
          final state = tuple.item2;

          if (scopeId != null && scopeId != identifier) {
            return Container();
          }

          TimeLabelFormat? timeLabelFormat = this.timeLabelFormat;
          if (timeLabelFormat == null) {
            if (state.livestream) {
              timeLabelFormat = timeLabelFormatForLivestream ??
                  TimeLabelFormat(
                      leftTimeLabelType: LeftTimeLabelType.custom,
                      rightTimeLabelType: RightTimeLabelType.custom,
                      rightTimeLabelText: localization.liveStreamTotalDuration);
            } else {
              timeLabelFormat = TimeLabelFormat();
            }
          }

          return PlaybackProgressBar(
            barCapShape: trackCapShape,
            barHeight: trackHeight,
            baseBarColor: trackBaseColor,
            buffered: state.buffered,
            bufferedBarColor: trackBufferedColor,
            dragEnabled: dragEnabled && !state.livestream,
            onDragUpdate: (details) => onDragging?.call(details.timeStamp),
            onSeek: onSeek,
            progress: state.current,
            progressBarGradient: trackProgressGradient,
            thumbColor: thumbColor,
            thumbGlowRadius: 0,
            thumbRadius: state.livestream ? thumbRadius / 2 : thumbRadius,
            timeLabelFormat: timeLabelFormat,
            timeLabelLocation: timeLabelLocation ?? TimeLabelLocation.none,
            timeLabelTextStyle: TextStyles.heading6
                .copyWith(color: DynamicTheme.get(context).neutral10()),
            total: state.total,
          );
        });
  }
}
