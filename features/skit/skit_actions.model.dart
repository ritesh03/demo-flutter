import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/events/events.dart';
import 'package:kwotmusic/l10n/localizations.dart';

class SkitActionsModel {
  /*
   *
   * LOGIC: Get displayable name for [SkitType]
   */

  String getSkitTypeText(
    BuildContext context, {
    required SkitType type,
    bool plural = false,
  }) {
    final localization = LocaleResources.of(context);
    switch (type) {
      case SkitType.audio:
        return plural
            ? localization.skitsTypeAudio
            : localization.skitTypeAudio;
      case SkitType.video:
        return plural
            ? localization.skitsTypeVideo
            : localization.skitTypeVideo;
    }
  }

  /*
   * LOGIC: Get displayable name for [SkitSortOrder]
   */

  String getSkitSortOrderText(BuildContext context, SkitSortOrder sortOrder) {
    final localization = LocaleResources.of(context);
    switch (sortOrder) {
      case SkitSortOrder.newestToOldest:
        return localization.newestToOldestSortOption;
      case SkitSortOrder.oldestToNewest:
        return localization.oldestToNewestSortOption;
      case SkitSortOrder.mostPopularFirst:
        return localization.mostPopularFirstSortOption;
    }
  }

  /*
   * API: Like/Unlike Skit
   */

  async.CancelableOperation<Result<SkitLikeUpdateResponse>>? _updateSkitLikeOp;

  Future<Result<SkitLikeUpdateResponse>> toggleSkitLike({
    required String id,
    required bool liked,
  }) {
    if (liked) {
      return unlikeSkit(id: id);
    } else {
      return likeSkit(id: id);
    }
  }

  Future<Result<SkitLikeUpdateResponse>> likeSkit({
    required String id,
  }) async {
    try {
      // Cancel current operation (if any)
      _updateSkitLikeOp?.cancel();

      // Create Request
      final request = LikeSkitRequest(id: id);
      _updateSkitLikeOp = async.CancelableOperation.fromFuture(
          locator<KwotData>().skitsRepository.likeSkit(request));

      // Wait for result
      final result = await _updateSkitLikeOp!.value;
      if (result.isSuccess() && !result.isEmpty()) {
        final response = result.data();
        final event = SkitLikeUpdatedEvent(
          skitId: response.id,
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

  Future<Result<SkitLikeUpdateResponse>> unlikeSkit({
    required String id,
  }) async {
    try {
      // Cancel current operation (if any)
      _updateSkitLikeOp?.cancel();

      // Create Request
      final request = UnlikeSkitRequest(id: id);
      _updateSkitLikeOp = async.CancelableOperation.fromFuture(
          locator<KwotData>().skitsRepository.unlikeSkit(request));

      // Wait for result
      final result = await _updateSkitLikeOp!.value;
      if (result.isSuccess() && !result.isEmpty()) {
        final response = result.data();
        final event = SkitLikeUpdatedEvent(
          skitId: response.id,
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
   * API: Dislike or Undo Dislike a Skit
   */

  async.CancelableOperation<Result<SkitLikeUpdateResponse>>?
      _updateSkitDislikeOp;

  Future<Result<SkitLikeUpdateResponse>> toggleSkitDislike({
    required String id,
    required bool disliked,
  }) {
    if (disliked) {
      return undoDislikeSkit(id: id);
    } else {
      return dislikeSkit(id: id);
    }
  }

  Future<Result<SkitLikeUpdateResponse>> dislikeSkit({
    required String id,
  }) async {
    try {
      // Cancel current operation (if any)
      _updateSkitDislikeOp?.cancel();

      // Create Request
      final request = DislikeSkitRequest(id: id);
      _updateSkitDislikeOp = async.CancelableOperation.fromFuture(
          locator<KwotData>().skitsRepository.dislikeSkit(request));

      // Wait for result
      final result = await _updateSkitDislikeOp!.value;
      if (result.isSuccess() && !result.isEmpty()) {
        final response = result.data();
        final event = SkitLikeUpdatedEvent(
          skitId: response.id,
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

  Future<Result<SkitLikeUpdateResponse>> undoDislikeSkit({
    required String id,
  }) async {
    try {
      // Cancel current operation (if any)
      _updateSkitDislikeOp?.cancel();

      // Create Request
      final request = UndoDislikeSkitRequest(id: id);
      _updateSkitDislikeOp = async.CancelableOperation.fromFuture(
          locator<KwotData>().skitsRepository.undoDislikeSkit(request));

      // Wait for result
      final result = await _updateSkitDislikeOp!.value;
      if (result.isSuccess() && !result.isEmpty()) {
        final response = result.data();
        final event = SkitLikeUpdatedEvent(
          skitId: response.id,
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
   * API: Add comment
   */

  async.CancelableOperation<Result<ItemComment>>? _addCommentOp;

  Future<Result<bool>> addTextComment({
    required String skitId,
    required String text,
  }) async {
    try {
      // Cancel current operation (if any)
      _addCommentOp?.cancel();

      // Create Request
      final request = AddSkitCommentRequest(skitId: skitId, commentText: text);
      _addCommentOp = async.CancelableOperation.fromFuture(
          locator<KwotData>().skitsRepository.addSkitComment(request));

      // Wait for result
      final result = await _addCommentOp!.value;
      if (result.isSuccess() && !result.isEmpty()) {
        final addedComment = result.data();
        final event = SkitCommentAddedEvent(
          skitId: addedComment.parentId,
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
   * API: Notify Skit Viewed
   */

  async.CancelableOperation<Result>? _notifySkitViewedOp;

  Future<Result> notifySkitViewed({
    required Skit skit,
  }) async {
    try {
      // Cancel current operation (if any)
      _notifySkitViewedOp?.cancel();

      // Create Request
      final request = SkitViewedNotificationRequest(id: skit.id);
      _notifySkitViewedOp = async.CancelableOperation.fromFuture(
          locator<KwotData>().skitsRepository.notifySkitViewed(request));

      // Wait for result

      return await _notifySkitViewedOp!.value;

    } catch (error) {
      return Result.error("Error: $error");
    }
  }
}
