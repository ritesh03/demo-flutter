import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/events/events.dart';

class ShowActionsModel with ChangeNotifier {
  //=

  @override
  void dispose() {
    _updateReminderOp?.cancel();
    super.dispose();
  }

  /*
   * API: Like/Unlike a Show
   */

  async.CancelableOperation<Result<ShowLikeUpdateResponse>>? _showLikeUpdateOp;

  Future<Result<ShowLikeUpdateResponse>> toggleShowLike({
    required String id,
    required bool liked,
  }) {
    if (liked) {
      return unlikeShow(id: id);
    } else {
      return likeShow(id: id);
    }
  }

  Future<Result<ShowLikeUpdateResponse>> likeShow({
    required String id,
  }) async {
    try {
      // Cancel current operation (if any)
      _showLikeUpdateOp?.cancel();

      // Create Request
      final request = LikeShowRequest(id: id);
      _showLikeUpdateOp = async.CancelableOperation.fromFuture(
          locator<KwotData>().showsRepository.likeShow(request));

      // Wait for result
      final result = await _showLikeUpdateOp!.value;
      if (result.isSuccess() && !result.isEmpty()) {
        final response = result.data();
        final event = ShowLikeUpdatedEvent(
          showId: response.id,
          disliked: response.disliked,
          dislikes: response.dislikes,
          liked: response.liked,
          likes: response.likes,
        );
        eventBus.fire(event);
      }

      return result;
    } catch (error) {
      return Result.error("Error: $error");
    }
  }

  Future<Result<ShowLikeUpdateResponse>> unlikeShow({
    required String id,
  }) async {
    try {
      // Cancel current operation (if any)
      _showLikeUpdateOp?.cancel();

      // Create Request
      final request = UnlikeShowRequest(id: id);
      _showLikeUpdateOp = async.CancelableOperation.fromFuture(
          locator<KwotData>().showsRepository.unlikeShow(request));

      // Wait for result
      final result = await _showLikeUpdateOp!.value;
      if (result.isSuccess() && !result.isEmpty()) {
        final response = result.data();
        final event = ShowLikeUpdatedEvent(
          showId: response.id,
          disliked: response.disliked,
          dislikes: response.dislikes,
          liked: response.liked,
          likes: response.likes,
        );
        eventBus.fire(event);
      }

      return result;
    } catch (error) {
      return Result.error("Error: $error");
    }
  }

  /*
   * API: Dislike or Undo Dislike a Show
   */

  async.CancelableOperation<Result<ShowLikeUpdateResponse>>?
      _showDislikeUpdateOp;

  Future<Result<ShowLikeUpdateResponse>> toggleShowDislike({
    required String id,
    required bool disliked,
  }) {
    if (disliked) {
      return undoDislikeShow(id: id);
    } else {
      return dislikeShow(id: id);
    }
  }

  Future<Result<ShowLikeUpdateResponse>> dislikeShow({
    required String id,
  }) async {
    try {
      // Cancel current operation (if any)
      _showDislikeUpdateOp?.cancel();

      // Create Request
      final request = DislikeShowRequest(id: id);
      _showDislikeUpdateOp = async.CancelableOperation.fromFuture(
          locator<KwotData>().showsRepository.dislikeShow(request));

      // Wait for result
      final result = await _showDislikeUpdateOp!.value;
      if (result.isSuccess() && !result.isEmpty()) {
        final response = result.data();
        final event = ShowLikeUpdatedEvent(
          showId: response.id,
          disliked: response.disliked,
          dislikes: response.dislikes,
          liked: response.liked,
          likes: response.likes,
        );
        eventBus.fire(event);
      }

      return result;
    } catch (error) {
      return Result.error("Error: $error");
    }
  }

  Future<Result<ShowLikeUpdateResponse>> undoDislikeShow({
    required String id,
  }) async {
    try {
      // Cancel current operation (if any)
      _showDislikeUpdateOp?.cancel();

      // Create Request
      final request = UndoDislikeShowRequest(id: id);
      _showDislikeUpdateOp = async.CancelableOperation.fromFuture(
          locator<KwotData>().showsRepository.undoDislikeShow(request));

      // Wait for result
      final result = await _showDislikeUpdateOp!.value;
      if (result.isSuccess() && !result.isEmpty()) {
        final response = result.data();
        final event = ShowLikeUpdatedEvent(
          showId: response.id,
          disliked: response.disliked,
          dislikes: response.dislikes,
          liked: response.liked,
          likes: response.likes,
        );
        eventBus.fire(event);
      }

      return result;
    } catch (error) {
      return Result.error("Error: $error");
    }
  }

  /*
   * API: Set/unset reminder for a Show
   */

  async.CancelableOperation<Result<ShowReminderUpdateResponse>>?
      _updateReminderOp;

  Future<Result<bool>> setIsReminderEnabled({
    required String id,
    required bool shouldEnable,
  }) async {
    try {
      // Cancel current operation (if any)
      _updateReminderOp?.cancel();

      // Create Request
      final request =
          UpdateShowReminderRequest(showId: id, enable: shouldEnable);
      _updateReminderOp = async.CancelableOperation.fromFuture(
          locator<KwotData>().showsRepository.updateShowReminder(request));

      // Wait for result
      final result = await _updateReminderOp!.value;
      if (result.isSuccess() && !result.isEmpty()) {
        final response = result.data();
        final event = ShowReminderUpdatedEvent(
          showId: response.showId,
          enabled: response.enabled,
        );
        eventBus.fire(event);
      }

      return result.map((data) => data.enabled);
    } catch (error) {
      return Result.error("Error: $error");
    }
  }

  /*
   * API: Add comment
   */

  async.CancelableOperation<Result<ItemComment>>? _addCommentOp;

  Future<Result<bool>> addTextComment({
    required String showId,
    required String text,
  }) async {
    try {
      // Cancel current operation (if any)
      _addCommentOp?.cancel();

      // Create Request
      final request = AddShowCommentRequest(showId: showId, commentText: text);
      _addCommentOp = async.CancelableOperation.fromFuture(
          locator<KwotData>().showsRepository.addShowComment(request));

      // Wait for result
      final result = await _addCommentOp!.value;
      if (result.isSuccess() && !result.isEmpty()) {
        final addedComment = result.data();
        final event = ShowCommentAddedEvent(
          showId: addedComment.parentId,
          comment: addedComment,
        );
        eventBus.fire(event);
      }

      return result.map((data) => result.isSuccess());
    } catch (error) {
      return Result.error("Error: $error");
    }
  }

  /*
   * API: Add live chat comment
   */

  async.CancelableOperation<Result<ItemComment>>? _addLiveChatCommentOp;

  Future<Result<bool>> addLiveChatTextComment({
    required String showId,
    required String text,
  }) async {
    try {
      // Cancel current operation (if any)
      _addLiveChatCommentOp?.cancel();

      // Create Request
      final request =
          AddShowLiveChatCommentRequest(showId: showId, commentText: text);
      _addLiveChatCommentOp = async.CancelableOperation.fromFuture(
          locator<KwotData>().showsRepository.addShowLiveChatComment(request));

      // Wait for result
      final result = await _addLiveChatCommentOp!.value;
      return result.map((data) => result.isSuccess());
    } catch (error) {
      return Result.error("Error: $error");
    }
  }
}
