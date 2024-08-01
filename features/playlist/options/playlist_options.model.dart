import 'dart:async';

import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotdata/api/ext/playlist_ext.dart';
import 'package:kwotmusic/events/events.dart';

class PlaylistOptionsArgs {
  PlaylistOptionsArgs({
    required this.playlist,
    this.isOnPlaylistPage = false,
  });

  final Playlist playlist;
  final bool isOnPlaylistPage;
}

class PlaylistOptionsModel with ChangeNotifier {
  //=

  Playlist _playlist;
  final bool _isOnPlaylistPage;
  late bool _isPlaylistOwnedByCurrentUser;

  late final StreamSubscription _eventsSubscription;

  PlaylistOptionsModel({
    required PlaylistOptionsArgs args,
  })  : _playlist = args.playlist,
        _isOnPlaylistPage = args.isOnPlaylistPage {
    _isPlaylistOwnedByCurrentUser = playlist.isOwnedByCurrentUser();
    _eventsSubscription = _listenToEvents();
  }

  Playlist get playlist => _playlist;

  bool get _canEditItems =>
      _isPlaylistOwnedByCurrentUser ||
      (_playlist.capabilities?.canEditItems ?? false);

  bool get isOnPlaylistPage => _isOnPlaylistPage;

  bool get liked => _playlist.liked;

  bool get canShowLikeOption => !_isPlaylistOwnedByCurrentUser;

  bool get canShowVisibilityOption => _isPlaylistOwnedByCurrentUser;

  bool get canShowAddSongsOption => _canEditItems;

  bool get canShowInviteOption => _isPlaylistOwnedByCurrentUser;

  bool get canShowManageCollaboratorsOption => _isPlaylistOwnedByCurrentUser;

  bool get canShowEditOption => _isPlaylistOwnedByCurrentUser;

  bool get canShowReportPlaylistOption =>
      _isOnPlaylistPage && !_isPlaylistOwnedByCurrentUser;

  @override
  void dispose() {
    _eventsSubscription.cancel();
    super.dispose();
  }

  /*
   * EVENT:
   *  PlaylistLikeUpdatedEvent
   */

  StreamSubscription _listenToEvents() {
    return eventBus.on().listen((event) {
      if (event is PlaylistLikeUpdatedEvent) {
        return _handlePlaylistLikeEvent(event);
      }
    });
  }

  void _handlePlaylistLikeEvent(PlaylistLikeUpdatedEvent event) {
    final playlist = _playlist;
    if (playlist.id == event.id) {
      _playlist = event.update(playlist);
      notifyListeners();
    }
  }
}
