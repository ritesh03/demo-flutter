import 'package:kwotdata/kwotdata.dart';

import 'events.dart';

class ShowCommentAddedEvent extends Event {
  final String showId;
  final ItemComment comment;

  ShowCommentAddedEvent({
    required this.showId,
    required this.comment,
  }) : super(id: showId);
}
