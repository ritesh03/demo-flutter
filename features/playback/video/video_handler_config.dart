import 'package:kwotmusic/features/playback/dependant_notifier.dart';
import 'package:kwotmusic/features/playback/playback.dart';

class VideoHandlerConfig {
  VideoHandlerConfig({
    required this.videoItem,
    this.autoPlay = true,
    this.isLivestream = false,
  });

  final VideoItem videoItem;
  final bool autoPlay;
  final bool isLivestream;
}

typedef VideoHandlerConfigNotifier = DependantValueNotifier<VideoHandlerConfig>;
