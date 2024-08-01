import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/models/models.dart';
import 'package:kwotmusic/features/playback/audio/audio_playback_actions.model.dart';

import '../../../../l10n/localizations.dart';
import '../../../profile/subscriptions/subscription_enforcement.dart';
import 'playback_item_play_button.widget.dart';

class PodcastEpisodePlayButton extends StatelessWidget {
  const PodcastEpisodePlayButton({
    Key? key,
    required this.episode,
    required this.size,
    this.iconSize,
  }) : super(key: key);

  final PodcastEpisode episode;
  final double size;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    return PlaybackItemPlayButton(
      scopeId: episode.id,
      size: size,
      iconSize: iconSize,
      onTap: () {
        final fulfilled = SubscriptionEnforcement.fulfilSubscriptionRequirement(
          context,
          feature: "listen-online", text: LocaleResources.of(context).yourSubscriptionDoesNotAllowListenOline,
        );
        if (!fulfilled) return;
        locator<AudioPlaybackActionsModel>().playPodcastEpisode(episode);
      }

    );
  }
}
