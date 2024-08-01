import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/api/audioplayer.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/button/buttons.dart';
import 'package:kwotmusic/components/widgets/indicator/indicators.dart';
import 'package:kwotmusic/components/widgets/multi_value_listenable_builder.widget.dart';
import 'package:kwotmusic/features/playback/audio/audio_playback_actions.model.dart';
import 'package:kwotmusic/features/playback/playback.dart';
import 'package:kwotmusic/features/show/detail/show_detail.bottomsheet.dart';
import 'package:kwotmusic/features/show/detail/show_detail.model.dart';
import 'package:kwotmusic/features/skit/detail/skit_detail.bottomsheet.dart';
import 'package:kwotmusic/features/skit/detail/skit_detail.model.dart';
import 'package:kwotmusic/l10n/localizations.dart';

class CompactPlaybackBar extends StatelessWidget {
  const CompactPlaybackBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TwoValuesListenableBuilder<PlaybackItem?, VideoItem?>(
        valueListenable1: audioPlayerManager.playbackItemNotifier,
        valueListenable2: videoPlayerManager.videoItemNotifier,
        builder: (_, playbackItem, videoItem, __) {
          final Widget child;
          if (playbackItem != null && videoItem != null) {
            child = Container(
                color: Colors.red,
                child: Text(
                    "Somehow video & audio is able to play at the same time",
                    style: TextStyles.heading5));
          } else if (playbackItem != null) {
            child = _CompactAudioPlaybackBar(playbackItem: playbackItem);
          } else if (videoItem != null) {
            child = _CompactVideoPlaybackBar(videoItem: videoItem);
          } else {
            return const SizedBox();
          }

          return _buildContainer(context, child);
        });
  }

  Widget _buildContainer(BuildContext context, Widget child) {
    return Dismissible(
        key: UniqueKey(),
        direction: DismissDirection.down,
        background: Container(color: Colors.transparent),
        onDismissed: (direction) => _onDismissed(),
        child: Material(
            color: Colors.transparent,
            child: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          DynamicTheme.get(context).neutral80(),
                          DynamicTheme.get(context).background()
                        ]),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(ComponentRadius.normal.r),
                        topRight: Radius.circular(ComponentRadius.normal.r))),
                clipBehavior: Clip.antiAlias,
                child: child)));
  }

  void _onDismissed() {
    locator<AudioPlaybackActionsModel>().stopPlayback();
  }
}

class _CompactAudioPlaybackBar extends StatelessWidget {
  const _CompactAudioPlaybackBar({
    Key? key,
    required this.playbackItem,
  }) : super(key: key);

  final PlaybackItem playbackItem;

  @override
  Widget build(BuildContext context) {
    return TappableButton(
        onTap: () => AudioPlaybackBottomSheet.show(context),
        child: Align(
            alignment: Alignment.topCenter,
            child: Stack(children: [
              const AudioPlayerSeekBar(compact: true),
              Padding(
                  padding: EdgeInsets.only(
                    left: ComponentInset.normal.r,
                    top: ComponentInset.normal.r,
                    right: ComponentInset.small.r,
                    bottom: ComponentInset.normal.r,
                  ),
                  child: Row(children: [
                    PlayerArtwork(size: ComponentSize.large.h),
                    SizedBox(width: ComponentInset.small.w),
                    Expanded(
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _CompactPlayerTitle(text: playbackItem.title),
                            _CompactPlayerSubtitle(text: playbackItem.subtitle),
                          ]),
                    ),
                    SizedBox(width: ComponentInset.small.w),
                    AudioPlayButton(compact: true, size: ComponentSize.large.r),
                  ]))
            ])));
  }
}

class _CompactVideoPlaybackBar extends StatelessWidget {
  const _CompactVideoPlaybackBar({
    Key? key,
    required this.videoItem,
  }) : super(key: key);

  final VideoItem videoItem;

  @override
  Widget build(BuildContext context) {
    return TappableButton(
        onTap: () => _onTap(context),
        child: Align(
            alignment: Alignment.topCenter,
            child: Stack(children: [
              const VideoPlayerSeekBar(compact: true),
              Padding(
                  padding: EdgeInsets.only(
                    left: ComponentInset.normal.r,
                    top: ComponentInset.normal.r,
                    right: ComponentInset.small.r,
                    bottom: ComponentInset.normal.r,
                  ),
                  child: Row(children: [
                    PreviewVideoPlayer(
                        controller: videoPlayerManager.controller!,
                        height: ComponentSize.large.h,
                        videoItem: videoItem),
                    SizedBox(width: ComponentInset.small.w),
                    Expanded(
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _CompactPlayerTitle(text: videoItem.title),
                            _CompactPlayerSubtitle(text: videoItem.subtitle),
                          ]),
                    ),
                    SizedBox(width: ComponentInset.small.w),
                    _buildTrailingWidget(),
                  ]))
            ])));
  }

  Widget _buildTrailingWidget() {
    return ValueListenableBuilder<VideoControlsState?>(
        valueListenable: videoPlayerManager.controlsStateNotifier,
        builder: (context, state, __) {
          if (state?.hasError == true) {
            return Container(
                margin:
                    EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
                child: Text(LocaleResources.of(context).error,
                    style: TextStyles.boldHeading5.copyWith(
                        color: DynamicTheme.get(context).error100())));
          }

          if (state == null || state.isLoading) {
            return Container(
                width: ComponentSize.smaller.r,
                height: ComponentSize.smaller.r,
                margin:
                    EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
                child: const LoadingIndicator());
          }

          if (state.isFinished && !state.isPlaying) {
            if (!state.isLivestream) {
              return Button(
                  height: ComponentSize.normal.r,
                  type: ButtonType.text,
                  text: LocaleResources.of(context).videoReplayButton,
                  margin:
                      EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
                  onPressed: videoPlayerManager.replay);
            }
          }

          return VideoPlayButton(compact: true, size: ComponentSize.large.r);
        });
  }

  void _onTap(BuildContext context) {
    switch (videoItem.type) {
      case VideoItemType.show:
        ShowDetailBottomSheet.showBottomSheet(context,
            args: ShowDetailArgs(
                id: videoItem.id,
                title: videoItem.title,
                thumbnail: videoItem.thumbnail));
        break;
      case VideoItemType.skit:
        SkitDetailBottomSheet.showBottomSheet(context,
            args: SkitDetailArgs(
                id: videoItem.id,
                title: videoItem.title,
                thumbnail: videoItem.thumbnail));
        break;
    }
  }
}

class _CompactPlayerTitle extends StatelessWidget {
  const _CompactPlayerTitle({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: ComponentSize.smaller.h,
        child: Text(text,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyles.boldBody));
  }
}

class _CompactPlayerSubtitle extends StatelessWidget {
  const _CompactPlayerSubtitle({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: ComponentSize.smallest.h,
        child: Text(text,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyles.heading6.copyWith(
              color: DynamicTheme.get(context).neutral10(),
            )));
  }
}
