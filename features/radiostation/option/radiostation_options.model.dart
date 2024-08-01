import 'dart:async';

import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/api/audioplayer.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/events/events.dart';

class RadioStationOptionsModel with ChangeNotifier {
  //=

  RadioStation _radioStation;
  final PlaybackItem? playbackItem;

  late final StreamSubscription _eventsSubscription;

  RadioStationOptionsModel({
    required RadioStation radioStation,
    this.playbackItem,
  }) : _radioStation = radioStation {
    _eventsSubscription = _listenToEvents();
  }

  @override
  void dispose() {
    _eventsSubscription.cancel();
    super.dispose();
  }

  RadioStation get radioStation => _radioStation;

  String get title => _radioStation.title;

  bool get liked => _radioStation.liked;

  /*
   * EVENT:
   *  RadioStationLikeUpdatedEvent
   */

  StreamSubscription _listenToEvents() {
    return eventBus.on().listen((event) {
      if (event is RadioStationLikeUpdatedEvent) {
        return _handleRadioStationLikeEvent(event);
      }
    });
  }

  void _handleRadioStationLikeEvent(RadioStationLikeUpdatedEvent event) {
    if (_radioStation.id == event.id) {
      _radioStation = event.update(_radioStation);
      notifyListeners();
    }
  }
}
