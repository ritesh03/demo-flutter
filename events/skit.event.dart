import 'package:kwotdata/kwotdata.dart';

import 'events.dart';

class SkitLikeUpdatedEvent extends Event {
  final String skitId;
  final bool disliked;
  final int dislikes;
  final bool liked;
  final int likes;

  SkitLikeUpdatedEvent({
    required this.skitId,
    required this.disliked,
    required this.dislikes,
    required this.liked,
    required this.likes,
  }) : super(id: skitId);

  Skit update(Skit skit) {
    if (skit.id != skitId) return skit;
    return skit.copyWith(
      disliked: disliked,
      dislikes: dislikes,
      liked: liked,
      likes: likes,
    );
  }
}

class SkitCommentAddedEvent extends Event {
  final String skitId;
  final ItemComment comment;

  SkitCommentAddedEvent({
    required this.skitId,
    required this.comment,
  }) : super(id: skitId);
}
