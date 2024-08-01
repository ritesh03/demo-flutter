import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotmusic/components/widgets/notificationbar/notification_bar.dart';
import 'package:kwotmusic/features/playback/audio/audio_playback_actions.model.dart';

import 'playback_source_play_button.widget.dart';

class DownloadsPlayButton extends StatelessWidget {
  const DownloadsPlayButton({
    Key? key,
    required this.size,
    this.iconSize,
  }) : super(key: key);

  final double size;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    return PlaybackSourcePlayButton(
      scopeId: 'downloads',
      size: size,
      iconSize: iconSize,
      onTap: _onTap,
    );
  }

  void _onTap() async {
    final result = await locator<AudioPlaybackActionsModel>().playDownloads();
    if (!result.isSuccess()) {
      showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()));
    }
  }
}
