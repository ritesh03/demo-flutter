import 'dart:async';

import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/events/events.dart';

class ArtistOptionsModel with ChangeNotifier {
  //=

  Artist _artist;

  late final StreamSubscription _eventsSubscription;

  ArtistOptionsModel({
    required Artist artist,
  }) : _artist = artist {
    _eventsSubscription = _listenToEvents();
  }

  @override
  void dispose() {
    _eventsSubscription.cancel();
    super.dispose();
  }

  Artist get artist => _artist;

  /*
   * EVENT: ArtistBlockUpdatedEvent, ArtistFollowUpdatedEvent
   */

  StreamSubscription _listenToEvents() {
    return eventBus.on().listen((event) {
      if (event is ArtistFollowUpdatedEvent) {
        return _handleArtistFollowEvent(event);
      }
    });
  }

  void _handleArtistFollowEvent(ArtistFollowUpdatedEvent event) {
    _artist = event.update(_artist);
    notifyListeners();
  }
}
