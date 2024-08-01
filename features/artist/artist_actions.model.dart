import 'package:async/async.dart' as async;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/events/events.dart';

class ArtistActionsModel {
  /*
   * API: Set follow/unfollow for Artist
   */

  async.CancelableOperation<Result<Artist>>? _toggleFollowOp;

  Future<Result<Artist>> setIsFollowed({
    required String id,
    required bool shouldFollow,
  }) async {
    try {
      // Cancel current operation (if any)
      _toggleFollowOp?.cancel();

      // Create Request
      final request = UpdateArtistFollowRequest(artistId: id, follow: shouldFollow);
      _toggleFollowOp = async.CancelableOperation.fromFuture(
        locator.get<KwotData>().artistsRepository.updateArtistFollow(request),
      );

      // Wait for result
      final result = await _toggleFollowOp!.value;
      if (result.isSuccess() && !result.isEmpty()) {
        final data = result.data();
        final event = ArtistFollowUpdatedEvent(
            artistId: data.id,
            followed: data.isFollowed,
            followers: data.followerCount);
        eventBus.fire(event);
      }

      return result;
    } catch (error) {
      return Result.error("Error: $error");
    }
  }
}
