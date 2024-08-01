import 'package:kwotdata/kwotdata.dart';

import 'events.dart';

class ShowLikeUpdatedEvent extends Event {
  final String showId;
  final bool disliked;
  final int dislikes;
  final bool liked;
  final int likes;

  ShowLikeUpdatedEvent({
    required this.showId,
    required this.disliked,
    required this.dislikes,
    required this.liked,
    required this.likes,
  }) : super(id: showId);

  Show update(Show show) {
    if (show.id != showId) return show;
    return show.copyWith(
      disliked: disliked,
      dislikes: dislikes,
      liked: liked,
      likes: likes,
    );
  }
}

class ShowReminderUpdatedEvent extends Event {
  final String showId;
  final bool enabled;

  ShowReminderUpdatedEvent({
    required this.showId,
    required this.enabled,
  }) : super(id: showId);

  Show update(Show show) {
    if (show.id != showId) return show;
    return show.copyWith(isReminderEnabled: enabled);
  }
}
