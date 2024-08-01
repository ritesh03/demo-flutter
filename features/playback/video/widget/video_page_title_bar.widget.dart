import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/features/playback/video/fullscreen/video_page_interface.dart';

class VideoPageTitleBar extends StatelessWidget {
  const VideoPageTitleBar({
    Key? key,
    required this.pageInterface,
  }) : super(key: key);

  final VideoPageInterface pageInterface;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
        valueListenable: pageInterface.titleNotifier,
        builder: (context, title, __) {
          return Text(title ?? " ",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.boldHeading2.copyWith(
                color: DynamicTheme.get(context).white(),
              ));
        });
  }
}
