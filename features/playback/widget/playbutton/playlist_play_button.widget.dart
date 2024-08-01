import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/models/models.dart';
import 'package:kwotmusic/components/widgets/notificationbar/notification_bar.dart';
import 'package:kwotmusic/features/playback/audio/audio_playback_actions.model.dart';

import '../../../../l10n/localizations.dart';
import '../../../profile/subscriptions/subscription_enforcement.dart';
import 'playback_source_play_button.widget.dart';

class PlaylistPlayButton extends StatelessWidget {
  const PlaylistPlayButton({
    Key? key,
    required this.playlist,
    required this.size,
    this.iconSize,
  }) : super(key: key);

  final Playlist playlist;
  final double size;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    return PlaybackSourcePlayButton(
      scopeId: playlist.id,
      size: size,
      iconSize: iconSize,
      onTap: (){
        _onTap(context);
      },
    );
  }

  void _onTap(BuildContext context) async {
    final fulfilled = SubscriptionEnforcement.fulfilSubscriptionRequirement(
      context,
      feature: "listen-online", text: LocaleResources.of(context).yourSubscriptionDoesNotAllowListenOline,
    );
    if (!fulfilled) return;
    final result = await locator<AudioPlaybackActionsModel>().playPlaylist(playlist.id);
    if (!result.isSuccess()) {
      showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()));
    }
  }
}
