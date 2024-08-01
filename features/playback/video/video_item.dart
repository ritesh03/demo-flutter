import 'package:kwotdata/kwotdata.dart';
import 'package:kwotdata/models/videos/video.dart';
import 'package:kwotmusic/features/playback/dependant_notifier.dart';

enum VideoItemType { show, skit, video }

class VideoItem {
  VideoItem({
    required this.id,
    required this.data,
    required this.isAudioOnly,
    required this.isLivestream,
    required this.subtitle,
    required this.thumbnail,
    required this.title,
    required this.type,
    required this.url,
  });

  final String id;
  final dynamic data;
  final bool isAudioOnly;
  final bool isLivestream;
  final String subtitle;
  final String? thumbnail;
  final String title;
  final VideoItemType type;
  final String url;

  VideoItem.fromShow(Show show)
      : id = show.id,
        data = show,
        isAudioOnly = false,
        isLivestream = show.isStreamingNow,
        subtitle = show.artist.name,
        thumbnail = show.thumbnail,
        title = show.title,
        type = VideoItemType.show,
        url = show.url!;

  VideoItem.fromSkit(Skit skit)
      : id = skit.id,
        data = skit,
        isAudioOnly = (SkitType.audio == skit.type),
        isLivestream = false,
        subtitle = skit.artist.name,
        thumbnail = skit.thumbnail,
        title = skit.title,
        type = VideoItemType.skit,
        url = skit.url;

  VideoItem.fromVideos(Videos videos)
      : id = videos.id,
        data = videos,
        isAudioOnly = false,
        isLivestream = false,
        subtitle = videos.title,
        thumbnail = videos.image,
        title = videos.title,
        type = VideoItemType.video,
        url = videos.url;


}

class VideoItemNotifier extends DependantValueNotifier<VideoItem?> {
  VideoItemNotifier() : super(null);
}
