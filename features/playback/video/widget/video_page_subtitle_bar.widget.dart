import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/features/playback/video/fullscreen/video_page_interface.dart';

class VideoPageSubtitleBar extends StatelessWidget {
  const VideoPageSubtitleBar({
    Key? key,
    required this.pageInterface,
  }) : super(key: key);

  final VideoPageInterface pageInterface;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
        valueListenable: pageInterface.subtitleNotifier,
        builder: (context, subtitle, __) {
          if (subtitle == null) return Container();
          return Text(subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.body
                  .copyWith(color: DynamicTheme.get(context).neutral10()));
        });
  }
}
