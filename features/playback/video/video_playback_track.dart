import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/features/playback/dependant_notifier.dart';

class VideoPlaybackTrack {
  VideoPlaybackTrack({
    this.id,
    this.width,
    this.height,
    this.bitrate,
  });

  VideoPlaybackTrack.auto()
      : id = null,
        width = null,
        height = null,
        bitrate = null;

  final String? id;
  final int? width;
  final int? height;
  final int? bitrate;

  @override
  bool operator ==(Object other) {
    return other is VideoPlaybackTrack &&
        id == other.id &&
        width == other.width &&
        height == other.height &&
        bitrate == other.bitrate;
  }

  @override
  int get hashCode => hashValues(id, width, height, bitrate);

  @override
  String toString() {
    return "VideoPlaybackTrack(id: $id, width: $width, height: $height, bitrate: $bitrate)";
  }
}

extension VideoPlaybackTrackExtension on VideoPlaybackTrack {
  bool get isAuto {
    return (width == 0 && height == 0 && bitrate == 0) ||
        (width == null && height == null && bitrate == null);
  }

  String? get name {
    final height = this.height;
    if (height != null) {
      return "${height}p";
    }

    return null;
  }
}

class VideoPlaybackTrackNotifier
    extends DependantValueNotifier<VideoPlaybackTrack> {
  VideoPlaybackTrackNotifier({
    VideoPlaybackTrack? track,
  }) : super(track ?? VideoPlaybackTrack.auto());
}

class VideoPlaybackTracksNotifier
    extends DependantValueNotifier<List<VideoPlaybackTrack>> {
  VideoPlaybackTracksNotifier({
    List<VideoPlaybackTrack>? tracks,
  }) : super(tracks ?? []);
}
