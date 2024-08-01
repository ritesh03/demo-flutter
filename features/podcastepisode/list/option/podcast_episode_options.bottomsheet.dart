import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/api/audioplayer.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/blocking_progress.dialog.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/bottomsheet.dart';
import 'package:kwotmusic/components/widgets/notificationbar/notification_bar.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/misc/report/report_content.model.dart';
import 'package:kwotmusic/features/playback/audio/audio_playback_actions.model.dart';
import 'package:kwotmusic/features/playback/audio/queue/playing_queue.bottomsheet.dart';
import 'package:kwotmusic/features/podcastepisode/detail/podcast_episode_detail.model.dart';
import 'package:kwotmusic/features/podcastepisode/podcast_episode_actions.model.dart';
import 'package:kwotmusic/features/podcastepisode/widget/podcast_episode_compact_preview.widget.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:kwotmusic/util/error_code_messages.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'podcast_episode_options.model.dart';

class PodcastEpisodeOptionsBottomSheet extends StatefulWidget {
  //=
  static Future show(
    BuildContext context, {
    required PodcastEpisodeOptionsArgs args,
  }) {
    return showMaterialBottomSheet<void>(
      context,
      expand: false,
      builder: (context, controller) => MultiProvider(providers: [
        ChangeNotifierProvider(
            create: (_) => PodcastEpisodeOptionsModel(args: args)),
      ], child: const PodcastEpisodeOptionsBottomSheet()),
    );
  }

  const PodcastEpisodeOptionsBottomSheet({Key? key}) : super(key: key);

  @override
  State<PodcastEpisodeOptionsBottomSheet> createState() =>
      _PodcastEpisodeOptionsBottomSheetState();
}

class _PodcastEpisodeOptionsBottomSheetState
    extends State<PodcastEpisodeOptionsBottomSheet> {
  //=

  PodcastEpisodeOptionsModel get _optionsModel =>
      context.read<PodcastEpisodeOptionsModel>();

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

          // ADD TO QUEUE
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

          // VIEW EPISODE
          _buildViewEpisodeOption(tileMargin),

          // REPORT
          _buildReportEpisodeOption(tileMargin),

          // REMOVE FROM QUEUE
          _RemoveFromPlayingQueueOption(
              margin: tileMargin, onTap: _onRemoveFromQueueButtonTapped),
          SizedBox(height: ComponentInset.normal.h)
        ]));
  }

  Widget _buildHeader() {
    return Selector<PodcastEpisodeOptionsModel, PodcastEpisode>(
        selector: (_, model) => model.episode,
        builder: (_, episode, __) {
          return PodcastEpisodeCompactPreview(episode: episode);
        });
  }

  Widget _buildLikeOption(EdgeInsets tileMargin) {
    return Selector<PodcastEpisodeOptionsModel, bool>(
        selector: (_, model) => model.isEpisodeLiked,
        builder: (_, isEpisodeLiked, __) {
          return BottomSheetTile(
              iconPath: isEpisodeLiked
                  ? Assets.iconHeartFilled
                  : Assets.iconHeartOutline,
              margin: tileMargin,
              text: isEpisodeLiked
                  ? LocaleResources.of(context).unlike
                  : LocaleResources.of(context).like,
              onTap: () => _onLikeButtonTapped(context));
        });
  }

  Widget _buildViewEpisodeOption(EdgeInsets tileMargin) {
    return Selector<PodcastEpisodeOptionsModel, bool>(
        selector: (_, model) => model.canShowViewEpisodeOption,
        builder: (_, canShowViewEpisodeOption, __) {
          if (!canShowViewEpisodeOption) return Container();
          return BottomSheetTile(
              iconPath: Assets.iconEpisode,
              margin: tileMargin,
              text: LocaleResources.of(context).goToEpisode,
              onTap: _onViewEpisodeButtonTapped);
        });
  }

  Widget _buildReportEpisodeOption(EdgeInsets tileMargin) {
    return Selector<PodcastEpisodeOptionsModel, bool>(
        selector: (_, model) => model.canShowReportEpisodeOption,
        builder: (_, canShowReportEpisodeOption, __) {
          if (!canShowReportEpisodeOption) return Container();
          return BottomSheetTile(
              iconPath: Assets.iconReport,
              margin: tileMargin,
              text: LocaleResources.of(context).report,
              onTap: _onReportEpisodeButtonTapped);
        });
  }

  void _onLikeButtonTapped(BuildContext context) async {
    final episode = _optionsModel.episode;

    showBlockingProgressDialog(context);
    final result = await locator<PodcastEpisodeActionsModel>().setIsLiked(
      podcastId: episode.podcastId,
      episodeId: episode.id,
      shouldLike: !episode.liked,
    );

    if (!mounted) return;
    hideBlockingProgressDialog(context);

    if (!result.isSuccess()) {
      showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()));
    }
  }

  void _onAddToPlaylistButtonTapped() {}

  void _onAddToQueueButtonTapped() async {
    showBlockingProgressDialog(context);

    final episode = _optionsModel.episode;
    final result = await locator<AudioPlaybackActionsModel>()
        .addPodcastEpisodeToQueue(episode);

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
    final episode = _optionsModel.episode;
    final shareableLink = episode.shareableLink;
    if (shareableLink.isEmpty) {
      return;
    }

    Share.share(shareableLink);
  }

  void _onViewEpisodeButtonTapped() {
    RootNavigation.popUntilRoot(context);

    final episode = _optionsModel.episode;
    final args = PodcastEpisodeDetailArgs.object(episode: episode);
    DashboardNavigation.pushNamed(
      context,
      Routes.podcastEpisode,
      arguments: args,
    );
  }

  void _onRemoveFromQueueButtonTapped() {
    final playbackItem = _optionsModel.playbackItem;
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

  void _onReportEpisodeButtonTapped() {
    RootNavigation.popUntilRoot(context);

    final episode = _optionsModel.episode;
    final args = ReportContentArgs(
        content: ReportableContent.fromPodcastEpisode(episode));
    DashboardNavigation.pushNamed(
      context,
      Routes.reportContent,
      arguments: args,
    );
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
    return Selector<PodcastEpisodeOptionsModel, PlaybackItem?>(
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
    return Selector<PodcastEpisodeOptionsModel, PlaybackItem?>(
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
