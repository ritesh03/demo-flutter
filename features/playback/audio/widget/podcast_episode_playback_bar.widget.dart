import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/api/audioplayer.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/features/playback/audio/queue/playing_queue.bottomsheet.dart';
import 'package:kwotmusic/features/playback/playback.dart';
import 'package:share_plus/share_plus.dart';

class PodcastEpisodePlaybackBar extends StatelessWidget {
  const PodcastEpisodePlaybackBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final playerManager = audioPlayerManager;
    return Row(children: [
      PlaybackPlayingQueueButton(
          onTap: () => _onPlayQueueButtonTapped(context)),
      const Spacer(),
      PlaybackSeekBackwardButton(
        notifier: playerManager.canSeekBackwardNotifier,
        onTap: audioPlayerManager.seekBackward,
      ),
      SizedBox(width: ComponentInset.medium.w),
      AudioPlayButton(size: 56.r),
      SizedBox(width: ComponentInset.medium.w),
      PlaybackSeekForwardButton(
        notifier: playerManager.canSeekForwardNotifier,
        onTap: audioPlayerManager.seekForward,
      ),
      const Spacer(),
      AppIconButton(
          width: ComponentSize.small.r,
          height: ComponentSize.small.r,
          assetColor: DynamicTheme.get(context).neutral10(),
          assetPath: Assets.iconShare,
          onPressed: _onShareButtonTapped),
    ]);
  }

  void _onPlayQueueButtonTapped(BuildContext context) {
    PlayingQueueBottomSheet.show(context);
  }

  void _onShareButtonTapped() {
    final playbackItem = audioPlayerManager.playbackItemNotifier.value;
    if (playbackItem == null) return;

    Share.share(playbackItem.shareUrl);
  }
}
