import 'dart:async';

import 'package:async/async.dart' as async;
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/api/audioplayer.dart';
import 'package:kwotdata/api/ext/playlist_ext.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/events/events.dart';

import 'playlist.args.dart';

class PlaylistModel with ChangeNotifier {
  //=
  final PlaylistArgs _args;

  async.CancelableOperation<Result<Playlist>>? _playlistOp;
  Result<Playlist>? playlistResult;

  async.CancelableOperation<Result<ListPage<Track>>>? _playlistTracksOp;
  Result<ListPage<Track>>? _playlistTracksResult;
  PlaylistTracksFilter tracksFilter = PlaylistTracksFilter(query: null);

  late final StreamSubscription _eventsSubscription;

  PlaylistModel({
    required PlaylistArgs args,
  }) : _args = args {
    _eventsSubscription = _listenToEvents();
  }

  void init() {
    fetchPlaylist();
  }

  @override
  void dispose() {
    _eventsSubscription.cancel();
    _playlistTracksOp?.cancel();
    _playlistOp?.cancel();
    super.dispose();
  }

  String get playlistId => _args.id;

  Playlist? get playlist => playlistResult?.peek();

  bool get _isOwnedByMe => playlist?.isOwnedByCurrentUser() ?? false;

  bool get _canEditItems =>
      _isOwnedByMe || (playlist?.capabilities?.canEditItems ?? false);

  bool get canShowOptions => (playlist != null);

  bool get canShowLikeOption => canShowOptions && !_isOwnedByMe;

  bool get canShowVisibilityOption => canShowOptions && _isOwnedByMe;

  bool get canShowPlaybackControls => (playlist != null);

  String? get playlistArtwork {
    if (playlist != null) {
      return playlist!.images.isEmpty ? null : playlist!.images.first;
    }

    return _args.thumbnail;
  }

  String? get playlistArtworkCover => playlistArtwork;

  String? get playlistTitle => playlist?.name ?? _args.title;

  User? get playlistOwner => _isOwnedByMe ? null : playlist?.owner;

  bool get public => playlist?.public ?? false;

  bool get isAddedAsCollaborator => !_isOwnedByMe && _canEditItems;

  bool get canShowAddTracksOption => _canEditItems;

  int? get sharedWithCollaboratorsCount {
    if (!_isOwnedByMe) return null;
    final total = playlist?.totalCollaborators ?? 0;
    if (total < 1) return null;
    return total;
  }

  List<Feed>? get feeds {
    if (_playlistTracksResult == null || !_playlistTracksResult!.isSuccess()) {
      return null;
    }
    return playlist?.feeds;
  }

  bool get liked => playlist?.liked ?? false;

  // List<Track>? get tracks => canShowPlaybackControls ? playlist?.tracks : null;

  bool get canShowSeeAllSongsOption {
    final tracksResult = _playlistTracksResult;
    final tracksPage = tracksResult?.peek();
    if (playlist == null || tracksPage == null || tracksPage.isEmpty) {
      return false;
    }
    return (playlist?.totalTracks ??0) > (tracksPage.items?.length??0);
  }

  PlaylistSubtitleInfo? get playlistSubtitleInfo {
    final playlist = this.playlist;
    if (playlist == null) return null;
    return PlaylistSubtitleInfo(
      duration: playlist.duration,
      trackCount: playlist.totalTracks,
    );
  }

  Future<void> fetchPlaylist() async {
    try {
      // Cancel current operation (if any)
      _playlistOp?.cancel();

      if (playlistResult != null || _playlistTracksResult != null) {
        playlistResult = null;
        _playlistTracksResult = null;
        notifyListeners();
      }

      // Create Request
      final request = PlaylistRequest(id: _args.id);
      _playlistOp = async.CancelableOperation.fromFuture(
          locator<KwotData>().playlistsRepository.fetchPlaylist(request));

      // Wait for result
      playlistResult = await _playlistOp?.value;

      tracksFilter = PlaylistTracksFilter(query: null);
      fetchPlaylistTracks();
    } catch (error) {
      playlistResult = Result.error("Error: $error");
    }
    notifyListeners();
  }

  PlayTrackRequest createPlayTrackRequest(Track track) {
    return PlayTrackRequest.playlist(playlistId,
        track: track,
        query: tracksSearchQuery,
        playlistTrackSortBy: tracksSortBy);
  }

  /*
   * SEARCH, SORT, FETCH PLAYLIST TRACKS
   */

  Result<ListPage<Track>>? get tracksResult => _playlistTracksResult;

  String? get tracksSearchQuery => tracksFilter.query;

  bool get hasTracksSearchQuery => tracksFilter.hasSearchQuery;

  PlaylistTrackSortBy get tracksSortBy => tracksFilter.sortBy;

  bool get tracksFiltered =>
      tracksFilter.sortBy != PlaylistTrackSortBy.recentlyAdded;

  void updateTracksSearchQuery(String text) {
    if (tracksSearchQuery != text) {
      tracksFilter = tracksFilter.copyWithQuery(query: text);
      fetchPlaylistTracks();
    }
  }

  void clearTracksSearchQuery() {
    if (tracksSearchQuery != null) {
      tracksFilter = tracksFilter.copyWithQuery(query: null);
      fetchPlaylistTracks();
    }
  }

  void setTracksSortBy(PlaylistTrackSortBy sortBy) {
    if (sortBy == tracksFilter.sortBy) {
      return;
    }

    tracksFilter = tracksFilter.copyWithSortBy(sortBy: sortBy);
    fetchPlaylistTracks();
  }

  Future<void> fetchPlaylistTracks() async {
    try {
      // Cancel current operation (if any)
      _playlistTracksOp?.cancel();

      if (_playlistTracksResult != null) {
        _playlistTracksResult = null;
        notifyListeners();
      }

      // Create Request
      final request = PlaylistTracksRequest(
        page: 1,
        playlistId: playlistId,
        query: tracksFilter.query,
        sortBy: tracksFilter.sortBy,
      );
      _playlistTracksOp = async.CancelableOperation.fromFuture(
          locator<KwotData>().playlistsRepository.fetchPlaylistTracks(request));

      // Wait for result
      _playlistTracksResult = await _playlistTracksOp?.value;
    } catch (error) {
      _playlistTracksResult = Result.error("Error: $error");
    }
    notifyListeners();
  }

  /*
   * EVENT:
   *  PlaylistLikeUpdatedEvent,
   *  PlaylistVisibilityUpdatedEvent
   *  PlaylistCollaboratorsCountUpdatedEvent
   *  PlaylistTrackAddedEvent
   *  PlaylistTracksAddedEvent
   *  PlaylistTrackRemovedEvent,
   *  PlaylistUpdatedEvent,
   *  PlaylistDeletedEvent,
   *  UserFollowUpdatedEvent,
   *  TrackLikeUpdatedEvent,
   */

  StreamSubscription _listenToEvents() {
    return eventBus.on().listen((event) {
      if (event is PlaylistLikeUpdatedEvent) {
        return _handlePlaylistLikeUpdatedEvent(event);
      } else if (event is PlaylistVisibilityUpdatedEvent) {
        return _handlePlaylistVisibilityUpdatedEvent(event);
      } else if (event is PlaylistCollaboratorsCountUpdatedEvent) {
        return _handlePlaylistCollaboratorsCountUpdatedEvent(event);
      } else if (event is PlaylistTrackAddedEvent) {
        return _handlePlaylistTrackAddedEvent(event);
      } else if (event is PlaylistTracksAddedEvent) {
        return _handlePlaylistTracksAddedEvent(event);
      } else if (event is PlaylistTrackRemovedEvent) {
        return _handlePlaylistTrackRemovedEvent(event);
      } else if (event is PlaylistUpdatedEvent) {
        return _handlePlaylistUpdatedEvent(event);
      } else if (event is PlaylistDeletedEvent) {
        return _handlePlaylistDeletedEvent(event);
      } else if (event is UserBlockUpdatedEvent) {
        return _handleUserBlockEvent(event);
      } else if (event is UserFollowUpdatedEvent) {
        return _handleUserFollowEvent(event);
      } else if (event is TrackLikeUpdatedEvent) {
        return _handleTrackLikeEvent(event);
      }
    });
  }

  void _handlePlaylistLikeUpdatedEvent(PlaylistLikeUpdatedEvent event) {
    final playlist = this.playlist;
    if (playlist == null || playlist.id != event.id) return;

    playlistResult = Result.success(event.update(playlist));
    notifyListeners();
  }

  void _handlePlaylistVisibilityUpdatedEvent(
      PlaylistVisibilityUpdatedEvent event) {
    final playlist = this.playlist;
    if (playlist == null || playlist.id != event.playlistId) return;

    playlistResult = Result.success(event.update(playlist));
    notifyListeners();
  }

  void _handlePlaylistCollaboratorsCountUpdatedEvent(
    PlaylistCollaboratorsCountUpdatedEvent event,
  ) {
    final playlist = this.playlist;
    if (playlist == null || playlist.id != event.playlistId) return;

    playlistResult = Result.success(event.update(playlist));
    notifyListeners();
  }

  void _handlePlaylistTrackAddedEvent(PlaylistTrackAddedEvent event) {
    final playlist = this.playlist;
    if (playlist == null || playlist.id != event.playlistId) return;

    if (event.totalTracks != playlist.totalTracks) {
      playlistResult = Result.success(
        playlist.copyWith(totalTracks: event.totalTracks),
      );
      notifyListeners();
    }

    final tracksResult = _playlistTracksResult;
    if (tracksResult == null ||
        !tracksResult.isSuccess() ||
        tracksResult.isEmpty()) {
      fetchPlaylistTracks();
      return;
    }

    final tracksPage = tracksResult.data();
    final tracks = tracksPage.items;
    if(tracks != null) {
      if (tracks.isEmpty) {
        fetchPlaylistTracks();
        return;
      }
    }

    final addedTrack = event.track;
    if (addedTrack == null) return;

    final updatedTracks = tracks?.toList()??[]
      ..insert(
        0,
        event.update(playlistId: playlist.id, track: addedTrack),
      );
    _playlistTracksResult = Result.success(
      ListPage(items: updatedTracks, totalItems: event.totalTracks),
    );
    notifyListeners();
  }

  void _handlePlaylistTracksAddedEvent(PlaylistTracksAddedEvent event) {
    final playlist = this.playlist;
    if (playlist == null || playlist.id != event.id) return;

    if (event.totalTracks != null &&
        event.totalTracks != playlist.totalTracks) {
      playlistResult = Result.success(
        playlist.copyWith(totalTracks: event.totalTracks!),
      );
    }

    fetchPlaylistTracks();
    notifyListeners();
  }

  void _handlePlaylistTrackRemovedEvent(PlaylistTrackRemovedEvent event) {
    final playlist = this.playlist;
    if (playlist == null || playlist.id != event.playlistId) return;

    if (event.totalTracks != playlist.totalTracks) {
      playlistResult = Result.success(
        playlist.copyWith(totalTracks: event.totalTracks),
      );
      notifyListeners();
    }

    final tracksResult = _playlistTracksResult;
    if (tracksResult == null ||
        !tracksResult.isSuccess() ||
        tracksResult.isEmpty()) {
      fetchPlaylistTracks();
      return;
    }

    final tracksPage = tracksResult.data();
    final tracks = tracksPage.items;
    if(tracks != null) {
      if (tracks.isEmpty) {
        fetchPlaylistTracks();
        return;
      }
    }
    if(tracks != null) {
      if (tracks.length == 1) {
        final firstTrack = tracks.first;
        if (firstTrack.id == event.trackId) {
          fetchPlaylistTracks();
        }

        return;
      }
    }

    final playlistItemIndex = (tracks??[]).indexWhere(
        (track) => track.playlistInfo?.playlistItemId == event.playlistItemId);
    if (playlistItemIndex == -1) {
      return;
    }

    final updatedTracks = (tracks?.toList()??[])..removeAt(playlistItemIndex);
    _playlistTracksResult = Result.success(
      ListPage(items: updatedTracks, totalItems: event.totalTracks),
    );
    notifyListeners();
  }

  void _handlePlaylistUpdatedEvent(PlaylistUpdatedEvent event) {
    final playlist = this.playlist;
    if (playlist == null || playlist.id != event.playlist.id) return;

    fetchPlaylist();
  }

  void _handlePlaylistDeletedEvent(PlaylistDeletedEvent event) {
    final playlist = this.playlist;
    if (playlist == null || playlist.id != event.playlistId) return;

    fetchPlaylist();
  }

  void _handleUserBlockEvent(UserBlockUpdatedEvent event) {
    final playlist = this.playlist;
    if (playlist == null || event.userId != playlist.owner.id) return;

    final updatedOwner = event.update(playlist.owner);
    final updatedPlaylist = playlist.copyWith(owner: updatedOwner);
    playlistResult = Result.success(updatedPlaylist);
    notifyListeners();
  }

  void _handleUserFollowEvent(UserFollowUpdatedEvent event) {
    final playlist = this.playlist;
    if (playlist == null || event.userId != playlist.owner.id) return;

    final updatedOwner = event.update(playlist.owner);
    final updatedPlaylist = playlist.copyWith(owner: updatedOwner);
    playlistResult = Result.success(updatedPlaylist);
    notifyListeners();
  }

  void _handleTrackLikeEvent(TrackLikeUpdatedEvent event) {
    final playlist = this.playlist;
    if (playlist == null) return;

    bool updated = false;
    final playlistTracks = playlist.tracks ?? [];
    final updatedTracks = <Track>[];
    for (final track in playlistTracks) {
      if (track.id == event.id) {
        updatedTracks.add(event.update(track));
        updated = true;
      } else {
        updatedTracks.add(track);
      }
    }

    if (updated) {
      final updatedPlaylist = playlist.copyWith(tracks: updatedTracks);
      playlistResult = Result.success(updatedPlaylist);
      notifyListeners();
    }
  }
}

class PlaylistSubtitleInfo extends Equatable {
  const PlaylistSubtitleInfo({
    required this.duration,
    required this.trackCount,
  });

  final Duration duration;
  final int trackCount;

  @override
  List<Object> get props => [duration, trackCount];
}
