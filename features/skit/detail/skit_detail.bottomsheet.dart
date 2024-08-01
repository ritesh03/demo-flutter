import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/material_bottom_sheet.dart';
import 'package:kwotmusic/components/widgets/indicator/indicators.dart';
import 'package:kwotmusic/components/widgets/photo/photo_kind.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/misc/report/report_content.model.dart';
import 'package:kwotmusic/features/playback/audio/audio_playback_actions.model.dart';
import 'package:kwotmusic/features/playback/playback.dart';
import 'package:kwotmusic/features/playback/video/widget/video_page_content_builder.widget.dart';
import 'package:kwotmusic/features/playback/video/widget/video_page_placeholder_info.widget.dart';
import 'package:kwotmusic/features/playback/video/widget/video_page_top_bar.widget.dart';
import 'package:kwotmusic/features/skit/skit_actions.model.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:provider/provider.dart';

import 'skit_detail.model.dart';

class SkitDetailBottomSheet extends StatefulWidget {
  //=
  static Future showBottomSheet(
    BuildContext context, {
    required SkitDetailArgs args,
  }) {
    return showMaterialBottomSheet<void>(
      context,
      backgroundColor: DynamicTheme.get(context).background(),
      borderRadius: BorderRadius.zero,
      margin: EdgeInsets.zero,
      builder: (context, controller) {
        return MultiProvider(providers: [
          ChangeNotifierProvider(create: (_) => SkitDetailModel(args: args)),
          ChangeNotifierProvider(create: (_) => VideoControlsVisibilityModel()),
        ],
            child: SkitDetailBottomSheet(controller: controller));
      },
    );
  }

  const SkitDetailBottomSheet({
    Key? key,
    this.controller,
  }) : super(key: key);

  final ScrollController? controller;

  @override
  State<SkitDetailBottomSheet> createState() => _SkitDetailBottomSheetState();
}

class _SkitDetailBottomSheetState extends State<SkitDetailBottomSheet> {
  //=

  SkitDetailModel get skitDetailModel => context.read<SkitDetailModel>();

  @override
  void initState() {
    super.initState();

    /// Stop Audio Playback
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      locator<AudioPlaybackActionsModel>().stopAudioPlayback();
    });

    /// Initialize Skit Detail Model
    skitDetailModel.init(onSkitAvailable: (skit) {
      skitDetailModel.updateSubtitle(context);
      final videoItem = VideoItem.fromSkit(skit);
      final started = videoPlayerManager.startPlayback(videoItem: videoItem);
      if (started) {
        locator<SkitActionsModel>().notifySkitViewed(skit: skit);
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
          Selector<SkitDetailModel, Result<Skit>?>(
              selector: (_, model) => model.skitResult,
              builder: (_, result, __) {
                final widget = _buildSkitResultHandler();
                if (widget != null) {
                  return VideoPagePlaceholderBuilder(
                      title: skitDetailModel.title,
                      subtitle: skitDetailModel.subtitle,
                      thumbnail: skitDetailModel.thumbnail,
                      photoKind: PhotoKind.skit,
                      child: widget
                  );
                }

                return VideoPageContentBuilder(
                    pageInterface: skitDetailModel.pageInterface!,
                    onOptionsTap: _onSkitOptionsTapped,
                    onRefresh: skitDetailModel.fetchSkit);
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

  Widget? _buildSkitResultHandler() {
    final result = skitDetailModel.skitResult;
    if (result == null) {
      return const LoadingIndicator();
    }

    if (!result.isSuccess()) {
      return ErrorIndicator(
          error: result.error(),
          onTryAgain: skitDetailModel.fetchSkit,
          padding: EdgeInsets.zero);
    }

    return null;
  }

  void _onSkitOptionsTapped() async {
    final skit = skitDetailModel.skit;
    if (skit == null) return;

    videoPlayerManager.pauseUntil(() async {
      await VideoPlaybackSettingsBottomSheet.show(
        context,
        onReportTap: _onReportButtonTapped,
      );
    });
  }

  void _onReportButtonTapped() {
    final skit = skitDetailModel.skit;
    if (skit == null) return;

    RootNavigation.popUntilRoot(context);

    final args = ReportContentArgs(content: ReportableContent.fromSkit(skit));
    DashboardNavigation.pushNamed(context, Routes.reportContent,
        arguments: args);
  }
}
