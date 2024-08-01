import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/app_config.dart';
import 'package:kwotmusic/components/widgets/list/item_list.model.dart';
import 'package:kwotmusic/components/widgets/notificationbar/notification_bar.dart';
import 'package:kwotmusic/components/widgets/photo/photo_kind.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/events/events.dart';
import 'package:kwotmusic/features/artist/profile/artist.model.dart';
import 'package:kwotmusic/features/misc/report/report_content.model.dart';
import 'package:kwotmusic/features/playback/video/fullscreen/video_page_interface.dart';
import 'package:kwotmusic/features/playback/video/widget/video_page_comment_input_bar.widget.dart';
import 'package:kwotmusic/features/show/comment/show_comments.model.dart';
import 'package:kwotmusic/features/show/show_actions.model.dart';
import 'package:kwotmusic/features/user/profile/user_profile.model.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'show_live_chat_manager.dart';

/// TODO: compare with SkitPageInterface
class ShowPageInterface extends VideoPageInterface {
  //=

  Show show;

  late ShowLiveChatManager _liveChatManager;
  late ShowCommentsModel _commentsModel;

  ShowCommentsModel get commentsModel => _commentsModel;

  ShowPageInterface({
    required this.show,
  }) {
    _liveChatManager = ShowLiveChatManager(
        showId: show.id,
        liveChatNotifier: liveChatNotifier,
        shouldNotify: () {
          return (liveChatPanelController.isAttached &&
                  liveChatPanelController.isPanelOpen) ||
              (liveChatFullScreenPanelController.isAttached &&
                  liveChatFullScreenPanelController.isPanelOpen);
        },
        onLiveChatUpdated: (liveChat) {
          /// Can we add comments?
          final liveStreamMode = liveStreamModeNotifier.value;
          if (liveChat.loading ||
              liveChat.error != null ||
              liveStreamMode != LiveStreamMode.active) {
            commentInputVisibilityNotifier.value = false;
          } else {
            commentInputVisibilityNotifier.value = true;
          }
        });

    _commentsModel = ShowCommentsModel(args: ShowCommentsArgs(id: show.id))
      ..init(onRefreshListener: () {});

    _listenToShowLikeUpdates();
    _updateShow(show: show);
  }

  @override
  void dispose() {
    _liveChatManager.dispose();
    _commentsModel.dispose();
    super.dispose();
  }

  void _listenToShowLikeUpdates() {
    eventBus.on<ShowLikeUpdatedEvent>().listen((event) {
      if (show.id != event.showId) return;

      final updatedShow = show.copyWith(
          disliked: event.disliked, liked: event.liked, likes: event.likes);
      _updateShow(show: updatedShow);
    });
  }

  void _updateShow({required Show show}) {
    this.show = show;

    artistNotifier.value = show.artist;
    canDownloadVideoNotifier.value = !show.isStreamingNow;
    commentCountNotifier.value = show.commentCount;
    dislikedNotifier.value = show.disliked;
    highlightedCommentNotifier.value = show.highlightedComment;
    likedNotifier.value = show.liked;
    likesNotifier.value = show.likes;
    liveStreamModeNotifier.value = show.isStreamingNow
        ? LiveStreamMode.active
        : (show.wasLiveStream ? LiveStreamMode.replay : LiveStreamMode.none);
    titleNotifier.value = show.title;
    thumbnailNotifier.value = show.thumbnail;
  }

  @override
  List<Feed> getFeeds() {
    return show.feeds ?? [];
  }

  @override
  PhotoKind getPhotoKind() {
    return PhotoKind.show;
  }

  @override
  ItemListModel<ItemComment> obtainCommentsModel() {
    return commentsModel;
  }

  @override
  Future<bool> onAddComment(BuildContext context) async {
    final localization = LocaleResources.of(context);

    final text = commentInputController.text.trim();
    if (text.isEmpty) {
      showDefaultNotificationBar(NotificationBarInfo.error(
          message: localization.errorCommentCannotBeEmpty));
      return false;
    }

    if (text.length > AppConfig.allowedNewCommentLength) {
      showDefaultNotificationBar(NotificationBarInfo.error(
          message: localization.errorCommentIsTooLong));
      return false;
    }

    commentInputStatusNotifier.value = CommentInputStatus.loading;
    final result = await locator<ShowActionsModel>().addTextComment(
      showId: show.id,
      text: text,
    );

    if (!result.isSuccess()) {
      showDefaultNotificationBar(NotificationBarInfo.error(
          message: localization.errorFailedToAddComment));
      commentInputStatusNotifier.value = CommentInputStatus.idle;
      return false;
    }

    commentInputController.clear();
    commentInputStatusNotifier.value = CommentInputStatus.idle;
    return true;
  }

  @override
  Future<bool> onAddLiveChatComment(BuildContext context) async {
    final localization = LocaleResources.of(context);

    final text = liveChatMessageInputController.text.trim();
    if (text.isEmpty) {
      showDefaultNotificationBar(NotificationBarInfo.error(
          message: localization.errorCommentCannotBeEmpty));
      return false;
    }

    if (text.length > AppConfig.allowedNewCommentLength) {
      showDefaultNotificationBar(NotificationBarInfo.error(
          message: localization.errorCommentIsTooLong));
      return false;
    }

    liveChatCommentInputStatusNotifier.value = CommentInputStatus.loading;
    final result = await locator<ShowActionsModel>().addLiveChatTextComment(
      showId: show.id,
      text: text,
    );
    if (!result.isSuccess()) {
      showDefaultNotificationBar(NotificationBarInfo.error(
          message: localization.errorFailedToAddComment));
      liveChatCommentInputStatusNotifier.value = CommentInputStatus.idle;
      return false;
    }

    liveChatMessageInputController.clear();
    liveChatCommentInputStatusNotifier.value = CommentInputStatus.idle;
    return true;
  }

  @override
  Future<void> onArtistButtonTap(BuildContext context) {
    final args = ArtistPageArgs.object(artist: show.artist);
    return DashboardNavigation.pushNamed(context, Routes.artist,
        arguments: args);
  }

  @override
  void onCloseCommentsPanel({bool isFullScreenMode = false}) {
    if (isFullScreenMode) {
      commentsFullScreenPanelController.closeIfAttached();
    } else {
      commentsPanelController.closeIfAttached();
    }
  }

  @override
  void onCloseLiveChatPanel({bool isFullScreenMode = false}) {
    if (isFullScreenMode) {
      liveChatFullScreenPanelController.closeIfAttached();
    } else {
      liveChatPanelController.closeIfAttached();
    }
  }

  @override
  Future<void> onCommentAuthorButtonTap(
    BuildContext context, {
    required User user,
  }) {
    final args = UserProfileArgs(
      id: user.id,
      name: user.name,
      thumbnail: user.thumbnail,
    );
    return DashboardNavigation.pushNamed(context, Routes.userProfile,
        arguments: args);
  }

  @override
  Future<Result> onDislikeButtonTap() {
    return locator<ShowActionsModel>().toggleShowDislike(
      id: show.id,
      disliked: show.disliked,
    );
  }

  @override
  Future<Result> onLikeButtonTap() {
    return locator<ShowActionsModel>().toggleShowLike(
      id: show.id,
      liked: show.liked,
    );
  }

  @override
  void onLoadComments() {
    if (!_commentsModel.hasComments()) {
      _commentsModel.refresh(resetPageKey: true);
    }

    commentInputVisibilityNotifier.value = true;
  }

  @override
  void onLoadLiveChat() {
    _liveChatManager.load();
  }

  @override
  void onOpenCommentsPanel({bool isFullScreenMode = false}) {
    if (isFullScreenMode) {
      commentsFullScreenPanelController.openIfAttached();
    } else {
      commentsPanelController.openIfAttached();
    }

    onLoadComments();
  }

  @override
  void onOpenLiveChatPanel({bool isFullScreenMode = false}) {
    if (isFullScreenMode) {
      liveChatFullScreenPanelController.openIfAttached();
    } else {
      liveChatPanelController.openIfAttached();
    }

    onLoadLiveChat();
  }

  @override
  void onReloadLiveChat() {
    _liveChatManager.refresh();
  }

  @override
  Future<void> onShareButtonTap() {
    return Share.share(show.shareableLink);
  }

  @override
  Future<void> onReportButtonTap(BuildContext context) {
    final args = ReportContentArgs(content: ReportableContent.fromShow(show));
    return DashboardNavigation.pushNamed(context, Routes.reportContent,
        arguments: args);
  }
}
