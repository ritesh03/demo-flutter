import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/api/audioplayer.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/features/playback/playback.dart';

class PlaybackRepeatButton extends StatelessWidget {
  const PlaybackRepeatButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PlayerRepeatMode?>(
        valueListenable: audioPlayerManager.repeatModeNotifier,
        builder: (_, mode, __) {
          if (mode == null) return SizedBox(width: ComponentSize.small.r);
          return AppIconButton(
              width: ComponentSize.small.r,
              height: ComponentSize.small.r,
              assetColor: DynamicTheme.get(context).white(),
              assetPath: _obtainIcon(mode),
              onPressed: audioPlayerManager.repeat);
        });
  }

  String _obtainIcon(PlayerRepeatMode mode) {
    switch (mode) {
      case PlayerRepeatMode.none:
        return Assets.iconRepeat;
      case PlayerRepeatMode.one:
        return Assets.iconRepeatOnce;
      case PlayerRepeatMode.all:
        return Assets.iconRepeatLoop;
    }
  }
}
