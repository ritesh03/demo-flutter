import 'package:kwotdata/models/models.dart';

class PlaylistAddTracksArgs {
  PlaylistAddTracksArgs({
    required this.playlist,
    required this.isOnPlaylistPage,
  });

  final Playlist playlist;
  final bool isOnPlaylistPage;
}
