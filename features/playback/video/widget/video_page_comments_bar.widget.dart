import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/playback/video/fullscreen/comments/item_comment_list_item.widget.dart';
import 'package:kwotmusic/features/playback/video/fullscreen/video_page_interface.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/util/util.dart';

class VideoPageCommentsBar extends StatelessWidget {
  const VideoPageCommentsBar({
    Key? key,
    required this.pageInterface,
    required this.onTap,
  }) : super(key: key);

  final VideoPageInterface pageInterface;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
        onPressed: onTap,
        child: Container(
          /// required for ScaleTop to work
          color: Colors.transparent,
          child: Column(children: [
            _buildTitleBar(context),
            _buildHighlightedCommentArea(context),
          ]),
        ));
  }

  Widget _buildTitleBar(BuildContext context) {
    return SizedBox(
        height: ComponentSize.normal.r,
        child: Row(children: [
          _buildCommentsLabel(context),
          SizedBox(width: ComponentInset.small.r),
          _buildCommentCountLabel(context),
          const Spacer(),
          _buildViewAllCommentsLabel(context),
        ]));
  }

  Widget _buildCommentsLabel(BuildContext context) {
    return Text(LocaleResources.of(context).comments,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.boldHeading3
            .copyWith(color: DynamicTheme.get(context).white()));
  }

  Widget _buildCommentCountLabel(BuildContext context) {
    return ValueListenableBuilder<int>(
        valueListenable: pageInterface.commentCountNotifier,
        builder: (_, count, __) {
          return Text(count.prettyCount,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.heading5
                  .copyWith(color: DynamicTheme.get(context).neutral20()));
        });
  }

  Widget _buildHighlightedCommentArea(BuildContext context) {
    return ValueListenableBuilder<ItemComment?>(
        valueListenable: pageInterface.highlightedCommentNotifier,
        builder: (_, comment, __) {
          if (comment == null) {
            return _buildHighlightedCommentPlaceholder(context);
          } else {
            return ItemCommentListItem(
                comment: comment,
                showCommentBackground: false,
                onTap: (_) => onTap(),
                onAuthorTap: (user) => _onCommentAuthorTap(context, user));
          }
        });
  }

  Widget _buildHighlightedCommentPlaceholder(BuildContext context) {
    return Container(
      height: ComponentSize.small.r,
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
          color: DynamicTheme.get(context).black(),
          borderRadius: BorderRadius.circular(ComponentRadius.normal.r)),
      margin: EdgeInsets.only(left: ComponentInset.normal.r),
      padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
      child: Text(LocaleResources.of(context).writeCommentHint,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyles.heading6
              .copyWith(color: DynamicTheme.get(context).neutral20())),
    );
  }

  Widget _buildViewAllCommentsLabel(BuildContext context) {
    return ValueListenableBuilder<int>(
        valueListenable: pageInterface.commentCountNotifier,
        builder: (_, count, __) {
          if (count <= 0) return Container();
          return Text(LocaleResources.of(context).seeAll,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.boldBody
                  .copyWith(color: DynamicTheme.get(context).secondary100()));
        });
  }

  void _onCommentAuthorTap(BuildContext context, User user) {
    pageInterface.onCommentAuthorButtonTap(context, user: user);
    RootNavigation.popUntilRoot(context);
  }
}
