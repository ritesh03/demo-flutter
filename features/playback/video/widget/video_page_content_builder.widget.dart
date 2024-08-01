import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/app_config.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/feed/feed_routing.dart';
import 'package:kwotmusic/components/widgets/feed/feed_sliver_list.widget.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/playback/playback.dart';
import 'package:kwotmusic/features/playback/video/fullscreen/video_page_interface.dart';
import 'package:kwotmusic/features/playback/video/widget/video_page_live_chat_panel.dart';

import 'video_page_artist_bar.widget.dart';
import 'video_page_comments_bar.widget.dart';
import 'video_page_comments_panel.dart';
import 'video_page_options_bar.widget.dart';
import 'video_page_player_bar.widget.dart';
import 'video_page_subtitle_bar.widget.dart';
import 'video_page_title_bar.widget.dart';

class VideoPageContentBuilder extends StatefulWidget {
  const VideoPageContentBuilder({
    Key? key,
    required this.pageInterface,
    required this.onOptionsTap,
    required this.onRefresh,
  }) : super(key: key);

  final VideoPageInterface pageInterface;
  final VoidCallback onOptionsTap;
  final VoidCallback onRefresh;

  @override
  State<VideoPageContentBuilder> createState() =>
      _VideoPageContentBuilderState();
}

class _VideoPageContentBuilderState extends State<VideoPageContentBuilder> {
  double get progressBarHeight => ComponentSize.smallest.r;

  late _FeedRouting _feedRouting;

  @override
  initState() {
    super.initState();
    _feedRouting = _FeedRouting();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final aspectWidth = size.width;
    final aspectHeight = aspectWidth / AppConfig.videoPlaybackAspectRatio;

    return Stack(children: [
      Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: aspectHeight,
          child: VideoPagePlayerBar(pageInterface: widget.pageInterface)),
      Positioned(
          left: 0,
          top: aspectHeight,
          right: 0,
          bottom: 0,
          child: _buildItemList(context)),
      Positioned(
          left: 0,
          right: 0,
          top: aspectHeight,
          bottom: 0,
          child: _buildLiveChatPanel()),
      Positioned(
          left: 0,
          right: 0,
          top: aspectHeight,
          bottom: 0,
          child: _buildCommentsPanel()),
      Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: aspectHeight + (progressBarHeight / 2),
          child: VideoPlaybackControls(
              onExpandButtonTap: _onExpandButtonTap,
              onOptionsButtonTap: widget.onOptionsTap,
              progressBarHeight: progressBarHeight)),
    ]);
  }

  Widget _buildItemList(BuildContext context) {
    return RefreshIndicator(
      color: DynamicTheme.get(context).secondary100(),
      backgroundColor: DynamicTheme.get(context).black(),
      onRefresh: () => Future.sync(widget.onRefresh),
      child: CustomScrollView(slivers: [
        SliverToBoxAdapter(child: _buildDetailHeader()),
        _buildFeedSliverList(),
        SliverToBoxAdapter(child: SizedBox(height: ComponentInset.large.r)),
      ]),
    );
  }

  Widget _buildDetailHeader() {
    final spacing = ComponentInset.normal.r;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(height: ComponentInset.normal.h),
      Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing),
          child: VideoPageTitleBar(pageInterface: widget.pageInterface)),
      Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing),
          child: VideoPageSubtitleBar(pageInterface: widget.pageInterface)),
      SizedBox(height: ComponentInset.normal.h),
      VideoPageOptionsBar(
          pageInterface: widget.pageInterface,
          padding: EdgeInsets.symmetric(horizontal: spacing)),
      SizedBox(height: ComponentInset.normal.h),
      Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing),
          child: VideoPageArtistBar(pageInterface: widget.pageInterface)),
      SizedBox(height: ComponentInset.normal.h),
      Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing),
          child: _buildCommentsBar()),
    ]);
  }

  Widget _buildFeedSliverList() {
    final feeds = widget.pageInterface.getFeeds();
    if (feeds.isEmpty) {
      return const SliverToBoxAdapter();
    }

    return FeedSliverList(feeds: feeds, routing: _feedRouting);
  }

  Widget _buildLiveChatPanel() {
    return LayoutBuilder(builder: (_, constraints) {
      return ValueListenableBuilder<LiveStreamMode>(
          valueListenable: widget.pageInterface.liveStreamModeNotifier,
          builder: (_, mode, __) {
            if (mode == LiveStreamMode.none) return Container();
            return VideoPageLiveChatPanel(
              liveStreamMode: mode,
              maxHeight: constraints.maxHeight,
              pageInterface: widget.pageInterface,
              panelController: widget.pageInterface.liveChatPanelController,
              onClose: widget.pageInterface.onCloseLiveChatPanel,
            );
          });
    });
  }

  Widget _buildCommentsPanel() {
    return LayoutBuilder(builder: (_, constraints) {
      return VideoPageCommentsPanel(
        maxHeight: constraints.maxHeight,
        pageInterface: widget.pageInterface,
        panelController: widget.pageInterface.commentsPanelController,
        onClose: widget.pageInterface.onCloseCommentsPanel,
      );
    });
  }

  Widget _buildCommentsBar() {
    return ValueListenableBuilder<LiveStreamMode>(
        valueListenable: widget.pageInterface.liveStreamModeNotifier,
        builder: (_, mode, __) {
          if (mode == LiveStreamMode.active) return Container();
          return VideoPageCommentsBar(
              pageInterface: widget.pageInterface,
              onTap: widget.pageInterface.onOpenCommentsPanel);
        });
  }

  void _onExpandButtonTap() {
    widget.pageInterface.onCloseLiveChatPanel();
    widget.pageInterface.onCloseCommentsPanel();
    videoPlayerManager.toggleFullScreen();
  }
}

class _FeedRouting extends FeedRouting {
  @override
  void handleSeeAllTap(
    BuildContext context, {
    required Feed feed,
  }) {
    RootNavigation.popUntilRoot(context);
    super.handleSeeAllTap(context, feed: feed);
  }
}
