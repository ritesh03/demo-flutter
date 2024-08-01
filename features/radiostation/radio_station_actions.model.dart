import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/events/events.dart';

class RadioStationActionsModel with ChangeNotifier {
  //=

  @override
  void dispose() {
    _toggleLikeOp?.cancel();
    super.dispose();
  }

  /*
   * API: Like / Unlike Radio Station
   */

  async.CancelableOperation<Result<RadioStationLikeStatus>>? _toggleLikeOp;

  Future<Result<RadioStationLikeStatus>> toggleLike(
      RadioStation radioStation) async {
    try {
      // Cancel current operation (if any)
      _toggleLikeOp?.cancel();

      // Create Request
      final request = UpdateRadioStationLikeRequest(
          radioStationId: radioStation.id, like: !radioStation.liked);
      _toggleLikeOp = async.CancelableOperation.fromFuture(locator<KwotData>()
          .radioStationsRepository
          .updateRadioStationLike(request));
      final result = await _toggleLikeOp!.value;
      if (result.isSuccess() && !result.isEmpty()) {
        final data = result.data();
        final event = RadioStationLikeUpdatedEvent(
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
