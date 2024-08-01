import 'package:kwotdata/models/models.dart';

abstract class PlaylistsPageActionCallback {

  void onBackTap();

  void onCreatePlaylistTap();

  void onPlaylistTap(Playlist playlist);
}
