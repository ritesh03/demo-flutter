import 'package:kwotdata/kwotdata.dart';

import 'events.dart';

class TrackLikeUpdatedEvent extends Event {
  TrackLikeUpdatedEvent({
    required this.id,
    required this.liked,
    required this.likes,
  }) : super(id: id);

  final String id;
  final bool liked;
  final int likes;

  Track update(Track track) {
    if (track.id != id) return track;
    return track.copyWith(liked: liked, likes: likes);
  }
}

class TrackDownloadDeletedEvent extends Event {
  TrackDownloadDeletedEvent({
    required this.id,
  }) : super(id: id);

  final String id;
}
