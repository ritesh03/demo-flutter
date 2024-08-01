import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/events/events.dart';

class UserActionsModel with ChangeNotifier {
  //=

  @override
  void dispose() {
    _toggleFollowOp?.cancel();
    super.dispose();
  }

  /*
   * API: Set follow/unfollow for User
   */

  async.CancelableOperation<Result<User>>? _toggleFollowOp;

  Future<Result<User>> setIsFollowed({
    required String id,
    required bool shouldFollow,
  }) async {
    try {
      // Cancel current operation (if any)
      _toggleFollowOp?.cancel();

      // Create Request
      final request = UpdateUserFollowRequest(userId: id, follow: shouldFollow);
      _toggleFollowOp = async.CancelableOperation.fromFuture(
          locator<KwotData>().usersRepository.updateUserFollow(request));
      // Wait for result
      final result = await _toggleFollowOp!.value;
      if (result.isSuccess() && !result.isEmpty()) {
        final data = result.data();
        final event = UserFollowUpdatedEvent(
          userId: data.id,
          followed: data.isFollowed,
          followers: data.followerCount,
        );
        eventBus.fire(event);
      }

      return result;
    } catch (error) {
      return Result.error("Error: $error");
    }
  }

  /*
   * API: Block User
   */

  async.CancelableOperation<Result<User>>? _blockUserOp;

  Future<Result<User>> blockUser({
    required String id,
  }) async {
    try {
      // Cancel current operation (if any)
      _blockUserOp?.cancel();

      // Create Request
      final request = BlockUserRequest(id: id);
      _blockUserOp = async.CancelableOperation.fromFuture(
          locator<KwotData>().usersRepository.blockUser(request));

      // Wait for result
      final result = await _blockUserOp!.value;
      if (result.isSuccess() && !result.isEmpty()) {
        final event = UserBlockUpdatedEvent(user: result.data());
        eventBus.fire(event);
      }

      return result;
    } catch (error) {
      return Result.error("Error: $error");
    }
  }

  /*
   * API: Unblock User
   */

  async.CancelableOperation<Result<User>>? _unblockUserOp;

  Future<Result<User>> unblockUser({
    required String id,
  }) async {
    try {
      // Cancel current operation (if any)
      _unblockUserOp?.cancel();

      // Create Request
      final request = UnblockUserRequest(id: id);
      _unblockUserOp = async.CancelableOperation.fromFuture(
          locator<KwotData>().usersRepository.unblockUser(request));

      // Wait for result
      final result = await _unblockUserOp!.value;
      if (result.isSuccess() && !result.isEmpty()) {
        final event = UserBlockUpdatedEvent(user: result.data());
        eventBus.fire(event);
      }

      return result;
    } catch (error) {
      return Result.error("Error: $error");
    }
  }
}
