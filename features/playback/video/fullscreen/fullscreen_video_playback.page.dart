import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/features/playback/playback.dart';
import 'package:kwotmusic/features/playback/video/fullscreen/landscape/landscape_video_playback.page.dart';

import 'portrait/portrait_video_playback.page.dart';

class FullScreenVideoPlaybackPage extends StatelessWidget {
  const FullScreenVideoPlaybackPage({
    Key? key,
    required this.animation,
    required this.secondaryAnimation,
    required this.controllerProvider,
  }) : super(key: key);

  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final BetterPlayerControllerProvider controllerProvider;

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (_, orientation) {
      switch (orientation) {
        case Orientation.landscape:
          return LandscapeVideoPlaybackPage(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            controllerProvider: controllerProvider,
          );
        case Orientation.portrait:
          return PortraitVideoPlaybackPage(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            controllerProvider: controllerProvider,
          );
      }
    });
  }
}
