import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/indicator/indicators.dart';
import 'package:kwotmusic/components/widgets/multi_value_listenable_builder.widget.dart';
import 'package:kwotmusic/features/playback/playback.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/util/util.dart';
import 'package:provider/provider.dart';

class VideoPlaybackControls extends StatelessWidget {
  const VideoPlaybackControls({
    Key? key,
    required this.onOptionsButtonTap,
    required this.onExpandButtonTap,
    required this.progressBarHeight,
  }) : super(key: key);

  final VoidCallback onOptionsButtonTap;
  final VoidCallback onExpandButtonTap;
  final double progressBarHeight;

  Color get controlsBackgroundColor =>
      DynamicTheme.displayBlack.withOpacity(0.5);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<VideoControlsState?>(
        valueListenable: videoPlayerManager.controlsStateNotifier,
        builder: (_, state, __) {
          if (state == null) {
            return _buildPlaybackLoadingWidget();
          }

          if (state.hasError) {
            return _buildPlaybackErrorWidget(context, error: state.error!);
          }

          if (state.isLoading) {
            return _buildPlaybackLoadingWidget();
          }

          if (state.isFinished && !state.isPlaying) {
            return _buildPlaybackFinishedWidget(
              context,
              canReplay: !state.isLivestream,
            );
          }

          return Stack(children: [
            const Positioned.fill(child: VideoPlaybackSubtitlesWidget()),
            Positioned(
                left: 0,
                top: 0,
                right: 0,
                bottom: progressBarHeight / 2,
                child: _buildControlsVisibilityHandler(context)),
            Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildProgressBar(context)),
          ]);
        });
  }

  Widget _buildPlaybackLoadingWidget() {
    return Container(
      color: controlsBackgroundColor,
      margin: EdgeInsets.only(bottom: progressBarHeight / 2),
      child: const LoadingIndicator(),
    );
  }

  Widget _buildPlaybackErrorWidget(
    BuildContext context, {
    required String error,
  }) {
    return Container(
        color: controlsBackgroundColor,
        margin: EdgeInsets.only(bottom: progressBarHeight / 2),
        child: VideoPlaybackError(
          error: error,
          onRetry: videoPlayerManager.retryPlaying,
        ));
  }

  Widget _buildPlaybackFinishedWidget(
    BuildContext context, {
    bool canReplay = false,
  }) {
    return Container(
      color: controlsBackgroundColor,
      margin: EdgeInsets.only(bottom: progressBarHeight / 2),
      child: VideoPlaybackCompleted(
          message: LocaleResources.of(context).errorBroadcastPlaybackHasEnded,
          onReplayTap: canReplay ? videoPlayerManager.replay : null),
    );
  }

  Widget _buildControlsVisibilityHandler(BuildContext context) {
    return GestureDetector(
        onTap: () => controlsVisibilityModelOf(context).onDisplayTap(),
        onDoubleTap: () => controlsVisibilityModelOf(context).restartTimer(),
        child: Selector<VideoControlsVisibilityModel, bool>(
            selector: (_, model) => model.areControlsVisible,
            builder: (_, visible, __) {
              return AbsorbPointer(
                  absorbing: !visible,
                  child: AnimatedOpacity(
                    opacity: visible ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    child: _buildControls(context),
                  ));
            }));
  }

  Widget _buildControls(BuildContext context) {
    return Container(
        color: controlsBackgroundColor,
        child: Stack(children: [
          Positioned(
              top: 0,
              right: 0,
              child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildCaptionsButton(context),
                    _buildOptionsButton(context),
                  ])),
          Center(
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              _buildSeekBackwardButton(context),
              SizedBox(width: ComponentInset.medium.w),
              _buildPlayButton(context),
              SizedBox(width: ComponentInset.medium.w),
              _buildSeekForwardButton(context),
            ]),
          ),
          Positioned(
              left: 0, right: 0, bottom: 0, child: _buildDurationBar(context)),
          Positioned(right: 0, bottom: 0, child: _buildExpandButton(context)),
        ]));
  }

  Widget _buildCaptionsButton(BuildContext context) {
    return TwoValuesListenableBuilder<bool, List<VideoPlaybackSubtitleTrack>>(
        valueListenable1: videoPlayerManager.isCaptionsOptionEnabledNotifier,
        valueListenable2: videoPlayerManager.availableSubtitleTracksNotifier,
        builder: (_, captionsEnabled, tracks, __) {
          if (tracks.isEmpty) return Container();
          return AppIconButton(
              width: ComponentSize.large.r,
              height: ComponentSize.large.r,
              assetColor: DynamicTheme.get(context).white(),
              assetPath: captionsEnabled
                  ? Assets.iconCaptionsOn
                  : Assets.iconCaptionsOff,
              padding: EdgeInsets.all(ComponentInset.small.r),
              onPressed: () => _onCaptionsButtonTap(context, captionsEnabled));
        });
  }

  Widget _buildOptionsButton(BuildContext context) {
    return AppIconButton(
        width: ComponentSize.large.r,
        height: ComponentSize.large.r,
        assetColor: DynamicTheme.get(context).white(),
        assetPath: Assets.iconOptions,
        padding: EdgeInsets.all(ComponentInset.small.r),
        onPressed: () {
          controlsVisibilityModelOf(context).restartTimer();
          onOptionsButtonTap();
        });
  }

  Widget _buildSeekBackwardButton(BuildContext context) {
    return PlaybackSeekBackwardButton(
        notifier: videoPlayerManager.canSeekBackwardNotifier,
        onTap: () {
          controlsVisibilityModelOf(context).restartTimer();
          videoPlayerManager.quickSeekBackward();
        });
  }

  Widget _buildPlayButton(BuildContext context) {
    return PlayButton(
        notifier: videoPlayerManager.playButtonStateNotifier,
        onPlayTap: videoPlayerManager.play,
        onPauseTap: videoPlayerManager.pause,
        size: 56.r,
        compact: true);
  }

  Widget _buildSeekForwardButton(BuildContext context) {
    return PlaybackSeekForwardButton(
        notifier: videoPlayerManager.canSeekForwardNotifier,
        onTap: () {
          controlsVisibilityModelOf(context).restartTimer();
          videoPlayerManager.quickSeekForward();
        });
  }

  Widget _buildDurationBar(BuildContext context) {
    final textStyle =
        TextStyles.heading6.copyWith(color: DynamicTheme.get(context).white());

    return Container(
        padding: EdgeInsets.all(ComponentInset.small.r),
        child: Row(children: [
          /// CURRENT POSITION
          ValueListenableBuilder<Duration?>(
              valueListenable: videoPlayerManager.playbackPositionNotifier,
              builder: (_, position, __) {
                /// Null position indicates that playback is a livestream.
                if (position == null) {
                  return Text(LocaleResources.of(context).liveStreamIndicator,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textStyle);
                }

                final positionText = position.toHoursMinutesSeconds() ?? "";
                return Text(positionText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textStyle);
              }),
          const Spacer(),

          /// TOTAL DURATION
          ValueListenableBuilder<Duration?>(
              valueListenable: videoPlayerManager.playbackDurationNotifier,
              builder: (_, duration, __) {
                if (duration == null) return Container();

                final durationText = duration.toHoursMinutesSeconds() ?? "";
                return Text(durationText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textStyle);
              }),
        ]));
  }

  Widget _buildExpandButton(BuildContext context) {
    return AppIconButton(
        width: ComponentSize.small.r,
        height: ComponentSize.small.r,
        assetColor: DynamicTheme.get(context).white(),
        margin: EdgeInsets.symmetric(
          horizontal: ComponentInset.small.r,
          vertical: ComponentInset.medium.r,
        ),
        assetPath: Assets.iconExpand,
        onPressed: () {
          controlsVisibilityModelOf(context).restartTimer();
          onExpandButtonTap();
        });
  }

  Widget _buildProgressBar(BuildContext context) {
    return Selector<VideoControlsVisibilityModel, bool>(
        selector: (_, model) => model.areControlsVisible,
        builder: (_, visible, __) {
          final thumbRadius = visible ? (progressBarHeight / 2) : 1.r;
          final trackHeight = visible ? 4.r : 2.r;
          return Container(
              height: progressBarHeight,
              alignment: Alignment.center,
              child: PlayerSeekBar(
                notifier: videoPlayerManager.seekBarStateNotifier,
                onSeek: videoPlayerManager.seek,
                dragEnabled: visible,
                onDragging: (duration) =>
                    controlsVisibilityModelOf(context).restartTimer(),
                trackCapShape: BarCapShape.square,
                thumbRadius: thumbRadius,
                timeLabelLocation: null,
                trackHeight: trackHeight,
              ));
        });
  }

  VideoControlsVisibilityModel controlsVisibilityModelOf(BuildContext context) {
    return context.read<VideoControlsVisibilityModel>();
  }

  void _onCaptionsButtonTap(BuildContext context, bool captionsEnabled) {
    controlsVisibilityModelOf(context).restartTimer();
    captionsEnabled
        ? videoPlayerManager.disableCaptions()
        : videoPlayerManager.enableCaptions();
  }
}
