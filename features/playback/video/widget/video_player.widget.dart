import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/app_config.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/features/playback/playback.dart';
import 'package:kwotmusic/features/playback/video/fullscreen/fullscreen_video_playback.page.dart';
import 'package:kwotmusic/features/playback/video/fullscreen/video_page_interface.dart';
import 'package:kwotmusic/util/video_item_type_ext.dart';
import 'package:provider/provider.dart';

import 'video_page_placeholder_photo.widget.dart';

class VideoPlayerWidget extends StatelessWidget {
  const VideoPlayerWidget({
    Key? key,
    required this.controller,
    required this.pageInterface,
  }) : super(key: key);

  final BetterPlayerController controller;
  final VideoPageInterface pageInterface;

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.black,
        child: ValueListenableBuilder<VideoItem?>(
            valueListenable: videoPlayerManager.videoItemNotifier,
            builder: (_, videoItem, __) {
              if (videoItem == null) return Container();
              if (videoItem.isAudioOnly) {
                return SizedBox.expand(
                  child: VideoPagePlaceholderPhoto(
                    notifier: pageInterface.thumbnailNotifier,
                    photoKind: pageInterface.getPhotoKind(),
                  ),
                );
              }

              return BetterPlayer(
                  controller: controller,
                  routePageBuilder:
                      (_, animation, secondaryAnimation, controllerProvider) {
                    return _buildFullScreenRouteWidget(
                        animation: animation,
                        secondaryAnimation: secondaryAnimation,
                        controllerProvider: controllerProvider);
                  });
            }));
  }

  Widget _buildFullScreenRouteWidget({
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
    required BetterPlayerControllerProvider controllerProvider,
  }) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => VideoControlsVisibilityModel()),
          Provider<VideoPageInterface>.value(value: pageInterface)
        ],
        child: FullScreenVideoPlaybackPage(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            controllerProvider: controllerProvider));
  }
}

class PreviewVideoPlayer extends StatelessWidget {
  const PreviewVideoPlayer({
    Key? key,
    required this.controller,
    this.width,
    this.height,
    required this.videoItem,
  }) : super(key: key);

  final BetterPlayerController controller;
  final double? width;
  final double? height;
  final VideoItem videoItem;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(ComponentRadius.normal.r);
    return Container(
        decoration:
            BoxDecoration(color: Colors.black, borderRadius: borderRadius),
        width: width,
        height: height,
        child: AspectRatio(
          aspectRatio:
              videoItem.isAudioOnly ? 1.0 : AppConfig.videoPlaybackAspectRatio,
          child: videoItem.isAudioOnly
              ? VideoPagePlaceholderPhoto(
                  thumbnail: videoItem.thumbnail,
                  photoKind: videoItem.type.photoKind,
                  borderRadius: borderRadius)
              : BetterPlayer(controller: controller, previewMode: true),
        ));
  }
}
