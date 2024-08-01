import 'package:kwotdata/models/models.dart';

abstract class AlbumPageActionCallback {
  void onArtistTap(Artist artist);

  void onBackTap();

  void onDownloadTap();

  void onFollowArtistTap(Artist artist);

  void onLikeTap();

  void onOptionsTap();

  void onReloadAlbumTap();

  void onSeeAllTracksTap();
}
