import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/events/events.dart';
import 'package:kwotmusic/features/album/detail/album.model.dart';
import 'package:kwotmusic/l10n/localizations.dart';

class AlbumActionsModel with ChangeNotifier {
  //=

  @override
  void dispose() {
    _toggleLikeOp?.cancel();
    super.dispose();
  }

  String generateAlbumSubtitle(
    BuildContext context, {
    required AlbumSubtitleInfo info,
  }) {
    final localization = LocaleResources.of(context);

    final albumText = localization.album;

    final String durationText;
    if (info.duration.inMinutes == 0 && info.duration.inSeconds != 0) {
      final seconds = info.duration.inSeconds;
      durationText = localization.integerSecondsFormat(seconds);
    } else {
      final minutes = info.duration.inMinutes;
      durationText = localization.integerMinutesCompactFormat(minutes);
    }

    final trackCountText = localization.integerSongCountFormat(info.trackCount);

    return "$albumText · ${info.year} | $durationText · $trackCountText";
  }

  /*
   * API: Like / Unlike Album
   */

  async.CancelableOperation<Result<AlbumLikeStatus>>? _toggleLikeOp;

  Future<Result<AlbumLikeStatus>> toggleLike(Album album) async {
    try {
      // Cancel current operation (if any)
      _toggleLikeOp?.cancel();

      // Create Request
      if (album.liked) {
        final request = UnlikeAlbumRequest(id: album.id);
        _toggleLikeOp = async.CancelableOperation.fromFuture(
          locator<KwotData>().albumsRepository.unlike(request),
        );
      } else {
        final request = LikeAlbumRequest(id: album.id);
        _toggleLikeOp = async.CancelableOperation.fromFuture(
          locator<KwotData>().albumsRepository.like(request),
        );
      }

      // Listen to result
      final result = await _toggleLikeOp!.value;
      if (result.isSuccess() && !result.isEmpty()) {
        final data = result.data();
        final event = AlbumLikeUpdatedEvent(
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
}
