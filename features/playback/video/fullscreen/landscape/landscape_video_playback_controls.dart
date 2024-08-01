import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/blocking_progress.dialog.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/indicator/indicators.dart';
import 'package:kwotmusic/components/widgets/multi_value_listenable_builder.widget.dart';
import 'package:kwotmusic/components/widgets/notificationbar/notification_bar.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/playback/playback.dart';
import 'package:kwotmusic/features/playback/video/fullscreen/video_page_interface.dart';
import 'package:kwotmusic/features/playback/video/fullscreen/widget/fullscreen_artist_control_button.dart';
import 'package:kwotmusic/features/playback/video/fullscreen/widget/fullscreen_comments_visibility_control_button.dart';
import 'package:kwotmusic/features/playback/video/fullscreen/widget/fullscreen_dislike_control_button.dart';
import 'package:kwotmusic/features/playback/video/fullscreen/widget/fullscreen_icon_control_button.dart';
import 'package:kwotmusic/features/playback/video/fullscreen/widget/fullscreen_like_control_button.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:provider/provider.dart';

class LandscapeVideoPlaybackControls extends StatelessWidget {
  const LandscapeVideoPlaybackControls({
    Key? key,
    required this.commentsVisibilityNotifier,
    required this.onCommentVisibilityButtonTap,
    required this.onMinimizeButtonTap,
    required this.onOptionsButtonTap,
  }) : super(key: key);

  final ValueNotifier<bool> commentsVisibilityNotifier;
  final VoidCallback onCommentVisibilityButtonTap;
  final VoidCallback onMinimizeButtonTap;
  final VoidCallback onOptionsButtonTap;

  Color get controlsBackgroundColor =>
      DynamicTheme.displayBlack.withOpacity(0.5);

  VideoPageInterface pageInterfaceOf(BuildContext context) {
    return context.read<VideoPageInterface>();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<VideoControlsState?>(
        valueListenable: videoPlayerManager.controlsStateNotifier,
        builder: (_, state, __) {
          if (state == null) {
            return _buildPlaybackLoadingWidget(context);
          }

          if (state.hasError) {
            return _buildPlaybackErrorWidget(context, error: state.error!);
          }

          if (state.isLoading) {
            return _buildPlaybackLoadingWidget(context);
          }

          if (state.isFinished) {
            return _buildPlaybackFinishedWidget(
              context,
              canReplay: !state.isLivestream,
            );
          }

          return Stack(children: [
            const Positioned.fill(child: VideoPlaybackSubtitlesWidget()),
            Positioned.fill(child: _buildControlsVisibilityHandler(context))
          ]);
        });
  }

  Widget _buildPlaybackInfoOverlay(
    BuildContext context, {
    required Widget child,
  }) {
    return Container(
        color: controlsBackgroundColor,
        child: Stack(children: [
          Positioned.fill(child: child),
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildTopControlsBar(context, showOptionsButton: false)),
        ]));
  }

  Widget _buildPlaybackLoadingWidget(BuildContext context) {
    return _buildPlaybackInfoOverlay(context, child: const LoadingIndicator());
  }

  Widget _buildPlaybackErrorWidget(
    BuildContext context, {
    required String error,
  }) {
    return _buildPlaybackInfoOverlay(context,
        child: VideoPlaybackError(
            error: error,
            onRetry: () {
              controlsVisibilityModelOf(context).restartTimer();
              videoPlayerManager.retryPlaying();
            }));
  }

  Widget _buildPlaybackFinishedWidget(
    BuildContext context, {
    bool canReplay = false,
  }) {
    return _buildPlaybackInfoOverlay(context,
        child: VideoPlaybackCompleted(
            message: LocaleResources.of(context).errorBroadcastPlaybackHasEnded,
            onReplayTap: canReplay
                ? () {
                    controlsVisibilityModelOf(context).restartTimer();
                    videoPlayerManager.replay();
                  }
                : null));
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
          Column(children: [
            _buildTopControlsBar(context),
            const Spacer(),
            _buildMinimizeOptionBar(context),
            _buildProgressBar(context),
            _buildBottomControlsBar(context),
          ]),
          Center(child: _buildPlaybackControlsBar(context)),
        ]));
  }

  Widget _buildTopControlsBar(
    BuildContext context, {
    bool showOptionsButton = true,
  }) {
    return Row(children: [
      /// CLOSE BUTTON
      AppIconButton(
          width: ComponentSize.large.r,
          height: ComponentSize.large.r,
          assetColor: DynamicTheme.get(context).white(),
          assetPath: Assets.iconArrowDown,
          padding: EdgeInsets.all(ComponentInset.small.r),
          onPressed: () => _onCloseButtonTapped(context)),

      /// TITLE
      Expanded(
          child: ValueListenableBuilder<String?>(
              valueListenable: pageInterfaceOf(context).titleNotifier,
              builder: (_, title, __) {
                if (title == null) return Container();
                return Text(title,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyles.boldHeading5
                        .copyWith(color: DynamicTheme.get(context).white()));
              })),

      /// CAPTIONS BUTTON,
      if (showOptionsButton)
        TwoValuesListenableBuilder<bool, List<VideoPlaybackSubtitleTrack>>(
            valueListenable1:
                videoPlayerManager.isCaptionsOptionEnabledNotifier,
            valueListenable2:
                videoPlayerManager.availableSubtitleTracksNotifier,
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
                  onPressed: () =>
                      _onCaptionsButtonTap(context, captionsEnabled));
            }),

      /// OPTIONS BUTTON
      if (showOptionsButton)
        AppIconButton(
            width: ComponentSize.large.r,
            height: ComponentSize.large.r,
            assetColor: DynamicTheme.get(context).white(),
            assetPath: Assets.iconOptions,
            padding: EdgeInsets.all(ComponentInset.small.r),
            onPressed: () => _onOptionsButtonTap(context)),

      if (!showOptionsButton) SizedBox(width: ComponentSize.large.r),
    ]);
  }

  Widget _buildPlaybackControlsBar(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      /// SEEK BACKWARD BUTTON
      PlaybackSeekBackwardButton(
          notifier: videoPlayerManager.canSeekBackwardNotifier,
          onTap: () => _onSeekBackwardButtonTap(context)),
      SizedBox(width: ComponentInset.medium.r),

      /// PLAY BUTTON
      PlayButton(
          notifier: videoPlayerManager.playButtonStateNotifier,
          onPlayTap: videoPlayerManager.play,
          onPauseTap: videoPlayerManager.pause,
          size: 56.r,
          compact: true),
      SizedBox(width: ComponentInset.medium.r),

      /// SEEK FORWARD BUTTON
      PlaybackSeekForwardButton(
          notifier: videoPlayerManager.canSeekForwardNotifier,
          onTap: () => _onSeekForwardButtonTap(context)),
    ]);
  }

  Widget _buildMinimizeOptionBar(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Spacer(),

          /// MINIMIZE BUTTON
          AppIconButton(
              width: ComponentSize.small.r,
              height: ComponentSize.small.r,
              assetColor: DynamicTheme.get(context).white(),
              assetPath: Assets.iconMinimize,
              margin: EdgeInsets.only(bottom: ComponentInset.small.r),
              onPressed: () {
                controlsVisibilityModelOf(context).restartTimer();
                onMinimizeButtonTap();
              }),
          SizedBox(width: ComponentInset.normal.r)
        ]);
  }

  Widget _buildProgressBar(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
        child: PlayerSeekBar(
          notifier: videoPlayerManager.seekBarStateNotifier,
          onSeek: videoPlayerManager.seek,
          onDragging: (duration) =>
              controlsVisibilityModelOf(context).restartTimer(),
          trackCapShape: BarCapShape.round,
          thumbRadius: 8.r,
          timeLabelFormatForLivestream: TimeLabelFormat(
            leftTimeLabelText:
                LocaleResources.of(context).liveStreamTotalDuration,
            leftTimeLabelType: LeftTimeLabelType.custom,
            rightTimeLabelType: RightTimeLabelType.custom,
          ),
          timeLabelLocation: TimeLabelLocation.above,
          trackHeight: 4.r,
        ));
  }

  Widget _buildBottomControlsBar(BuildContext context) {
    final pageInterface = pageInterfaceOf(context);
    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.all(ComponentInset.normal.r),
        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          /// ARTIST
          FullScreenArtistControlButton(
              notifier: pageInterface.artistNotifier,
              onTap: () => _onArtistButtonTap(context)),
          SizedBox(width: ComponentInset.small.r),

          /// LIKES + LIKE TOGGLE
          FullScreenLikeControlButton(
              likedNotifier: pageInterface.likedNotifier,
              likesNotifier: pageInterface.likesNotifier,
              onTap: () => _onLikeButtonTap(context)),
          SizedBox(width: ComponentInset.small.r),

          /// DISLIKE TOGGLE
          FullScreenDislikeControlButton(
              notifier: pageInterface.dislikedNotifier,
              onTap: () => _onDislikeButtonTap(context)),
          SizedBox(width: ComponentInset.small.r),

          /// COMMENTS VISIBILITY TOGGLE
          FullScreenCommentsVisibilityControlButton(
              notifier: commentsVisibilityNotifier,
              onTap: () => _onCommentVisibilityButtonTap(context)),
          SizedBox(width: ComponentInset.small.r),

          /// SHARE
          FullScreenIconControlButton(
              size: ComponentSize.large.r,
              assetPath: Assets.iconShare,
              onTap: () => _onShareButtonTap(context)),
          SizedBox(width: ComponentInset.small.r),

          // /// DOWNLOAD
          // _buildDownloadButton(context),

          // /// SAVE
          // FullScreenIconControlButton(
          //     size: ComponentSize.large.r,
          //     assetPath: Assets.iconSave,
          //     onTap: () => _onSaveButtonTap(context)),
        ]),
      ),
    );
  }

  Widget _buildDownloadButton(BuildContext context) {
    return ValueListenableBuilder<bool>(
        valueListenable: pageInterfaceOf(context).canDownloadVideoNotifier,
        builder: (_, canDownload, __) {
          if (!canDownload) return Container();
          return FullScreenIconControlButton(
              size: ComponentSize.large.r,
              assetPath: Assets.iconDownload,
              margin: EdgeInsets.only(right: ComponentInset.small.r),
              onTap: () => _onDownloadButtonTap(context));
        });
  }

  VideoControlsVisibilityModel controlsVisibilityModelOf(BuildContext context) {
    return context.read<VideoControlsVisibilityModel>();
  }

  void _onArtistButtonTap(BuildContext context) async {
    await videoPlayerManager.exitPresentationMode();
    RootNavigation.popUntilRoot(context);

    pageInterfaceOf(context).onArtistButtonTap(context);
  }

  void _onCaptionsButtonTap(BuildContext context, bool captionsEnabled) {
    controlsVisibilityModelOf(context).restartTimer();
    captionsEnabled
        ? videoPlayerManager.disableCaptions()
        : videoPlayerManager.enableCaptions();
  }

  void _onCloseButtonTapped(BuildContext context) {
    RootNavigation.pop(context);
  }

  void _onCommentVisibilityButtonTap(BuildContext context) {
    controlsVisibilityModelOf(context).restartTimer();
    onCommentVisibilityButtonTap();
  }

  void _onDislikeButtonTap(BuildContext context) async {
    controlsVisibilityModelOf(context).restartTimer();

    showBlockingProgressDialog(context);
    final result = await pageInterfaceOf(context).onDislikeButtonTap();
    hideBlockingProgressDialog(context);

    if (!result.isSuccess()) {
      showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()));
    }
  }

  void _onDownloadButtonTap(BuildContext context) {
    controlsVisibilityModelOf(context).restartTimer();
  }

  void _onLikeButtonTap(BuildContext context) async {
    controlsVisibilityModelOf(context).restartTimer();

    showBlockingProgressDialog(context);
    final result = await pageInterfaceOf(context).onLikeButtonTap();
    hideBlockingProgressDialog(context);

    if (!result.isSuccess()) {
      showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()));
    }
  }

  void _onOptionsButtonTap(BuildContext context) {
    controlsVisibilityModelOf(context).restartTimer();
    onOptionsButtonTap();
  }

  void _onSaveButtonTap(BuildContext context) {
    controlsVisibilityModelOf(context).restartTimer();
  }

  void _onSeekBackwardButtonTap(BuildContext context) {
    controlsVisibilityModelOf(context).restartTimer();
    videoPlayerManager.quickSeekBackward();
  }

  void _onSeekForwardButtonTap(BuildContext context) {
    controlsVisibilityModelOf(context).restartTimer();
    videoPlayerManager.quickSeekForward();
  }

  void _onShareButtonTap(BuildContext context) {
    controlsVisibilityModelOf(context).restartTimer();
    pageInterfaceOf(context).onShareButtonTap();
  }
}
