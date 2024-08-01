import 'package:kwotdata/kwotdata.dart';

class TrackListArgs {
  TrackListArgs({
    this.availableFeed,
    this.albumId,
    this.genres,
  });

  final Feed<Track>? availableFeed;
  final String? albumId;
  final List<MusicGenre>? genres;
}
