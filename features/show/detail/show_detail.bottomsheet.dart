import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/material_bottom_sheet.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/indicator/indicators.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/misc/report/report_content.model.dart';
import 'package:kwotmusic/features/playback/audio/audio_playback_actions.model.dart';
import 'package:kwotmusic/features/playback/playback.dart';
import 'package:kwotmusic/features/playback/video/widget/video_page_content_builder.widget.dart';
import 'package:kwotmusic/features/playback/video/widget/video_page_placeholder_info.widget.dart';
import 'package:kwotmusic/features/playback/video/widget/video_page_top_bar.widget.dart';
import 'package:kwotmusic/features/show/options/purchase_show.bottomsheet.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:kwotmusic/util/util.dart';
import 'package:provider/provider.dart';

import 'show_detail.model.dart';

class ShowDetailBottomSheet extends StatefulWidget {
  //=
  static Future showBottomSheet(
    BuildContext context, {
    required ShowDetailArgs args,
  }) {
    return showMaterialBottomSheet<void>(
      context,
      backgroundColor: DynamicTheme.get(context).background(),
      borderRadius: BorderRadius.zero,
      margin: EdgeInsets.zero,
      builder: (context, controller) {
        return MultiProvider(providers: [
          ChangeNotifierProvider(create: (_) => ShowDetailModel(args: args)),
          ChangeNotifierProvider(create: (_) => VideoControlsVisibilityModel()),
        ], child: ShowDetailBottomSheet(controller: controller));
      },
    );
  }

  const ShowDetailBottomSheet({
    Key? key,
    this.controller,
  }) : super(key: key);

  final ScrollController? controller;

  @override
  State<ShowDetailBottomSheet> createState() => _ShowDetailBottomSheetState();
}

class _ShowDetailBottomSheetState extends State<ShowDetailBottomSheet> {
  //=

  ShowDetailModel get showDetailModel => context.read<ShowDetailModel>();

  @override
  void initState() {
    super.initState();

    /// Stop Audio Playback
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      locator<AudioPlaybackActionsModel>().stopAudioPlayback();
    });

    /// Initialize Show Detail Model
    showDetailModel.init(onShowAvailable: (show) {
      showDetailModel.updateSubtitle(context);

      /// Only load the Show for playback if all of below
      /// conditions are satisfied:
      /// 1. Show is either free, or purchased
      /// 2. Show has started (based on start date-time)
      /// 3. Show has a video/stream resolution
      if (show.isFreeOrPurchased && !show.hasNotStarted && show.hasUrl) {
        final videoItem = VideoItem.fromShow(show);
        videoPlayerManager.startPlayback(videoItem: videoItem);
      }
    });

    /// Listen to changes in Video Item
    videoPlayerManager.videoItemNotifier.addListener(_videoItemListener);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(children: [
          Selector<ShowDetailModel, Result<Show>?>(
              selector: (_, model) => model.showResult,
              builder: (_, result, __) {
                final widget = _buildShowResultHandler();
                if (widget != null) {
                  return VideoPagePlaceholderBuilder(
                      title: showDetailModel.title,
                      subtitle: showDetailModel.subtitle,
                      thumbnail: showDetailModel.thumbnail,
                      photoKind: PhotoKind.show,
                      child: widget);
                }

                return VideoPageContentBuilder(
                    pageInterface: showDetailModel.pageInterface!,
                    onOptionsTap: _onShowOptionsTapped,
                    onRefresh: showDetailModel.fetchShow);
              }),
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: VideoPageTopBar(onBackTap: () {
                return RootNavigation.popUntilRoot(context);
              }))
        ]),
      ),
    );
  }

  @override
  void dispose() {
    videoPlayerManager.videoItemNotifier.removeListener(_videoItemListener);
    super.dispose();
  }

  void _videoItemListener() {
    final videoItem = videoPlayerManager.videoItemNotifier.value;
    if (videoItem == null) {
      RootNavigation.pop(context);
    }
  }

  Widget? _buildShowResultHandler() {
    final result = showDetailModel.showResult;
    if (result == null) {
      return const LoadingIndicator();
    }

    if (!result.isSuccess()) {
      return ErrorIndicator(
          error: result.error(),
          onTryAgain: showDetailModel.fetchShow,
          padding: EdgeInsets.zero);
    }

    final show = result.data();
    if (!show.isFreeOrPurchased) {
      return Button(
          alignment: Alignment.center,
          height: ComponentSize.large.r,
          onPressed: _onWatchShowButtonTapped,
          text: LocaleResources.of(context).watchTheShow,
          type: ButtonType.primary);
    }

    if (show.hasNotStarted) {
      return ErrorIndicator(
          error: LocaleResources.of(context).errorShowNotStarted(
              show.startDateTime.toDefaultTimeFormat(),
              show.startDateTime.toDefaultDateFormat()),
          onTryAgain: showDetailModel.fetchShow,
          padding: EdgeInsets.zero,
          showErrorMessageOnNewLine: true);
    }

    if (!show.hasUrl) {
      return ErrorIndicator(
          error: LocaleResources.of(context).errorShowUnavailable,
          onTryAgain: showDetailModel.fetchShow,
          padding: EdgeInsets.zero,
          showErrorMessageOnNewLine: true);
    }

    return null;
  }

  void _onWatchShowButtonTapped() {
    final show = showDetailModel.show;
    if (show == null) return;

    if (!show.isFreeOrPurchased) {
      PurchaseShowBottomSheet.showBottomSheet(context, show: show);
      return;
    }

    showDetailModel.fetchShow();
  }

  void _onShowOptionsTapped() async {
    final show = showDetailModel.show;
    if (show == null) return;

    videoPlayerManager.pauseUntil(() async {
      await VideoPlaybackSettingsBottomSheet.show(
        context,
        onReportTap: _onReportButtonTapped,
      );
    });
  }

  void _onReportButtonTapped() {
    final show = showDetailModel.show;
    if (show == null) return;

    RootNavigation.popUntilRoot(context);

    final args = ReportContentArgs(content: ReportableContent.fromShow(show));
    DashboardNavigation.pushNamed(context, Routes.reportContent,
        arguments: args);
  }
}
