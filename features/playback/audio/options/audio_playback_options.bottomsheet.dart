import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/models/models.dart';
import 'package:kwotdata/api/audioplayer.dart';
import 'package:kwotmusic/features/podcastepisode/list/option/podcast_episode_options.bottomsheet.dart';
import 'package:kwotmusic/features/podcastepisode/list/option/podcast_episode_options.model.dart';
import 'package:kwotmusic/features/radiostation/option/radiostation_options.bottomsheet.dart';
import 'package:kwotmusic/features/skit/options/skit_options.bottomsheet.dart';
import 'package:kwotmusic/features/skit/options/skit_options.model.dart';
import 'package:kwotmusic/features/track/options/track_options.bottomsheet.dart';
import 'package:kwotmusic/features/track/options/track_options.model.dart';

class AudioPlaybackOptionsBottomSheet {
  //=
  static Future show(
    BuildContext context, {
    required PlaybackItem item,
    bool showRemoveFromQueueOption = true,
  }) {
    switch (item.kind) {

      /// [PodcastEpisode] options
      case PlaybackKind.podcastEpisode:
        final episode = item.data as PodcastEpisode;
        return PodcastEpisodeOptionsBottomSheet.show(
          context,
          args: PodcastEpisodeOptionsArgs(
            episode: episode,
            playbackItem: showRemoveFromQueueOption ? item : null,
          ),
        );

      /// [RadioStation] options
      case PlaybackKind.radioStation:
        final radioStation = item.data as RadioStation;
        return RadioStationOptionsBottomSheet.show(
          context,
          radioStation: radioStation,
          playbackItem: showRemoveFromQueueOption ? item : null,
        );

      /// [Skit] options
      case PlaybackKind.skit:
        final skit = item.data as Skit;
        return SkitOptionsBottomSheet.show(
          context,
          args: SkitOptionsArgs(
            skit: skit,
            playbackItem: showRemoveFromQueueOption ? item : null,
          ),
        );

      /// [Track] options
      case PlaybackKind.track:
        final track = item.data as Track;
        return TrackOptionsBottomSheet.show(
          context,
          args: TrackOptionsArgs(
            track: track,
            playbackItem: showRemoveFromQueueOption ? item : null,
          ),
        );
    }
  }
}
