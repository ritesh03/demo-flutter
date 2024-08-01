import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/api/audioplayer.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/blocking_progress.dialog.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/bottomsheet.dart';
import 'package:kwotmusic/components/widgets/notificationbar/notification_bar.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/artist/profile/artist.model.dart';
import 'package:kwotmusic/features/misc/report/report_content.model.dart';
import 'package:kwotmusic/features/playback/audio/audio_playback_actions.model.dart';
import 'package:kwotmusic/features/playback/audio/queue/playing_queue.bottomsheet.dart';
import 'package:kwotmusic/features/skit/skit_actions.model.dart';
import 'package:kwotmusic/features/skit/widget/skit_compact_preview.widget.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:kwotmusic/util/error_code_messages.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'skit_options.model.dart';

class SkitOptionsBottomSheet extends StatefulWidget {
  //=
  static Future show(
    BuildContext context, {
    required SkitOptionsArgs args,
  }) {
    return showMaterialBottomSheet<void>(
      context,
      expand: false,
      builder: (context, controller) {
        return ChangeNotifierProvider(
            create: (_) => SkitOptionsModel(args: args),
            child: const SkitOptionsBottomSheet());
      },
    );
  }

  const SkitOptionsBottomSheet({Key? key}) : super(key: key);

  @override
  State<SkitOptionsBottomSheet> createState() => _SkitOptionsBottomSheetState();
}

class _SkitOptionsBottomSheetState extends State<SkitOptionsBottomSheet> {
  //=
  SkitOptionsModel get _skitOptionsModel => context.read<SkitOptionsModel>();

  @override
  Widget build(BuildContext context) {
    final tileMargin = EdgeInsets.only(top: ComponentInset.small.h);

    return Container(
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const BottomSheetDragHandle(),
          SizedBox(height: ComponentInset.normal.h),
          _buildHeader(),
          SizedBox(height: ComponentInset.normal.h),
          Container(color: DynamicTheme.get(context).background(), height: 2.r),
          SizedBox(height: ComponentInset.normal.h),

          // LIKE
          _buildLikeOption(tileMargin),

          // ADD TO QUEUE (AUDIO ONLY)
          if (_skitOptionsModel.skit.type == SkitType.audio)
            _AddToQueueOption(
                margin: tileMargin, onTap: _onAddToQueueButtonTapped),

          // DOWNLOAD
          // BottomSheetTile(
          //     iconPath: Assets.iconDownload,
          //     margin: tileMargin,
          //     text: LocaleResources.of(context).download,
          //     onTap: _onDownloadButtonTapped),

          // SHARE
          BottomSheetTile(
              iconPath: Assets.iconShare,
              margin: tileMargin,
              text: LocaleResources.of(context).share,
              onTap: _onShareButtonTapped),

          // VIEW ARTIST
          BottomSheetTile(
              iconPath: Assets.iconProfile,
              margin: tileMargin,
              text: LocaleResources.of(context).viewArtist,
              onTap: _onViewArtistButtonTapped),

          // REPORT
          BottomSheetTile(
              iconPath: Assets.iconReport,
              margin: tileMargin,
              text: LocaleResources.of(context).report,
              onTap: _onReportSkitButtonTapped),

          // REMOVE FROM PLAYING QUEUE
          _RemoveFromPlayingQueueOption(
              margin: tileMargin, onTap: _onRemoveFromQueueButtonTapped),
          SizedBox(height: ComponentInset.normal.h)
        ]));
  }

  Widget _buildHeader() {
    return Selector<SkitOptionsModel, Skit>(
        selector: (_, model) => model.skit,
        builder: (_, skit, __) {
          return SkitCompactPreview(skit: skit);
        });
  }

  Widget _buildLikeOption(EdgeInsets tileMargin) {
    return Selector<SkitOptionsModel, bool>(
        selector: (_, model) => model.isSkitLiked,
        builder: (_, isLiked, __) {
          return BottomSheetTile(
              iconPath:
                  isLiked ? Assets.iconHeartFilled : Assets.iconHeartOutline,
              margin: tileMargin,
              text: isLiked
                  ? LocaleResources.of(context).unlike
                  : LocaleResources.of(context).like,
              onTap: () => _onLikeButtonTapped(context));
        });
  }

  void _onLikeButtonTapped(BuildContext context) async {
    final skit = _skitOptionsModel.skit;

    showBlockingProgressDialog(context);

    final result = await locator<SkitActionsModel>()
        .toggleSkitLike(id: skit.id, liked: skit.liked);

    if (!mounted) return;
    hideBlockingProgressDialog(context);

    if (!result.isSuccess()) {
      showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()));
    }
  }

  void _onAddToQueueButtonTapped() async {
    showBlockingProgressDialog(context);

    final skit = _skitOptionsModel.skit;
    final result =
        await locator<AudioPlaybackActionsModel>().addSkitToQueue(skit);

    if (!mounted) return;
    hideBlockingProgressDialog(context);

    if (result.isSuccess()) {
      RootNavigation.popUntilRoot(context);

      showDefaultNotificationBar(
        NotificationBarInfo.success(
          message: result.message,
          actionText: LocaleResources.of(context).viewPlayingQueue,
          actionCallback: (context) => PlayingQueueBottomSheet.show(context),
        ),
      );
    } else if (result.errorCode() != null) {
      final errorMessage =
          getErrorMessageFromErrorCode(context, result.errorCode()!);
      showDefaultNotificationBar(
          NotificationBarInfo.error(message: errorMessage));
    } else {
      showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()));
    }
  }

  void _onDownloadButtonTapped() {}

  void _onShareButtonTapped() async {
    final skit = _skitOptionsModel.skit;
    final shareableLink = skit.shareableLink;
    if (shareableLink.isEmpty) {
      return;
    }

    Share.share(shareableLink);
  }

  void _onViewArtistButtonTapped() {
    RootNavigation.pop(context);

    final skit = _skitOptionsModel.skit;
    final args = ArtistPageArgs.object(artist: skit.artist);
    DashboardNavigation.pushNamed(context, Routes.artist, arguments: args);
  }

  void _onRemoveFromQueueButtonTapped() {
    final playbackItem = _skitOptionsModel.playbackItem;
    if (playbackItem == null) return;

    showBlockingProgressDialog(context);
    locator<AudioPlaybackActionsModel>().removePlaybackItem(playbackItem).then(
      (result) {
        if (!mounted) return;
        hideBlockingProgressDialog(context);

        if (!result.isSuccess()) {
          showDefaultNotificationBar(
              NotificationBarInfo.error(message: result.error()));
          return;
        }

        RootNavigation.pop(context);
      },
    );
  }

  void _onReportSkitButtonTapped() {
    RootNavigation.pop(context);

    final skit = _skitOptionsModel.skit;
    final args = ReportContentArgs(content: ReportableContent.fromSkit(skit));
    DashboardNavigation.pushNamed(context, Routes.reportContent,
        arguments: args);
  }
}

class _AddToQueueOption extends StatelessWidget {
  const _AddToQueueOption({
    Key? key,
    this.margin = EdgeInsets.zero,
    required this.onTap,
  }) : super(key: key);

  final EdgeInsets margin;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Selector<SkitOptionsModel, PlaybackItem?>(
        selector: (_, model) => model.playbackItem,
        builder: (_, playbackItem, __) {
          if (playbackItem != null) return const SizedBox.shrink();
          return BottomSheetTile(
              iconPath: Assets.iconQueue,
              margin: margin,
              text: LocaleResources.of(context).addToQueue,
              onTap: onTap);
        });
  }
}

class _RemoveFromPlayingQueueOption extends StatelessWidget {
  const _RemoveFromPlayingQueueOption({
    Key? key,
    this.margin = EdgeInsets.zero,
    required this.onTap,
  }) : super(key: key);

  final EdgeInsets margin;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Selector<SkitOptionsModel, PlaybackItem?>(
        selector: (_, model) => model.playbackItem,
        builder: (_, playbackItem, __) {
          if (playbackItem == null) return const SizedBox.shrink();
          return BottomSheetDiscouragedOption(
              iconPath: Assets.iconDelete,
              text: LocaleResources.of(context).playingQueueRemoveItem,
              margin: margin,
              onTap: onTap);
        });
  }
}
