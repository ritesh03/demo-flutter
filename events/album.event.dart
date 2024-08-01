import 'package:kwotdata/kwotdata.dart';

import 'events.dart';

class AlbumLikeUpdatedEvent extends Event {
  final String id;
  final bool liked;
  final int likes;

  AlbumLikeUpdatedEvent({
    required this.id,
    required this.liked,
    required this.likes,
  }) : super(id: id);

  Album update(Album album) {
    if (album.id != id) return album;
    return album.copyWith(liked: liked, likes: likes);
  }
}
