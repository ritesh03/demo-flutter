import 'dart:async';

import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/api/audioplayer.dart';
import 'package:kwotdata/api/ext/playlist_ext.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/events/events.dart';
import 'package:kwotmusic/features/downloads/downloads_actions.model.dart';

class TrackOptionsArgs {
  TrackOptionsArgs({
    required this.track,
    this.playbackItem,
    this.album,
    this.playlist,
  });

  final Track track;
  final PlaybackItem? playbackItem;
  final Album? album;
  final Playlist? playlist;
}

class TrackOptionsModel with ChangeNotifier {
  //=

  final TrackOptionsArgs args;
  Track _track;

  late final ValueNotifier<TrackDownloadStatus?> _downloadStatusNotifier;

  late final StreamSubscription _downloadsSubscription;
  late final StreamSubscription _eventsSubscription;

  TrackOptionsModel({
    required this.args,
  }) : _track = args.track {
    _downloadStatusNotifier = ValueNotifier(null);
    _downloadsSubscription = _listenToDownloadsStream();
    _eventsSubscription = _listenToEvents();
  }

  @override
  void dispose() {
    _downloadsSubscription.cancel();
    _downloadStatusNotifier.dispose();
    _eventsSubscription.cancel();
    super.dispose();
  }

  Track get track => _track;

  List<Artist> get artists => _track.artists;

  bool get canShowViewAlbumOption {
    final albumInfo = _track.albumInfo;
    if (albumInfo == null) return false;

    final album = args.album;
    if (album == null) return true;

    return album.id != albumInfo.id;
  }

  ValueNotifier<TrackDownloadStatus?> get downloadStatusNotifier =>
      _downloadStatusNotifier;

  bool get liked => _track.liked;

  bool get isInPlaylist {
    final trackPlaylistId = _track.playlistInfo?.playlistId;
    if (trackPlaylistId == null) return false;

    final receivedPlaylist = args.playlist;
    if (receivedPlaylist == null || receivedPlaylist.id != trackPlaylistId) {
      return false;
    }

    return receivedPlaylist.isOwnedByCurrentUser();
  }

  StreamSubscription _listenToDownloadsStream() {
    return locator<DownloadActionsModel>()
        .downloadsStream
        .listen((downloadsMap) {
      _downloadStatusNotifier.value = downloadsMap[track.id]?.status;
    });
  }

  /*
   * EVENT:
   *  ArtistFollowUpdatedEvent,
   *  TrackLikeUpdatedEvent,
   *  PlaylistTrackRemovedEvent,
   *  PlaylistDeletedEvent,
   */

  StreamSubscription _listenToEvents() {
    return eventBus.on().listen((event) {
      if (event is ArtistFollowUpdatedEvent) {
        return _handleArtistFollowEvent(event);
      } else if (event is TrackLikeUpdatedEvent) {
        return _handleTrackLikeEvent(event);
      } else if (event is PlaylistTrackRemovedEvent) {
        return _handlePlaylistTrackRemovedEvent(event);
      } else if (event is PlaylistDeletedEvent) {
        return _handlePlaylistDeletedEvent(event);
      }
    });
  }

  void _handleArtistFollowEvent(ArtistFollowUpdatedEvent event) {
    final artists = _track.artists.toList();
    final artistIndex =
        artists.indexWhere((element) => element.id == event.artistId);
    if (artistIndex < 0) return;

    artists[artistIndex] = event.update(artists[artistIndex]);
    _track = _track.copyWith(artists: artists);
    notifyListeners();
  }

  void _handleTrackLikeEvent(TrackLikeUpdatedEvent event) {
    if (_track.id == event.id) {
      _track = event.update(_track);
      notifyListeners();
    }
  }

  void _handlePlaylistTrackRemovedEvent(PlaylistTrackRemovedEvent event) {
    final trackPlaylistId = track.playlistInfo?.playlistId;
    if (trackPlaylistId == null) return;
    if (trackPlaylistId != event.playlistId) return;
    if (track.id != event.trackId) return;

    _track = event.update(playlistId: trackPlaylistId, track: _track);
    notifyListeners();
  }

  void _handlePlaylistDeletedEvent(PlaylistDeletedEvent event) {
    final trackPlaylistId = track.playlistInfo?.playlistId;
    if (trackPlaylistId == null) return;
    if (trackPlaylistId != event.playlistId) return;

    _track = event.update(_track);
    notifyListeners();
  }
}
