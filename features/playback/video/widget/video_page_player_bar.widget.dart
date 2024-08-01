import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/app_config.dart';
import 'package:kwotmusic/features/playback/playback.dart';
import 'package:kwotmusic/features/playback/video/fullscreen/video_page_interface.dart';

class VideoPagePlayerBar extends StatelessWidget {
  const VideoPagePlayerBar({
    Key? key,
    required this.pageInterface,
  }) : super(key: key);

  final VideoPageInterface pageInterface;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
        aspectRatio: AppConfig.videoPlaybackAspectRatio,
        child: VideoPlayerWidget(
            controller: videoPlayerManager.controller!,
            pageInterface: pageInterface));
  }
}
