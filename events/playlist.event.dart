import 'package:kwotdata/kwotdata.dart';

import 'events.dart';

class PlaylistUpdatedEvent extends Event {
  final Playlist playlist;

  PlaylistUpdatedEvent({
    required this.playlist,
  }) : super(id: playlist.id);

  Playlist update(Playlist playlist) {
    final updatedPlaylist = this.playlist;
    if (playlist.id != updatedPlaylist.id) return playlist;

    return playlist.copyWith(
      name: updatedPlaylist.name,
      description: updatedPlaylist.description,
      images: updatedPlaylist.images,
      public: updatedPlaylist.public,
    );
  }
}

class PlaylistLikeUpdatedEvent extends Event {
  final String id;
  final bool liked;
  final int likes;

  PlaylistLikeUpdatedEvent({
    required this.id,
    required this.liked,
    required this.likes,
  }) : super(id: id);

  Playlist update(Playlist playlist) {
    if (playlist.id != id) return playlist;
    return playlist.copyWith(liked: liked, likes: likes);
  }
}

class PlaylistTrackAddedEvent extends Event {
  final String playlistId;
  final String playlistItemId;
  final String trackId;
  final Track? track;
  final int totalTracks;

  PlaylistTrackAddedEvent({
    required this.playlistId,
    required this.playlistItemId,
    required this.trackId,
    this.track,
    required this.totalTracks,
  }) : super(id: playlistId);

  Track update({
    required String playlistId,
    required Track track,
  }) {
    if (playlistId != this.playlistId) return track;
    if (trackId != track.id) return track;

    final playlistInfo = track.playlistInfo;
    if (playlistInfo != null && playlistInfo.playlistId != playlistId) {
      return track;
    }

    final updatedPlaylistInfo = TrackPlaylistInfo(
      playlistId: playlistId,
      playlistItemId: playlistItemId,
    );
    return track.copyWith(playlistInfo: updatedPlaylistInfo);
  }
}

class PlaylistTracksAddedEvent extends Event {
  final String id;
  final int? totalTracks;

  PlaylistTracksAddedEvent({
    required this.id,
    required this.totalTracks,
  }) : super(id: id);
}

class PlaylistTrackRemovedEvent extends Event {
  final String playlistId;
  final String playlistItemId;
  final String trackId;
  final int totalTracks;

  PlaylistTrackRemovedEvent({
    required this.playlistId,
    required this.playlistItemId,
    required this.trackId,
    required this.totalTracks,
  }) : super(id: playlistItemId);

  Track update({
    required String playlistId,
    required Track track,
  }) {
    if (playlistId != this.playlistId) return track;
    if (track.id != trackId) return track;
    if (track.playlistInfo?.playlistItemId != playlistItemId) return track;

    return track.copyWith(playlistInfo: null);
  }
}

class PlaylistVisibilityUpdatedEvent extends Event {
  final String playlistId;
  final bool public;

  PlaylistVisibilityUpdatedEvent({
    required this.playlistId,
    required this.public,
  }) : super(id: playlistId);

  Playlist update(Playlist playlist) {
    if (playlist.id != playlistId) return playlist;
    return playlist.copyWith(public: public);
  }
}

class PlaylistCollaboratorsCountUpdatedEvent extends Event {
  final String playlistId;
  final int totalCollaborators;

  PlaylistCollaboratorsCountUpdatedEvent({
    required this.playlistId,
    required this.totalCollaborators,
  }) : super(id: playlistId);

  Playlist update(Playlist playlist) {
    if (playlist.id != playlistId) return playlist;
    return playlist.copyWith(totalCollaborators: totalCollaborators);
  }
}

class PlaylistDeletedEvent extends Event {
  final String playlistId;

  PlaylistDeletedEvent({
    required this.playlistId,
  }) : super(id: playlistId);

  Track update(Track track) {
    if (track.playlistInfo?.playlistId != playlistId) return track;
    return track.copyWith(playlistInfo: null);
  }
}
