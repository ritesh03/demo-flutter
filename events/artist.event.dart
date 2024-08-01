import 'package:kwotdata/kwotdata.dart';

import 'events.dart';

class ArtistFollowUpdatedEvent extends Event {
  final String artistId;
  final bool followed;
  final int followers;

  ArtistFollowUpdatedEvent({
    required this.artistId,
    required this.followed,
    required this.followers,
  }) : super(id: artistId);

  Artist update(Artist artist) {
    if (artist.id != artistId) return artist;
    return artist.copyWith(
      isFollowed: followed,
      followerCount: followers,
    );
  }
}
