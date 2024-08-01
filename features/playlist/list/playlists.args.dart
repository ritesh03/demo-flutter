import 'package:kwotdata/kwotdata.dart';

class PlaylistsArgs {
  PlaylistsArgs._({
    this.user,
    this.feed,
  });

  PlaylistsArgs.user(User user) : this._(user: user);

  PlaylistsArgs.feed(Feed<Playlist> feed) : this._(feed: feed);

  final User? user;
  final Feed<Playlist>? feed;
}
