import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/events/events.dart';

class TrackActionsModel with ChangeNotifier {
  //=

  @override
  void dispose() {
    _toggleLikeOp?.cancel();
    super.dispose();
  }

  /*
   * API: Like / Unlike Track
   */

  async.CancelableOperation<Result<TrackLikeStatus>>? _toggleLikeOp;

  Future<Result<TrackLikeStatus>> toggleLike(Track track) async {
    try {
      // Cancel current operation (if any)
      _toggleLikeOp?.cancel();

      // Create Request
      if (track.liked) {
        final request = UnlikeTrackRequest(id: track.id);
        _toggleLikeOp = async.CancelableOperation.fromFuture(
          locator<KwotData>().tracksRepository.unlike(request),
        );
      } else {
        final request = LikeTrackRequest(id: track.id);
        _toggleLikeOp = async.CancelableOperation.fromFuture(
          locator<KwotData>().tracksRepository.like(request),
        );
      }

      // Listen to result
      final result = await _toggleLikeOp!.value;
      if (result.isSuccess() && !result.isEmpty()) {
        final data = result.data();
        final event = TrackLikeUpdatedEvent(
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
