import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/photo/svg_asset_photo.dart';
import 'package:kwotmusic/features/playback/audio/queue/playing_queue.bottomsheet.dart';
import 'package:kwotmusic/features/playback/playback.dart';
import 'package:kwotmusic/l10n/localizations.dart';

class MusicPlaybackBar extends StatelessWidget {
  const MusicPlaybackBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Column(children: [
        const _PlaybackBar(),
        SizedBox(height: ComponentInset.medium.r),
        const _PlaybackOptionsBar(),
      ]),
      const Positioned(
          bottom: 0, left: 0, right: 0, child: _PlaybackLyricsBar()),
    ]);
  }
}

class _PlaybackBar extends StatelessWidget {
  const _PlaybackBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const PlaybackShuffleButton(),
      const Spacer(),
      PlaybackPreviousItemButton(
        notifier: audioPlayerManager.canPlayPreviousItemNotifier,
        onTap: audioPlayerManager.previous,
      ),
      SizedBox(width: ComponentInset.medium.w),
      AudioPlayButton(size: 56.r),
      SizedBox(width: ComponentInset.medium.w),
      PlaybackNextItemButton(
        notifier: audioPlayerManager.canPlayNextItemNotifier,
        onTap: audioPlayerManager.next,
      ),
      const Spacer(),
      const PlaybackRepeatButton(),
    ]);
  }
}

class _PlaybackOptionsBar extends StatelessWidget {
  const _PlaybackOptionsBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      // TODO: space for external-devices option
      //  Also, balances items to be centered in this row
      SizedBox(width: ComponentSize.small.r),
      const Spacer(),
      PlaybackPlayingQueueButton(
          onTap: () => _onPlayQueueButtonTapped(context)),
    ]);
  }

  void _onPlayQueueButtonTapped(BuildContext context) {
    PlayingQueueBottomSheet.show(context);
  }
}

/// TODO: Reimplement when lyrics are available
class _PlaybackLyricsBar extends StatelessWidget {
  const _PlaybackLyricsBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 48.r);
    // return Center(
    //   child: ScaleTap(
    //     scaleMinValue: 1,
    //     opacityMinValue: 0.85,
    //     onPressed: () {},
    //     child: Container(
    //       width: 240.r,
    //       height: 48.r,
    //       color: DynamicTheme.get(context).black(),
    //       child: Column(mainAxisSize: MainAxisSize.min, children: [
    //         Expanded(
    //           child: Align(
    //             alignment: Alignment.center,
    //             child: Text(
    //               LocaleResources.of(context).lyrics,
    //               maxLines: 1,
    //               overflow: TextOverflow.ellipsis,
    //               style: TextStyles.heading6
    //                   .copyWith(color: DynamicTheme.get(context).white()),
    //             ),
    //           ),
    //         ),
    //         SvgAssetPhoto(Assets.iconArrowUp,
    //             width: ComponentSize.smaller.r,
    //             height: ComponentSize.smaller.r,
    //             color: DynamicTheme.get(context).neutral10()),
    //       ]),
    //     ),
    //   ),
    // );
  }
}
