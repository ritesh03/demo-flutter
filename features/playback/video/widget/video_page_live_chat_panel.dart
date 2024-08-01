import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/models/models.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/indicator/indicators.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/playback/playback.dart';
import 'package:kwotmusic/features/playback/video/fullscreen/comments/item_comment_list_item.widget.dart';
import 'package:kwotmusic/features/playback/video/fullscreen/comments/live_chat.dart';
import 'package:kwotmusic/features/playback/video/fullscreen/video_page_interface.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'video_page_comment_input_bar.widget.dart';
import 'video_page_panel.dart';

class VideoPageLiveChatPanel extends StatelessWidget {
  const VideoPageLiveChatPanel({
    Key? key,
    required this.liveStreamMode,
    this.maxWidth,
    required this.maxHeight,
    required this.pageInterface,
    required this.panelController,
    this.onPanelSlide,
    this.onPanelClosed,
    required this.onClose,
  }) : super(key: key);

  final LiveStreamMode liveStreamMode;
  final double? maxWidth;
  final double maxHeight;
  final VideoPageInterface pageInterface;
  final PanelController panelController;
  final ValueSetter<double>? onPanelSlide;
  final VoidCallback? onPanelClosed;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return VideoPagePanel(
        title: Text(_obtainHeaderTitle(context),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyles.boldHeading3
                .copyWith(color: DynamicTheme.get(context).white())),
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        panelController: panelController,
        onPanelSlide: onPanelSlide,
        onPanelClosed: onPanelClosed,
        onClose: onClose,
        builder: (_, controller) {
          return Container(
              color: DynamicTheme.get(context).neutral80(),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Expanded(
                    child: _buildCommentList(context, controller: controller)),
                _buildCommentInputWidget(context),
              ]));
        });
  }

  Widget _buildCommentList(
    BuildContext context, {
    required ScrollController controller,
  }) {
    return ValueListenableBuilder<LiveChat>(
        valueListenable: pageInterface.liveChatNotifier,
        builder: (_, chat, __) {
          if (chat.loading) {
            return const LoadingIndicator();
          }

          final error = chat.error;
          if (error != null) {
            return ErrorIndicator(
              error: error,
              onTryAgain: pageInterface.onReloadLiveChat,
            );
          }

          final comments = chat.comments;
          if (comments.isEmpty) {
            final message =
                LocaleResources.of(context).commentListFirstCommentPrompt;
            return EmptyIndicator(message: message);
          }

          return ListView.separated(
              controller: controller,
              itemCount: comments.length,
              reverse: true,
              padding: EdgeInsets.all(ComponentInset.normal.r),
              itemBuilder: (context, index) {
                final comment = comments[index];
                return ItemCommentListItem(
                    comment: comment,
                    onTap: (comment) {},
                    onAuthorTap: (user) {
                      return _onCommentAuthorTap(context, user: user);
                    });
              },
              separatorBuilder: (_, __) {
                return SizedBox(height: ComponentInset.small.r);
              });
        });
  }

  Widget _buildCommentInputWidget(BuildContext context) {
    return ValueListenableBuilder<bool>(
        valueListenable: pageInterface.commentInputVisibilityNotifier,
        builder: (_, visible, __) {
          if (!visible) return Container();
          return VideoPageCommentInputBar(
              notifier: pageInterface.liveChatCommentInputStatusNotifier,
              controller: pageInterface.liveChatMessageInputController,
              onSubmit: (text) => _onAddComment(context, text));
        });
  }

  String _obtainHeaderTitle(BuildContext context) {
    switch (liveStreamMode) {
      case LiveStreamMode.active:
        return LocaleResources.of(context).liveChat;
      case LiveStreamMode.replay:
        return LocaleResources.of(context).liveChatReplay;
      case LiveStreamMode.none:
        return "";
    }
  }

  void _onAddComment(BuildContext context, String text) async {
    final success = await pageInterface.onAddLiveChatComment(context);
    if (success) {
      /// New comments are added at top. So, we need
      /// to scroll to top to show latest comments. In this case,
      /// _top_ is actually at _bottom_ since the list is reversed.
      panelController.scrollController?.animateTo(
        0,
        duration: const Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  void _onCommentAuthorTap(
    BuildContext context, {
    required User user,
  }) async {
    await videoPlayerManager.exitPresentationMode();
    pageInterface.onCommentAuthorButtonTap(context, user: user);
    RootNavigation.popUntilRoot(context);
  }
}
