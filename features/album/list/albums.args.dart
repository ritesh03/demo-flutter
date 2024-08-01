import 'package:kwotdata/kwotdata.dart';

class AlbumsListArgs {
  AlbumsListArgs({
    this.availableFeed,
    this.genres,
  });

  final Feed<Album>? availableFeed;
  final List<MusicGenre>? genres;
}
