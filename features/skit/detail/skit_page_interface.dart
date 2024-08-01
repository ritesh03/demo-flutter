import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/app_config.dart';
import 'package:kwotmusic/components/widgets/list/item_list.model.dart';
import 'package:kwotmusic/components/widgets/notificationbar/notification_bar.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/events/events.dart';
import 'package:kwotmusic/features/artist/profile/artist.model.dart';
import 'package:kwotmusic/features/misc/report/report_content.model.dart';
import 'package:kwotmusic/features/playback/video/fullscreen/video_page_interface.dart';
import 'package:kwotmusic/features/playback/video/widget/video_page_comment_input_bar.widget.dart';
import 'package:kwotmusic/features/skit/comment/skit_comments.model.dart';
import 'package:kwotmusic/features/skit/skit_actions.model.dart';
import 'package:kwotmusic/features/user/profile/user_profile.model.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class SkitPageInterface extends VideoPageInterface {
  //=

  Skit skit;

  late SkitCommentsModel _commentsModel;

  SkitCommentsModel get commentsModel => _commentsModel;

  StreamSubscription? _eventsSubscription;

  SkitPageInterface({
    required this.skit,
  }) {
    _eventsSubscription = _listenToEvents();

    _commentsModel = SkitCommentsModel(args: SkitCommentsArgs(id: skit.id))
      ..init(onRefreshListener: () {});

    _updateSkit(skit: skit);
  }

  @override
  void dispose() {
    _eventsSubscription?.cancel();
    _commentsModel.dispose();
    super.dispose();
  }

  void _updateSkit({required Skit skit}) {
    this.skit = skit;

    artistNotifier.value = skit.artist;
    canDownloadVideoNotifier.value = true;
    commentCountNotifier.value = skit.commentCount;
    dislikedNotifier.value = skit.disliked;
    highlightedCommentNotifier.value = skit.highlightedComment;
    likedNotifier.value = skit.liked;
    likesNotifier.value = skit.likes;
    liveStreamModeNotifier.value = LiveStreamMode.none;
    titleNotifier.value = skit.title;
    thumbnailNotifier.value = skit.thumbnail;
  }

  @override
  List<Feed> getFeeds() {
    return skit.feeds ?? [];
  }

  @override
  PhotoKind getPhotoKind() {
    return PhotoKind.skit;
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
    final result = await locator<SkitActionsModel>().addTextComment(
      skitId: skit.id,
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
    // Skits do not support live chat
    return false;
  }

  @override
  Future<void> onArtistButtonTap(BuildContext context) {
    final args = ArtistPageArgs.object(artist: skit.artist);
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
    // Skits do not support live chat
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
    return locator<SkitActionsModel>().toggleSkitDislike(
      id: skit.id,
      disliked: skit.disliked,
    );
  }

  @override
  Future<Result> onLikeButtonTap() {
    return locator<SkitActionsModel>().toggleSkitLike(
      id: skit.id,
      liked: skit.liked,
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
    // Skits do not support live chat
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
    // Skits do not support live chat
  }

  @override
  void onReloadLiveChat() {
    // Skits do not support live chat
  }

  @override
  Future<void> onShareButtonTap() {
    return Share.share(skit.shareableLink);
  }

  @override
  Future<void> onReportButtonTap(BuildContext context) {
    final args = ReportContentArgs(content: ReportableContent.fromSkit(skit));
    return DashboardNavigation.pushNamed(context, Routes.reportContent,
        arguments: args);
  }

  /*
   * EVENT:
   *  ArtistBlockUpdatedEvent,
   *  ArtistFollowUpdatedEvent,
   *  SkitLikeUpdatedEvent,
   */

  StreamSubscription _listenToEvents() {
    return eventBus.on().listen((event) {
      if (event is ArtistFollowUpdatedEvent) {
        return _handleArtistFollowEvent(event);
      }
      if (event is SkitLikeUpdatedEvent) {
        return _handleSkitLikeEvent(event);
      }
    });
  }

  void _handleArtistFollowEvent(ArtistFollowUpdatedEvent event) {
    if (skit.artist.id != event.artistId) return;

    final updatedSkit = skit.copyWith(artist: event.update(skit.artist));
    _updateSkit(skit: updatedSkit);
  }

  void _handleSkitLikeEvent(SkitLikeUpdatedEvent event) {
    if (skit.id != event.skitId) return;

    _updateSkit(skit: event.update(skit));
  }
}
