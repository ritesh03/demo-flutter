import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';
import 'package:kwotmusic/util/util.dart';

class ItemCommentListItem extends StatelessWidget {
  const ItemCommentListItem({
    Key? key,
    required this.comment,
    this.showCommentBackground = true,
    required this.onTap,
    required this.onAuthorTap,
  }) : super(key: key);

  final ItemComment comment;
  final bool showCommentBackground;
  final Function(ItemComment) onTap;
  final Function(User) onAuthorTap;

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
        onPressed: () => onTap(comment),
        child: Container(
          decoration: _obtainOuterDecoration(context),
          padding: _obtainOuterPadding(),
          child: _buildContent(context),
        ));
  }

  Widget _buildContent(BuildContext context) {
    switch (comment.content.runtimeType) {
      case ItemTextCommentContent:
        return _buildTextComment(context);
      case ItemLikeCommentContent:
        return _buildLikeComment(context);
      case ItemDislikeCommentContent:
        return _buildDislikeComment(context);
      default:
        throw Exception("Unknown content for comment: ${comment.content}");
    }
  }

  Widget _buildTopBar(BuildContext context, {Widget? child}) {
    return Row(children: [
      /// AUTHOR
      _UserNameAndPhoto(
        user: comment.author,
        onTap: () => onAuthorTap(comment.author),
      ),
      SizedBox(width: ComponentInset.small.w),

      /// CHILD WIDGET
      if (child != null) child,

      const Spacer(),

      /// TIME
      Text(comment.createdAt.toCompactTimeAgoString(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyles.heading6
              .copyWith(color: DynamicTheme.get(context).neutral10()))
    ]);
  }

  Widget _buildTextComment(BuildContext context) {
    final content = comment.content as ItemTextCommentContent;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildTopBar(context, child: null),
      SizedBox(height: ComponentInset.small.r),
      Text(content.text,
          style: TextStyles.body
              .copyWith(color: DynamicTheme.get(context).white()))
    ]);
  }

  Widget _buildLikeComment(BuildContext context) {
    return _buildTopBar(context,
        child: SvgPicture.asset(Assets.iconHeartFilled,
            width: ComponentSize.small.r,
            height: ComponentSize.small.r,
            color: DynamicTheme.get(context).white()));
  }

  Widget _buildDislikeComment(BuildContext context) {
    return _buildTopBar(context,
        child: SvgPicture.asset(Assets.iconDislikeFilled,
            width: ComponentSize.small.r,
            height: ComponentSize.small.r,
            color: DynamicTheme.get(context).white()));
  }

  Decoration? _obtainOuterDecoration(BuildContext context) {
    return showCommentBackground
        ? BoxDecoration(
            color: DynamicTheme.get(context).black().withOpacity(0.75),
            borderRadius: BorderRadius.circular(ComponentRadius.normal.r))
        : const BoxDecoration(

            /// For ScaleTap's onPressed to work
            color: Colors.transparent);
  }

  EdgeInsets? _obtainOuterPadding() {
    return showCommentBackground
        ? EdgeInsets.all(ComponentInset.small.r)
        : null;
  }
}

class _UserNameAndPhoto extends StatelessWidget {
  const _UserNameAndPhoto({
    Key? key,
    required this.user,
    required this.onTap,
  }) : super(key: key);

  final User user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
        onPressed: onTap,
        child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// AUTHOR PHOTO
              Photo.user(
                user.thumbnail,
                options: PhotoOptions(
                    width: ComponentSize.small.r,
                    height: ComponentSize.small.r,
                    shape: BoxShape.circle),
              ),
              SizedBox(width: ComponentInset.small.w),

              /// AUTHOR NAME
              Text(user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.boldBody
                      .copyWith(color: DynamicTheme.get(context).white())),
            ]));
  }
}
