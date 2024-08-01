import 'package:kwotdata/api/audioplayer.dart';
import 'package:kwotmusic/components/widgets/photo/photo_kind.dart';

extension PlaybackKindExt on PlaybackKind {
  //=
  /// Returns [PhotoKind] to determine which placeholder
  /// to use for the artwork
  PhotoKind get photoKind {
    switch (this) {
      case PlaybackKind.podcastEpisode:
        return PhotoKind.podcastEpisode;
      case PlaybackKind.radioStation:
        return PhotoKind.radioStation;
      case PlaybackKind.skit:
        return PhotoKind.skit;
      case PlaybackKind.track:
        return PhotoKind.track;
    }
  }
}
