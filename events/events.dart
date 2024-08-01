import 'package:event_bus/event_bus.dart';

export 'album.event.dart';
export 'artist.event.dart';
export 'auth.event.dart';
export 'comment.event.dart';
export 'playing_queue.event.dart';
export 'playlist.event.dart';
export 'podcast.event.dart';
export 'podcast_episode.event.dart';
export 'profile.event.dart';
export 'radiostation.event.dart';
export 'search.event.dart';
export 'show.event.dart';
export 'skit.event.dart';
export 'track.event.dart';
export 'user.event.dart';

EventBus eventBus = EventBus();

class Event {
  Event({required String id}) : identifier = id;

  final String identifier;
}
