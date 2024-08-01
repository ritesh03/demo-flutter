import 'package:kwotmusic/features/playback/dependant_notifier.dart';

class VideoPlaybackSubtitle {
  VideoPlaybackSubtitle({
    required this.start,
    required this.end,
    required this.texts,
  });

  final Duration start;
  final Duration end;
  final List<String> texts;
}

class VideoPlaybackSubtitleNotifier
    extends DependantValueNotifier<VideoPlaybackSubtitle?> {
  VideoPlaybackSubtitleNotifier() : super(null);
}
