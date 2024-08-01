import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/api/audioplayer.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/features/playback/playback.dart';
import 'package:share_plus/share_plus.dart';

class RadioStationPlaybackBar extends StatelessWidget {
  const RadioStationPlaybackBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      // TODO: space for external-devices option
      //  Also, balances items to be centered in this row
      SizedBox(width: ComponentSize.small.r),
      const Spacer(),
      AudioPlayButton(size: 56.r),
      const Spacer(),
      AppIconButton(
          width: ComponentSize.small.r,
          height: ComponentSize.small.r,
          assetColor: DynamicTheme.get(context).neutral10(),
          assetPath: Assets.iconShare,
          onPressed: _onShareButtonTapped),
    ]);
  }

  void _onShareButtonTapped() {
    final playbackItem = audioPlayerManager.playbackItemNotifier.value;
    if (playbackItem == null) return;

    Share.share(playbackItem.shareUrl);
  }
}
