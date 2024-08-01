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

import 'landscape_video_playback_controls.dart';

class LandscapeVideoPlaybackPage extends StatefulWidget {
  const LandscapeVideoPlaybackPage({
    Key? key,
    required this.animation,
    required this.secondaryAnimation,
    required this.controllerProvider,
  }) : super(key: key);

  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final BetterPlayerControllerProvider controllerProvider;

  @override
  State<LandscapeVideoPlaybackPage> createState() =>
      _LandscapeVideoPlaybackPageState();
}

class _LandscapeVideoPlaybackPageState
    extends PageState<LandscapeVideoPlaybackPage> {
  //=

  final panelWidthFactor = 0.4;

  late ValueNotifier<bool> _commentsVisibilityNotifier;
  late ValueNotifier<double> _commentsPanelWidthFactorNotifier;

  VideoPageInterface get pageInterface => context.read<VideoPageInterface>();

  @override
  void initState() {
    super.initState();

    // TODO: Pause music even on resume of video-player
    //  or when coming back from another page
    locator<AudioPlaybackActionsModel>().stopAudioPlayback(onlyIfPlaying: true);

    _commentsVisibilityNotifier = ValueNotifier<bool>(false);
    _commentsPanelWidthFactorNotifier = ValueNotifier<double>(0);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final panelWidth = size.width * panelWidthFactor;

    return AnimatedBuilder(
        animation: widget.animation,
        builder: (BuildContext context, Widget? child) {
          return SafeArea(
              child: Scaffold(
                  resizeToAvoidBottomInset: false,
                  body: Stack(children: [
                    Row(children: [
                      Expanded(child: _buildPlayerAndControls()),
                      _buildCommentsPanelPlaceholder(),
                    ]),
                    Positioned(
                        top: 0,
                        bottom: 0,
                        right: 0,
                        width: panelWidth,
                        child: _buildLiveChatPanel(panelWidth: panelWidth)),
                    Positioned(
                        top: 0,
                        bottom: 0,
                        right: 0,
                        width: panelWidth,
                        child: _buildCommentsPanel(panelWidth: panelWidth)),
                  ])));
        });
  }

  Widget _buildPlayerAndControls() {
    return Stack(children: [
      Positioned.fill(child: widget.controllerProvider),
      Positioned.fill(
          child: LandscapeVideoPlaybackControls(
              commentsVisibilityNotifier: _commentsVisibilityNotifier,
              onCommentVisibilityButtonTap: _onCommentVisibilityButtonTap,
              onMinimizeButtonTap: _onMinimizeButtonTapped,
              onOptionsButtonTap: _onOptionsButtonTapped)),
    ]);
  }

  Widget _buildCommentsPanelPlaceholder() {
    final size = MediaQuery.of(context).size;
    return ValueListenableBuilder<double>(
        valueListenable: _commentsPanelWidthFactorNotifier,
        builder: (_, widthFactor, __) {
          return AnimatedSize(
              duration: const Duration(milliseconds: 200),
              child: SizedBox(
                width: size.width * widthFactor,
                height: double.infinity,
              ));
        });
  }

  Widget _buildLiveChatPanel({required double panelWidth}) {
    final size = MediaQuery.of(context).size;
    return ValueListenableBuilder<LiveStreamMode>(
        valueListenable: pageInterface.liveStreamModeNotifier,
        builder: (_, mode, __) {
          if (mode == LiveStreamMode.none) return Container();
          return VideoPageLiveChatPanel(
              liveStreamMode: mode,
              maxWidth: panelWidth,
              maxHeight: size.height,
              pageInterface: pageInterface,
              panelController: pageInterface.liveChatFullScreenPanelController,
              onPanelSlide: (factor) {
                _setCommentsVisibilityWidthFactor(factor: factor);
              },
              onPanelClosed: () {
                _onCommentsVisibilityChanged(isVisible: false);
              },
              onClose: () {
                pageInterface.onCloseLiveChatPanel(isFullScreenMode: true);
              });
        });
  }

  Widget _buildCommentsPanel({required double panelWidth}) {
    final size = MediaQuery.of(context).size;
    return VideoPageCommentsPanel(
        maxWidth: panelWidth,
        maxHeight: size.height,
        pageInterface: pageInterface,
        panelController: pageInterface.commentsFullScreenPanelController,
        onPanelSlide: (factor) {
          _setCommentsVisibilityWidthFactor(factor: factor);
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
    final isPanelVisible = _commentsPanelWidthFactorNotifier.value > 0;
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

          if (!mounted) return;
          RootNavigation.popUntilRoot(context);

          pageInterface.onReportButtonTap(context);
        },
      );
    });
  }

  void _onCommentsVisibilityChanged({required bool isVisible}) {
    _commentsVisibilityNotifier.value = isVisible;
    _commentsPanelWidthFactorNotifier.value = isVisible ? panelWidthFactor : 0;
  }

  void _setCommentsVisibilityWidthFactor({required double factor}) {
    _commentsPanelWidthFactorNotifier.value = panelWidthFactor * factor;
  }
}
