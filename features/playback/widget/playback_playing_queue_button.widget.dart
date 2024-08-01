import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/api/audioplayer.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/features/playback/playback.dart';

class PlaybackPlayingQueueButton extends StatelessWidget {
  const PlaybackPlayingQueueButton({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PlaybackItem?>(
        valueListenable: audioPlayerManager.playbackItemNotifier,
        builder: (_, playbackItem, __) {
          if (playbackItem == null || playbackItem.isLivestream) {
            return Container(width: ComponentSize.small.r);
          }

          return AppIconButton(
              width: ComponentSize.small.r,
              height: ComponentSize.small.r,
              assetColor: DynamicTheme.get(context).neutral10(),
              assetPath: Assets.iconMusicList,
              onPressed: onTap);
        });
  }
}
