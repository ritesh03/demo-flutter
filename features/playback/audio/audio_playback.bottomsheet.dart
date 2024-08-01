import 'dart:async';

import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/api/audioplayer.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/blocking_progress.dialog.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/material_bottom_sheet.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/glow/glow.widget.dart';
import 'package:kwotmusic/components/widgets/notificationbar/notification_bar.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/playback/audio/options/audio_playback_options.bottomsheet.dart';
import 'package:kwotmusic/features/playback/playback.dart';

import 'widget/music_playback_bar.widget.dart';
import 'widget/podcast_episode_playback_bar.widget.dart';
import 'widget/radio_station_playback_bar.widget.dart';

class AudioPlaybackBottomSheet extends StatefulWidget {
  //=
  static Future show(BuildContext context) {
    return showMaterialBottomSheet<void>(
      context,
      backgroundColor: DynamicTheme.get(context).background(),
      borderRadius: BorderRadius.zero,
      margin: EdgeInsets.zero,
      builder: (_, controller) =>
          AudioPlaybackBottomSheet(controller: controller),
    );
  }

  const AudioPlaybackBottomSheet({
    Key? key,
    this.controller,
  }) : super(key: key);

  final ScrollController? controller;

  @override
  State<AudioPlaybackBottomSheet> createState() =>
      _AudioPlaybackBottomSheetState();
}

class _AudioPlaybackBottomSheetState extends State<AudioPlaybackBottomSheet> {
  //=
  late StreamSubscription _playbackItemStreamSubscription;

  @override
  void initState() {
    super.initState();

    _playbackItemStreamSubscription =
        audioPlayerManager.playbackItemStream.listen((playbackItem) {
      if (playbackItem == null) {
        RootNavigation.popUntilRoot(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const _TopBar(),
      SizedBox(height: ComponentInset.normal.h),

      // ARTWORK
      Stack(alignment: Alignment.center, children: [
        const Positioned.fill(child: Glow()),
        PlayerArtwork(size: 264.r)
      ]),
      SizedBox(height: 48.h),

      // TITLE BAR
      Padding(
          padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
          child: PlayerTitleBar(onLikeTap: _onLikeButtonTapped)),
      const Spacer(),

      // PROGRESS BAR
      Padding(
          padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
          child: const AudioPlayerSeekBar()),
      SizedBox(height: ComponentInset.larger.r),
      const _BottomBar(),
    ]);
  }

  @override
  void dispose() {
    _playbackItemStreamSubscription.cancel();
    super.dispose();
  }

  void _onLikeButtonTapped() async {
    final playbackItem = audioPlayerManager.playbackItemNotifier.value;
    if (playbackItem == null) return;

    showBlockingProgressDialog(context);
    final result = await locator<PlaybackItemActionsModel>()
        .onLikeButtonTapped(playbackItem);

    if (!mounted) return;
    hideBlockingProgressDialog(context);

    if (result.isSuccess()) {
      audioPlayerManager.updatePlaybackInfo(result.data());
    } else {
      showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()));
    }
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      AppIconButton(
          width: ComponentSize.large.r,
          height: ComponentSize.large.r,
          assetColor: DynamicTheme.get(context).neutral20(),
          assetPath: Assets.iconArrowDown,
          padding: EdgeInsets.all(ComponentInset.small.r),
          onPressed: () => RootNavigation.pop(context)),
      const Spacer(),
      AppIconButton(
          width: ComponentSize.large.r,
          height: ComponentSize.large.r,
          assetColor: DynamicTheme.get(context).neutral10(),
          assetPath: Assets.iconOptions,
          padding: EdgeInsets.all(ComponentInset.small.r),
          onPressed: () => _onOptionsButtonTapped(context)),
    ]);
  }

  void _onOptionsButtonTapped(BuildContext context) {
    final playbackItem = audioPlayerManager.playbackItemNotifier.value;
    if (playbackItem == null) return;

    AudioPlaybackOptionsBottomSheet.show(
      context,
      item: playbackItem,
      showRemoveFromQueueOption: false,
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
      height: 152.r,
      child: StreamBuilder<PlaybackKind?>(
          stream: audioPlayerManager.playbackKindStream,
          builder: (_, snapshot) {
            final kind = snapshot.data;
            switch (kind) {
              case null:
                return const SizedBox.shrink();
              case PlaybackKind.podcastEpisode:
              case PlaybackKind.skit:
                return const PodcastEpisodePlaybackBar();
              case PlaybackKind.radioStation:
                return const RadioStationPlaybackBar();
              case PlaybackKind.track:
                return const MusicPlaybackBar();
            }
          }),
    );
  }
}
