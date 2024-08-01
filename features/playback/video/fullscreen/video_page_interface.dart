import 'package:flutter/cupertino.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/widgets/list/item_list.model.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';
import 'package:kwotmusic/features/playback/video/widget/video_page_comment_input_bar.widget.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'comments/live_chat.dart';

enum LiveStreamMode { active, replay, none }

class LiveStreamModeNotifier extends ValueNotifier<LiveStreamMode> {
  LiveStreamModeNotifier() : super(LiveStreamMode.none);
}

abstract class VideoPageInterface with VideoPageCommentsInterface {
  final artistNotifier = ValueNotifier<Artist?>(null);
  final canDownloadVideoNotifier = ValueNotifier<bool>(false);
  final dislikedNotifier = ValueNotifier<bool>(false);
  final likedNotifier = ValueNotifier<bool>(false);
  final likesNotifier = ValueNotifier<int>(-1);
  final liveStreamModeNotifier = LiveStreamModeNotifier();
  final subtitleNotifier = ValueNotifier<String?>(null);
  final titleNotifier = ValueNotifier<String?>(null);
  final thumbnailNotifier = ValueNotifier<String?>(null);

  void updateSubtitle(String? subtitle) {
    subtitleNotifier.value = subtitle;
  }

  List<Feed> getFeeds();

  PhotoKind getPhotoKind();

  Future<void> onArtistButtonTap(BuildContext context);

  Future<void> onCommentAuthorButtonTap(
    BuildContext context, {
    required User user,
  });

  Future<Result> onDislikeButtonTap();

  void onDownloadButtonTap() {}

  Future<Result> onLikeButtonTap();

  void onSaveButtonTap() {}

  Future<void> onShareButtonTap();

  Future<void> onReportButtonTap(BuildContext context);

  @mustCallSuper
  @override
  void dispose() {
    super.dispose();

    artistNotifier.dispose();
    canDownloadVideoNotifier.dispose();
    dislikedNotifier.dispose();
    likedNotifier.dispose();
    likesNotifier.dispose();
    liveStreamModeNotifier.dispose();
    subtitleNotifier.dispose();
    titleNotifier.dispose();
    thumbnailNotifier.dispose();
  }
}

mixin VideoPageCommentsInterface {
  final commentInputVisibilityNotifier = ValueNotifier<bool>(false);
  final highlightedCommentNotifier = ValueNotifier<ItemComment?>(null);

  @mustCallSuper
  void dispose() {
    commentInputVisibilityNotifier.dispose();
    highlightedCommentNotifier.dispose();

    _disposeComments();
    _disposeLiveChat();
  }

  /// COMMENTS

  final commentCountNotifier = ValueNotifier<int>(0);
  final commentInputController = TextEditingController();
  final commentInputStatusNotifier = CommentInputStatusNotifier();
  final commentsPanelController = PanelController();
  final commentsFullScreenPanelController = PanelController();

  ItemListModel<ItemComment> obtainCommentsModel();

  Future<bool> onAddComment(BuildContext context);

  void onLoadComments();

  void onCloseCommentsPanel({bool isFullScreenMode = false});

  void onOpenCommentsPanel({bool isFullScreenMode = false});

  void _disposeComments() {
    commentCountNotifier.dispose();
    commentInputController.dispose();
    commentInputStatusNotifier.dispose();
  }

  /// LIVE CHAT

  final liveChatCommentInputStatusNotifier = CommentInputStatusNotifier();
  final liveChatMessageInputController = TextEditingController();
  final liveChatNotifier = LiveChatNotifier();
  final liveChatPanelController = PanelController();
  final liveChatFullScreenPanelController = PanelController();

  Future<bool> onAddLiveChatComment(BuildContext context);

  void onLoadLiveChat();

  void onCloseLiveChatPanel({bool isFullScreenMode = false});

  void onOpenLiveChatPanel({bool isFullScreenMode = false});

  void onReloadLiveChat();

  void _disposeLiveChat() {
    liveChatCommentInputStatusNotifier.dispose();
    liveChatMessageInputController.dispose();
    liveChatNotifier.dispose();
  }
}
