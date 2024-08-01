import 'package:kwotdata/api/audioplayer.dart';

import 'events.dart';

class PlayingQueueItemRemovedEvent extends Event {
  PlayingQueueItemRemovedEvent({
    required this.item,
  }) : super(id: item.playbackId);

  final PlaybackItem item;
}
