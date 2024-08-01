import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/events/events.dart';

class PodcastEpisodeActionsModel with ChangeNotifier {
  //=

  @override
  void dispose() {
    _toggleLikeOp?.cancel();
    super.dispose();
  }

  /*
   * API: Set like/unlike for episode
   */

  async.CancelableOperation<Result<PodcastEpisodeLikeStatus>>? _toggleLikeOp;

  Future<Result<PodcastEpisodeLikeStatus>> setIsLiked({
    required String podcastId,
    required String episodeId,
    required bool shouldLike,
  }) async {
    try {
      // Cancel current operation (if any)
      _toggleLikeOp?.cancel();

      // Create Request
      final request = UpdatePodcastEpisodeLikeRequest(
        podcastId: podcastId,
        episodeId: episodeId,
        like: shouldLike,
      );
      _toggleLikeOp = async.CancelableOperation.fromFuture(locator<KwotData>()
          .podcastsRepository
          .updatePodcastEpisodeLike(request));
      final result = await _toggleLikeOp!.value;
      if (result.isSuccess() && !result.isEmpty()) {
        final data = result.data();
        final event = PodcastEpisodeLikeUpdatedEvent(
          episodeId: data.id,
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
