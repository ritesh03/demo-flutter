import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotmusic/components/widgets/page/page_state.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/playback/audio/audio_playback_actions.model.dart';
import 'package:kwotmusic/features/playback/playback.dart';
import 'package:kwotmusic/features/playback/video/fullscreen/video_page_interface.dart';
import 'package:kwotmusic/features/playback/video/widget/video_page_comments_panel.dart';
import 'package:kwotmusic/features/playback/video/widget/video_page_live_chat_panel.dart';
import 'package:provider/provider.dart';

import 'portrait_video_playback_controls.dart';

class PortraitVideoPlaybackPage extends StatefulWidget {
  const PortraitVideoPlaybackPage({
    Key? key,
    required this.animation,
    required this.secondaryAnimation,
    required this.controllerProvider,
  }) : super(key: key);

  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final BetterPlayerControllerProvider controllerProvider;

  @override
  State<PortraitVideoPlaybackPage> createState() =>
      _PortraitVideoPlaybackPageState();
}

class _PortraitVideoPlaybackPageState
    extends PageState<PortraitVideoPlaybackPage> {
  //=

  final panelHeightFactor = 0.6;

  late ValueNotifier<bool> _commentsVisibilityNotifier;
  late ValueNotifier<double> _commentsPanelHeightFactorNotifier;

  VideoPageInterface get pageInterface => context.read<VideoPageInterface>();

  @override
  void initState() {
    super.initState();

    // TODO: Pause music even on resume of video-player
    //  or when coming back from another page
    locator<AudioPlaybackActionsModel>().stopAudioPlayback(onlyIfPlaying: true);

    _commentsVisibilityNotifier = ValueNotifier<bool>(false);
    _commentsPanelHeightFactorNotifier = ValueNotifier<double>(0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: widget.animation,
        builder: (BuildContext context, Widget? child) {
          return SafeArea(
              child: Scaffold(
                  resizeToAvoidBottomInset: false,
                  body: Stack(children: [
                    Column(children: [
                      Expanded(child: _buildPlayerAndControls()),
                      _buildCommentsPanelPlaceholder(),
                    ]),
                    Positioned.fill(child: _buildLiveChatPanel()),
                    Positioned.fill(child: _buildCommentsPanel()),
                  ])));
        });
  }

  Widget _buildPlayerAndControls() {
    return Stack(children: [
      Positioned.fill(child: widget.controllerProvider),
      Positioned.fill(
          child: PortraitVideoPlaybackControls(
              commentsVisibilityNotifier: _commentsVisibilityNotifier,
              onCommentVisibilityButtonTap: _onCommentVisibilityButtonTap,
              onMinimizeButtonTap: _onMinimizeButtonTapped,
              onOptionsButtonTap: _onOptionsButtonTapped)),
    ]);
  }

  Widget _buildCommentsPanelPlaceholder() {
    final size = MediaQuery.of(context).size;
    return ValueListenableBuilder<double>(
        valueListenable: _commentsPanelHeightFactorNotifier,
        builder: (_, heightFactor, __) {
          return AnimatedSize(
              duration: const Duration(milliseconds: 200),
              child: SizedBox(
                width: double.infinity,
                height: size.height * heightFactor,
              ));
        });
  }

  Widget _buildLiveChatPanel() {
    final size = MediaQuery.of(context).size;
    return ValueListenableBuilder<LiveStreamMode>(
        valueListenable: pageInterface.liveStreamModeNotifier,
        builder: (_, mode, __) {
          if (mode == LiveStreamMode.none) return Container();
          return VideoPageLiveChatPanel(
              liveStreamMode: mode,
              maxHeight: size.height * panelHeightFactor,
              pageInterface: pageInterface,
              panelController: pageInterface.liveChatFullScreenPanelController,
              onPanelSlide: (factor) {
                _setCommentsVisibilityHeightFactor(factor: factor);
              },
              onPanelClosed: () {
                _onCommentsVisibilityChanged(isVisible: false);
              },
              onClose: () {
                pageInterface.onCloseLiveChatPanel(isFullScreenMode: true);
              });
        });
  }

  Widget _buildCommentsPanel() {
    final size = MediaQuery.of(context).size;
    return VideoPageCommentsPanel(
        maxHeight: size.height * panelHeightFactor,
        pageInterface: pageInterface,
        panelController: pageInterface.commentsFullScreenPanelController,
        onPanelSlide: (factor) {
          _setCommentsVisibilityHeightFactor(factor: factor);
        },
        onPanelClosed: () {
          _onCommentsVisibilityChanged(isVisible: false);
        },
        onClose: () {
          pageInterface.onCloseCommentsPanel(isFullScreenMode: true);
        });
  }

  void _onCommentVisibilityButtonTap() {
    final isLiveStream =
        pageInterface.liveStreamModeNotifier.value != LiveStreamMode.none;
    final isPanelVisible = _commentsPanelHeightFactorNotifier.value > 0;
    if (isLiveStream) {
      if (isPanelVisible) {
        pageInterface.onCloseLiveChatPanel(isFullScreenMode: true);
        _onCommentsVisibilityChanged(isVisible: false);
      } else {
        pageInterface.onOpenLiveChatPanel(isFullScreenMode: true);
        _onCommentsVisibilityChanged(isVisible: true);
      }

      return;
    }

    if (isPanelVisible) {
      pageInterface.onCloseCommentsPanel(isFullScreenMode: true);
      _onCommentsVisibilityChanged(isVisible: false);
    } else {
      pageInterface.onOpenCommentsPanel(isFullScreenMode: true);
      _onCommentsVisibilityChanged(isVisible: true);
    }
  }

  void _onMinimizeButtonTapped() {
    RootNavigation.pop(context);
  }

  void _onOptionsButtonTapped() {
    videoPlayerManager.pauseUntil(() async {
      await VideoPlaybackSettingsBottomSheet.show(
        context,
        onReportTap: () async {
          await videoPlayerManager.exitPresentationMode();
          RootNavigation.popUntilRoot(context);

          pageInterface.onReportButtonTap(context);
        },
      );
    });
  }

  void _onCommentsVisibilityChanged({required bool isVisible}) {
    _commentsVisibilityNotifier.value = isVisible;
    _commentsPanelHeightFactorNotifier.value =
        isVisible ? panelHeightFactor : 0;
  }

  void _setCommentsVisibilityHeightFactor({required double factor}) {
    _commentsPanelHeightFactorNotifier.value = panelHeightFactor * factor;
  }
}
