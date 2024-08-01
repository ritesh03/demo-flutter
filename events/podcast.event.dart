import 'package:kwotdata/kwotdata.dart';

import 'events.dart';

class PodcastLikeUpdatedEvent extends Event {
  final String id;
  final bool liked;
  final int likes;

  PodcastLikeUpdatedEvent({
    required this.id,
    required this.liked,
    required this.likes,
  }) : super(id: id);

  Podcast update(Podcast podcast) {
    if (podcast.id != id) return podcast;
    return podcast.copyWith(liked: liked, likes: likes);
  }
}
