import 'package:kwotdata/kwotdata.dart';

import 'events.dart';

class PodcastEpisodeLikeUpdatedEvent extends Event {
  final String episodeId;
  final bool liked;
  final int likes;

  PodcastEpisodeLikeUpdatedEvent({
    required this.episodeId,
    required this.liked,
    required this.likes,
  }) : super(id: episodeId);

  PodcastEpisode update(PodcastEpisode episode) {
    if (episode.id != episodeId) return episode;
    return episode.copyWith(liked: liked, likes: likes);
  }
}
