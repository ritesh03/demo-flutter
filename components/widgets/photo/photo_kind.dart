import 'package:kwotmusic/components/kit/assets.dart';

enum PhotoKind {
  album,
  any,
  artist,
  country,
  playlist,
  podcast,
  podcastCategory,
  podcastEpisode,
  profileCover,
  radioStation,
  show,
  skit,
  track,
  user;
}

extension PhotoKindExt on PhotoKind {
  String get placeholderAssetPath {
    switch (this) {
      case PhotoKind.album:
        return Assets.placeholderAlbum;
      case PhotoKind.any:
        return Assets.placeholderAny;
      case PhotoKind.artist:
        return Assets.placeholderArtist;
      case PhotoKind.country:
        return Assets.placeholderCountry;
      case PhotoKind.playlist:
        return Assets.placeholderPlaylist;
      case PhotoKind.podcast:
        return Assets.placeholderPodcast;
      case PhotoKind.podcastCategory:
        return Assets.placeholderPodcastCategory;
      case PhotoKind.podcastEpisode:
        return Assets.placeholderPodcastEpisode;
      case PhotoKind.profileCover:
        return Assets.placeholderUserCover;
      case PhotoKind.radioStation:
        return Assets.placeholderRadioStation;
      case PhotoKind.show:
        return Assets.placeholderShow;
      case PhotoKind.skit:
        return Assets.placeholderSkit;
      case PhotoKind.track:
        return Assets.placeholderTrack;
      case PhotoKind.user:
        return Assets.placeholderUser;
    }
  }
}
