import 'dart:async';

import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/events/events.dart';

class UserOptionsModel with ChangeNotifier {
  //=

  User _user;

  late final StreamSubscription _eventsSubscription;

  UserOptionsModel({
    required User user,
  }) : _user = user {
    _eventsSubscription = _listenToEvents();
  }

  @override
  void dispose() {
    _eventsSubscription.cancel();
    super.dispose();
  }

  User get user => _user;

  bool get isBlocked => _user.isBlocked;

  bool get canShowShareOption => !isBlocked;

  bool get canShowReportOption => !isBlocked;

  /*
   * EVENT: UserBlockUpdatedEvent
   */

  StreamSubscription _listenToEvents() {
    return eventBus.on().listen((event) {
      if (event is UserBlockUpdatedEvent) {
        return _handleUserBlockEvent(event);
      }
    });
  }

  void _handleUserBlockEvent(UserBlockUpdatedEvent event) {
    if (user.id == event.userId) {
      _user = event.update(_user);
      notifyListeners();
    }
  }
}
