import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/blocking_progress.dialog.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/notificationbar/notification_bar.dart';
import 'package:kwotmusic/features/playback/audio/audio_playback_actions.model.dart';

class PlaybackShuffleButton extends StatelessWidget {
  const PlaybackShuffleButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
        stream: locator<KwotData>().playQueueRepository.shuffledStream,
        initialData: false,
        builder: (_, snapshot) {
          final shuffled = snapshot.data ?? false;
          return AppIconButton(
            width: ComponentSize.small.r,
            height: ComponentSize.small.r,
            assetColor: DynamicTheme.get(context).white(),
            assetPath: shuffled
                ? Assets.iconPlaybackShuffleActive
                : Assets.iconPlaybackShuffle,
            onPressed: () => _onTap(context),
          );
        });
  }

  void _onTap(BuildContext context) {
    showBlockingProgressDialog(context);
    locator<AudioPlaybackActionsModel>().shuffle().then((result) {
      hideBlockingProgressDialog(context);
      if (!result.isSuccess()) {
        showDefaultNotificationBar(
            NotificationBarInfo.error(message: result.error()));
      }
    });
  }
}
