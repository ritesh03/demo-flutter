import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/blocking_progress.dialog.dart';
import 'package:kwotmusic/components/widgets/button/buttons.dart';
import 'package:kwotmusic/components/widgets/multi_value_listenable_builder.widget.dart';
import 'package:kwotmusic/components/widgets/notificationbar/notification_bar.dart';
import 'package:kwotmusic/features/playback/video/fullscreen/video_page_interface.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/util/util.dart';

class VideoPageOptionsBar extends StatelessWidget {
  const VideoPageOptionsBar({
    Key? key,
    required this.pageInterface,
    required this.padding,
  }) : super(key: key);

  final VideoPageInterface pageInterface;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final spacingMargin = EdgeInsets.only(right: ComponentInset.normal.r);
    return Padding(
      padding: padding,
      child: Row(children: [
        _buildLikeButton(margin: spacingMargin),
        _buildDislikeButton(margin: spacingMargin),
        const Spacer(),
        // _buildLiveChatButton(margin: spacingMargin),
        _buildShareButton(context, margin: EdgeInsets.zero),
        // _buildDownloadButton(margin: spacingMargin),
        // _buildSaveButton(context, margin: EdgeInsets.zero),
      ]),
    );
  }

  Widget _buildLikeButton({required EdgeInsets margin}) {
    return TwoValuesListenableBuilder<bool, int>(
        valueListenable1: pageInterface.likedNotifier,
        valueListenable2: pageInterface.likesNotifier,
        builder: (context, liked, likes, __) {
          return VerticalIconTextButton(
              color: DynamicTheme.get(context).white(),
              crossAxisAlignment: CrossAxisAlignment.center,
              height: ComponentSize.normal.h,
              iconPath:
                  liked ? Assets.iconHeartFilled : Assets.iconHeartOutline,
              margin: margin,
              text: likes.prettyCount,
              onTap: () => _onLikeButtonTap(context));
        });
  }

  Widget _buildDislikeButton({required EdgeInsets margin}) {
    return ValueListenableBuilder<bool>(
        valueListenable: pageInterface.dislikedNotifier,
        builder: (context, disliked, __) {
          return VerticalIconTextButton(
              color: DynamicTheme.get(context).white(),
              crossAxisAlignment: CrossAxisAlignment.center,
              height: ComponentSize.normal.h,
              iconPath:
                  disliked ? Assets.iconDislikeFilled : Assets.iconDislike,
              margin: margin,
              text: LocaleResources.of(context).dislikeUppercase,
              onTap: () => _onDislikeButtonTap(context));
        });
  }

  Widget _buildLiveChatButton({required EdgeInsets margin}) {
    return ValueListenableBuilder<LiveStreamMode>(
        valueListenable: pageInterface.liveStreamModeNotifier,
        builder: (context, mode, __) {
          if (mode == LiveStreamMode.none) return Container();
          return VerticalIconTextButton(
              color: DynamicTheme.get(context).white(),
              crossAxisAlignment: CrossAxisAlignment.center,
              height: ComponentSize.normal.h,
              iconPath: Assets.iconComments,
              margin: margin,
              text: LocaleResources.of(context).liveChatUppercase,
              onTap: _onLiveChatButtonTap);
        });
  }

  Widget _buildShareButton(BuildContext context, {required EdgeInsets margin}) {
    return VerticalIconTextButton(
        color: DynamicTheme.get(context).white(),
        crossAxisAlignment: CrossAxisAlignment.center,
        height: ComponentSize.normal.h,
        iconPath: Assets.iconShare,
        margin: margin,
        text: LocaleResources.of(context).shareUppercase,
        onTap: _onShareButtonTap);
  }

  Widget _buildDownloadButton({required EdgeInsets margin}) {
    return ValueListenableBuilder<bool>(
        valueListenable: pageInterface.canDownloadVideoNotifier,
        builder: (context, canDownload, __) {
          return VerticalIconTextButton(
              color: canDownload
                  ? DynamicTheme.get(context).white()
                  : DynamicTheme.get(context).neutral20(),
              crossAxisAlignment: CrossAxisAlignment.center,
              height: ComponentSize.normal.h,
              iconPath: Assets.iconDownload,
              margin: margin,
              text: LocaleResources.of(context).downloadUppercase,
              onTap: canDownload ? _onDownloadButtonTap : null);
        });
  }

  Widget _buildSaveButton(BuildContext context, {required EdgeInsets margin}) {
    return VerticalIconTextButton(
        color: DynamicTheme.get(context).white(),
        crossAxisAlignment: CrossAxisAlignment.center,
        height: ComponentSize.normal.h,
        iconPath: Assets.iconSave,
        margin: margin,
        text: LocaleResources.of(context).saveUppercase,
        onTap: _onSaveButtonTap);
  }

  void _onLikeButtonTap(BuildContext context) async {
    showBlockingProgressDialog(context);

    final result = await pageInterface.onLikeButtonTap();
    hideBlockingProgressDialog(context);

    if (!result.isSuccess()) {
      showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()));
      return;
    }
  }

  void _onDislikeButtonTap(BuildContext context) async {
    showBlockingProgressDialog(context);

    final result = await pageInterface.onDislikeButtonTap();
    hideBlockingProgressDialog(context);

    if (!result.isSuccess()) {
      showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()));
      return;
    }
  }

  void _onLiveChatButtonTap() {
    pageInterface.onOpenLiveChatPanel();
  }

  void _onShareButtonTap() {
    pageInterface.onShareButtonTap();
  }

  void _onDownloadButtonTap() {
    pageInterface.onDownloadButtonTap();
  }

  void _onSaveButtonTap() {
    pageInterface.onSaveButtonTap();
  }
}
