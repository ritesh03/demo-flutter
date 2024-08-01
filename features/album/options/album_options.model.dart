import 'dart:async';

import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/events/events.dart';

class AlbumOptionsArgs {
  AlbumOptionsArgs({
    required this.album,
    this.isOnAlbumPage = false,
  });

  final Album album;
  final bool isOnAlbumPage;
}

class AlbumOptionsModel with ChangeNotifier {
  //=

  Album _album;
  final bool _isOnAlbumPage;

  late final StreamSubscription _eventsSubscription;

  AlbumOptionsModel({
    required AlbumOptionsArgs args,
  })  : _album = args.album,
        _isOnAlbumPage = args.isOnAlbumPage {
    _eventsSubscription = _listenToEvents();
  }

  Album get album => _album;

  bool get liked => _album.liked;

  bool get canShowReportAlbumOption => _isOnAlbumPage;

  @override
  void dispose() {
    _eventsSubscription.cancel();
    super.dispose();
  }

  /*
   * EVENT:
   *  AlbumLikeUpdatedEvent
   */

  StreamSubscription _listenToEvents() {
    return eventBus.on().listen((event) {
      if (event is AlbumLikeUpdatedEvent) {
        return _handleAlbumLikeEvent(event);
      }
    });
  }

  void _handleAlbumLikeEvent(AlbumLikeUpdatedEvent event) {
    final album = _album;
    if (album.id == event.id) {
      _album = event.update(album);
      notifyListeners();
    }
  }
}
