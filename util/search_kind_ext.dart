import 'package:kwotdata/models/search/search.dart';
import 'package:kwotmusic/components/widgets/photo/photo_kind.dart';

extension SearchKindExt on SearchKind {
  PhotoKind get photoKind {
    switch (this) {
      case SearchKind.album:
        return PhotoKind.album;
      case SearchKind.artist:
        return PhotoKind.artist;
      case SearchKind.playlist:
        return PhotoKind.playlist;
      case SearchKind.podcast:
        return PhotoKind.podcast;
      case SearchKind.podcastEpisode:
        return PhotoKind.podcastEpisode;
      case SearchKind.radioStation:
        return PhotoKind.radioStation;
      case SearchKind.show:
        return PhotoKind.show;
      case SearchKind.skit:
        return PhotoKind.skit;
      case SearchKind.track:
        return PhotoKind.track;
      case SearchKind.user:
        return PhotoKind.user;
    }
  }
}
