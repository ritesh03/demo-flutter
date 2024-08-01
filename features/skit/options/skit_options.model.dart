import 'dart:async';

import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/api/audioplayer.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/events/events.dart';

class SkitOptionsArgs {
  SkitOptionsArgs({
    required this.skit,
    this.playbackItem,
  });

  final Skit skit;
  final PlaybackItem? playbackItem;
}

class SkitOptionsModel with ChangeNotifier {
  //=

  Skit _skit;
  final PlaybackItem? playbackItem;

  late final StreamSubscription _eventsSubscription;

  SkitOptionsModel({
    required SkitOptionsArgs args,
  })  : _skit = args.skit,
        playbackItem = args.playbackItem {
    _eventsSubscription = _listenToEvents();
  }

  @override
  void dispose() {
    _eventsSubscription.cancel();
    super.dispose();
  }

  Skit get skit => _skit;

  bool get isSkitLiked => _skit.liked;

  /*
   * EVENT:
   *  SkitLikeUpdatedEvent,
   */

  StreamSubscription _listenToEvents() {
    return eventBus.on().listen((event) {
      if (event is SkitLikeUpdatedEvent) {
        return _handleSkitLikeEvent(event);
      }
    });
  }

  void _handleSkitLikeEvent(SkitLikeUpdatedEvent event) {
    if (_skit.id == event.skitId) {
      _skit = event.update(_skit);
      notifyListeners();
    }
  }
}
