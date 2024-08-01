import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/list/item_list.model.dart';
import 'package:kwotmusic/components/widgets/list/item_list.widget.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/playback/playback.dart';
import 'package:kwotmusic/features/playback/video/fullscreen/comments/item_comment_list_item.widget.dart';
import 'package:kwotmusic/features/playback/video/fullscreen/video_page_interface.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'video_page_comment_input_bar.widget.dart';
import 'video_page_panel.dart';

class VideoPageCommentsPanel extends StatelessWidget {
  const VideoPageCommentsPanel({
    Key? key,
    this.maxWidth,
    required this.maxHeight,
    required this.pageInterface,
    required this.panelController,
    this.onPanelSlide,
    this.onPanelClosed,
    required this.onClose,
  }) : super(key: key);

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
        title: Text(LocaleResources.of(context).comments,
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
    return ItemListWidget<ItemComment, ItemListModel<ItemComment>>(
        model: pageInterface.obtainCommentsModel(),
        controller: controller,
        columnItemSpacing: ComponentInset.small.r,
        padding: EdgeInsets.all(ComponentInset.normal.r),
        itemBuilder: (context, comment, index) {
          return ItemCommentListItem(
            comment: comment,
            onTap: (comment) {},
            onAuthorTap: (user) => _onCommentAuthorTap(context, user: user),
          );
        });
  }

  Widget _buildCommentInputWidget(BuildContext context) {
    return ValueListenableBuilder<bool>(
        valueListenable: pageInterface.commentInputVisibilityNotifier,
        builder: (_, visible, __) {
          if (!visible) return Container();
          return VideoPageCommentInputBar(
              notifier: pageInterface.commentInputStatusNotifier,
              controller: pageInterface.commentInputController,
              onSubmit: (text) => _onAddComment(context, text));
        });
  }

  void _onAddComment(BuildContext context, String text) async {
    final success = await pageInterface.onAddComment(context);
    if (success) {
      /// New comments are added at top. So, we need
      /// to scroll to top to show latest comments.
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
