import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/events/events.dart';
import 'package:kwotmusic/l10n/localizations.dart';

import 'detail/playlist.model.dart';

class PlaylistActionsModel with ChangeNotifier {
  //=

  @override
  void dispose() {
    _toggleLikeOp?.cancel();
    super.dispose();
  }

  String generateCompactPlaylistSubtitle(
    BuildContext context, {
    required Duration duration,
    required int trackCount,
  }) {
    final localization = LocaleResources.of(context);

    final String durationText;
    if (duration.inMinutes == 0 && duration.inSeconds != 0) {
      final seconds = duration.inSeconds;
      durationText = localization.integerSecondsFormat(seconds);
    } else {
      final minutes = duration.inMinutes;
      durationText = localization.integerMinutesCompactFormat(minutes);
    }

    final trackCountText = localization.integerSongCountFormat(trackCount);

    return "$durationText · $trackCountText";
  }

  String generatePlaylistSubtitle(
    BuildContext context, {
    required PlaylistSubtitleInfo info,
  }) {
    final localization = LocaleResources.of(context);

    final playlistText = localization.playlist;

    final String durationText;
    if (info.duration.inMinutes == 0 && info.duration.inSeconds != 0) {
      final seconds = info.duration.inSeconds;
      durationText = localization.integerSecondsFormat(seconds);
    } else {
      final minutes = info.duration.inMinutes;
      durationText = localization.integerMinutesCompactFormat(minutes);
    }

    final trackCountText = localization.integerSongCountFormat(info.trackCount);

    return "$playlistText · $durationText | $trackCountText";
  }

  /*
   * API: Like / Unlike Playlist
   */

  async.CancelableOperation<Result<PlaylistLikeStatus>>? _toggleLikeOp;

  Future<Result<PlaylistLikeStatus>> toggleLike(Playlist playlist) async {
    try {
      // Cancel current operation (if any)
      _toggleLikeOp?.cancel();

      // Create Request
      if (playlist.liked) {
        final request = UnlikePlaylistRequest(id: playlist.id);
        _toggleLikeOp = async.CancelableOperation.fromFuture(
          locator<KwotData>().playlistsRepository.unlike(request),
        );
      } else {
        final request = LikePlaylistRequest(id: playlist.id);
        _toggleLikeOp = async.CancelableOperation.fromFuture(
          locator<KwotData>().playlistsRepository.like(request),
        );
      }

      // Listen to result
      final result = await _toggleLikeOp!.value;
      if (result.isSuccess() && !result.isEmpty()) {
        final data = result.data();
        final event = PlaylistLikeUpdatedEvent(
          id: data.id,
          liked: data.liked,
          likes: data.likes,
        );
        eventBus.fire(event);
      }

      return result;
    } catch (error) {
      return Result.error("Error: $error");
    }
  }

  /*
   * API: Add Album to Playlist
   */

  Future<Result> addAlbum({
    required String playlistId,
    required Album album,
  }) async {
    try {
      final request = AddAlbumToPlaylistRequest(
        playlistId: playlistId,
        albumId: album.id,
      );
      final result =
          await locator<KwotData>().playlistsRepository.addAlbum(request);
      if (result.isSuccess() && !result.isEmpty()) {
        final data = result.data();
        final event = PlaylistTracksAddedEvent(
          id: playlistId,
          totalTracks: data.totalTracks,
        );
        eventBus.fire(event);
      }

      return result;
    } catch (error) {
      return Result.error("Error: $error");
    }
  }

  /*
   * API: Add Track to Playlist
   */

  Future<Result> addTrack({
    required String playlistId,
    required Track track,
    bool allowDuplicate = false,
  }) async {
    if (!allowDuplicate) {
      final result =
          await checkTrackExists(playlistId: playlistId, track: track);
      if (!result.isSuccess() || result.isEmpty()) {
        return result;
      }

      final isTrackInPlaylist = result.data();
      if (isTrackInPlaylist) {
        return Result.error(
          "Playlist update failed.",
          errorCode: ErrorCodes.playlistUpdateFailedWhenTrackExists,
        );
      }
    }

    try {
      final request = AddTrackToPlaylistRequest(
        playlistId: playlistId,
        trackId: track.id,
        allowDuplicate: allowDuplicate,
      );
      final result =
          await locator<KwotData>().playlistsRepository.addTrack(request);
      if (result.isSuccess() && !result.isEmpty()) {
        final data = result.data();
        final event = PlaylistTrackAddedEvent(
          playlistId: data.playlistId,
          playlistItemId: data.playlistItemId,
          trackId: track.id,
          track: track,
          totalTracks: data.totalTracks,
        );
        eventBus.fire(event);
      }

      return result;
    } catch (error) {
      return Result.error("Error: $error");
    }
  }

  /*
   * API: Check track exists in Playlist
   */

  Future<Result> checkTrackExists({
    required String playlistId,
    required Track track,
  }) async {
    try {
      final request = CheckTrackExistsInPlaylistRequest(
        playlistId: playlistId,
        trackId: track.id,
      );
      return await locator<KwotData>()
          .playlistsRepository
          .checkTrackExists(request);
    } catch (error) {
      return Result.error("Error: $error");
    }
  }

  /*
   * API: Remove Track from Playlist
   */

  Future<Result> removeTrack({
    required String playlistId,
    required String playlistItemId,
    required String trackId,
  }) async {
    try {
      final request = RemoveTrackFromPlaylistRequest(
        playlistId: playlistId,
        playlistItemId: playlistItemId,
      );
      final result =
          await locator<KwotData>().playlistsRepository.removeTrack(request);
      if (result.isSuccess() && !result.isEmpty()) {
        final data = result.data();
        final event = PlaylistTrackRemovedEvent(
          playlistId: playlistId,
          playlistItemId: playlistItemId,
          trackId: trackId,
          totalTracks: data.totalTracks,
        );
        eventBus.fire(event);
      }

      return result;
    } catch (error) {
      return Result.error("Error: $error");
    }
  }

  Future<Result> undoRemoveTrack({
    required String playlistId,
    required Track track,
  }) async {
    return addTrack(playlistId: playlistId, track: track);
  }

  /*
   * API: Update playlist visibility
   */

  Future<Result<PlaylistVisibility>> updatePlaylistVisibility({
    required String playlistId,
    required bool public,
  }) async {
    try {
      final request =
          UpdatePlaylistVisibilityRequest(id: playlistId, public: public);

      final result = await locator<KwotData>()
          .playlistsRepository
          .updateVisibility(request);
      if (result.isSuccess() && !result.isEmpty()) {
        final data = result.data();
        final event = PlaylistVisibilityUpdatedEvent(
          playlistId: data.id,
          public: data.public,
        );
        eventBus.fire(event);
      }

      return result;
    } catch (error) {
      return Result.error("Error: $error");
    }
  }
}
