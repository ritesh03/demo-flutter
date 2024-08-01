import 'package:kwotdata/kwotdata.dart';

class PlaylistTracksArgs {
  PlaylistTracksArgs({
    required this.playlist,
    this.searchQuery,
    this.sortBy,
  });

  final Playlist playlist;
  final String? searchQuery;
  final PlaylistTrackSortBy? sortBy;
}
