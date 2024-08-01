import 'package:kwotmusic/features/playback/dependant_notifier.dart';

class VideoPlaybackSubtitleTrack {
  VideoPlaybackSubtitleTrack({
    required this.identifier,
    required this.name,
  });

  final String identifier;
  final String? name;
}

class VideoPlaybackSubtitleTrackNotifier
    extends DependantValueNotifier<VideoPlaybackSubtitleTrack?> {
  VideoPlaybackSubtitleTrackNotifier() : super(null);
}

class VideoPlaybackSubtitleTracksNotifier
    extends DependantValueNotifier<List<VideoPlaybackSubtitleTrack>> {
  VideoPlaybackSubtitleTracksNotifier() : super(List.empty());
}
