import 'dart:async';

import 'package:async/async.dart' as async;
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/api/audioplayer.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/events/events.dart';

import 'album.args.dart';

class AlbumModel with ChangeNotifier {
  //=
  final AlbumArgs _args;

  async.CancelableOperation<Result<Album>>? _albumOp;
  Result<Album>? albumResult;

  late final StreamSubscription _eventsSubscription;

  AlbumModel({
    required AlbumArgs args,
  }) : _args = args {
    _eventsSubscription = _listenToEvents();
  }

  void init() {
    fetchAlbum();
  }

  @override
  void dispose() {
    _eventsSubscription.cancel();
    _albumOp?.cancel();
    super.dispose();
  }

  String get albumId => _args.id;

  Album? get album => albumResult?.peek();

  bool get canShowOptions => (album != null);

  bool get canShowPlaybackControls => (album != null);

  String? get albumArtwork {
    if (album != null) {
      return album!.images.isEmpty ? null : album!.images.first;
    }

    return _args.thumbnail;
  }

  String? get albumArtworkCover => albumArtwork;

  String? get albumTitle => album?.title ?? _args.title;

  List<Artist>? get albumArtists => album?.artists;

  List<Feed>? get feeds => album?.feeds;

  bool get liked => album?.liked ?? false;

  List<Track>? get tracks => canShowPlaybackControls ? album?.tracks : null;

  bool get canShowSeeAllSongsOption {
    final album = this.album;
    final tracks = this.tracks;
    if (album == null || tracks == null || tracks.isEmpty) return false;
    return album.trackCount > tracks.length;
  }

  AlbumSubtitleInfo? get albumSubtitleInfo {
    final album = this.album;
    if (album == null) return null;
    if (album.releaseYear == null) return null;
    if (album.duration == null) return null;
    return AlbumSubtitleInfo(
      year: album.releaseYear!,
      duration: album.duration!,
      trackCount: album.trackCount,
    );
  }

  Future<void> fetchAlbum() async {
    try {
      // Cancel current operation (if any)
      _albumOp?.cancel();

      if (albumResult != null) {
        albumResult = null;
        notifyListeners();
      }

      // Create Request
      final request = AlbumRequest(id: _args.id);
      _albumOp = async.CancelableOperation.fromFuture(
          locator<KwotData>().albumsRepository.fetchAlbum(request));

      // Wait for result
      albumResult = await _albumOp?.value;
    } catch (error) {
      albumResult = Result.error("Error: $error");
    }
    notifyListeners();
  }

  PlayTrackRequest createPlayTrackRequest(Track track) {
    return PlayTrackRequest.album(albumId, track: track);
  }

  /*
   * EVENT:
   *  AlbumLikeUpdatedEvent,
   *  ArtistFollowUpdatedEvent,
   *  TrackLikeUpdatedEvent,
   */

  StreamSubscription _listenToEvents() {
    return eventBus.on().listen((event) {
      if (event is AlbumLikeUpdatedEvent) {
        return _handleAlbumLikeUpdatedEvent(event);
      } else if (event is ArtistFollowUpdatedEvent) {
        return _handleArtistFollowEvent(event);
      } else if (event is TrackLikeUpdatedEvent) {
        return _handleTrackLikeEvent(event);
      }
    });
  }

  void _handleAlbumLikeUpdatedEvent(AlbumLikeUpdatedEvent event) {
    final album = this.album;
    if (album == null || album.id != event.id) return;

    albumResult = Result.success(event.update(album));
    notifyListeners();
  }

  void _handleArtistFollowEvent(ArtistFollowUpdatedEvent event) {
    final album = this.album;
    if (album == null) return;

    bool updated = false;
    final updatedArtists = <Artist>[];
    for (final artist in album.artists) {
      if (artist.id == event.artistId) {
        final updatedArtist = event.update(artist);
        updatedArtists.add(updatedArtist);
        updated = true;
      } else {
        updatedArtists.add(artist);
      }
    }

    if (updated) {
      final updatedAlbum = album.copyWith(artists: updatedArtists);
      albumResult = Result.success(updatedAlbum);
      notifyListeners();
    }
  }

  void _handleTrackLikeEvent(TrackLikeUpdatedEvent event) {
    final album = this.album;
    if (album == null) return;

    bool updated = false;
    final albumTracks = album.tracks ?? [];
    final updatedTracks = <Track>[];
    for (final track in albumTracks) {
      if (track.id == event.id) {
        updatedTracks.add(event.update(track));
        updated = true;
      } else {
        updatedTracks.add(track);
      }
    }

    if (updated) {
      final updatedAlbum = album.copyWith(tracks: updatedTracks);
      albumResult = Result.success(updatedAlbum);
      notifyListeners();
    }
  }
}

class AlbumSubtitleInfo extends Equatable {
  const AlbumSubtitleInfo({
    required this.year,
    required this.duration,
    required this.trackCount,
  });

  final String year;
  final Duration duration;
  final int trackCount;

  @override
  List<Object> get props => [year, duration, trackCount];
}
