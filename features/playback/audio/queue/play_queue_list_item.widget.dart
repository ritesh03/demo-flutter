import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/api/audioplayer.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/button/buttons.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';
import 'package:kwotmusic/features/playback/audio/options/audio_playback_options.bottomsheet.dart';
import 'package:kwotmusic/features/playback/playback.dart';
import 'package:kwotmusic/util/playback_kind.ext.dart';

class PlayQueueListItem extends StatelessWidget {
  const PlayQueueListItem({
    Key? key,
    required this.playbackItem,
    this.isPlaying = false,
    this.onTap,
  }) : super(key: key);

  final PlaybackItem playbackItem;
  final bool isPlaying;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final itemHeight = ComponentSize.large.r;
    final size = itemHeight;
    return TappableButton(
        onTap: onTap,
        child: Container(
          height: itemHeight,
          decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(ComponentRadius.normal.r)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Photo.kind(
              playbackItem.artwork,
              kind: playbackItem.kind.photoKind,
              options: PhotoOptions(
                  width: size,
                  height: size,
                  borderRadius:
                      BorderRadius.circular(ComponentRadius.normal.r)),
            ),
            SizedBox(width: ComponentInset.small.w),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _PlayingQueueItemTitle(
                        text: playbackItem.title, isPlaying: isPlaying),
                    _PlayingQueueItemSubtitle(playbackItem: playbackItem),
                  ]),
            ),
            SizedBox(width: ComponentInset.small.w),
            _PlayingQueueItemOptionsButton(
                size: size,
                onTap: () {
                  AudioPlaybackOptionsBottomSheet.show(
                    context,
                    item: playbackItem,
                  );
                }),
          ]),
        ));
  }
}

class _PlayingQueueItemTitle extends StatelessWidget {
  const _PlayingQueueItemTitle({
    Key? key,
    required this.text,
    required this.isPlaying,
  }) : super(key: key);

  final String text;
  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.boldBody.copyWith(
          color: isPlaying
              ? DynamicTheme.get(context).secondary100()
              : DynamicTheme.get(context).white(),
        ));
  }
}

class _PlayingQueueItemSubtitle extends StatelessWidget {
  const _PlayingQueueItemSubtitle({
    Key? key,
    required this.playbackItem,
  }) : super(key: key);

  final PlaybackItem playbackItem;

  @override
  Widget build(BuildContext context) {
    final playbackKindStr = locator<PlaybackItemActionsModel>()
        .getPlaybackKindDisplayText(context, playbackItem.kind);

    String subtitle;
    if (playbackItem.subtitle.isEmpty) {
      subtitle = playbackKindStr;
    } else {
      subtitle = "$playbackKindStr · ${playbackItem.subtitle}";
    }

    return SizedBox(
      height: ComponentSize.smallest.h,
      child: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.heading6
            .copyWith(color: DynamicTheme.get(context).neutral10()),
      ),
    );
  }
}

class _PlayingQueueItemOptionsButton extends StatelessWidget {
  const _PlayingQueueItemOptionsButton({
    Key? key,
    required this.size,
    required this.onTap,
  }) : super(key: key);

  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppIconButton(
        width: size,
        height: size,
        padding: EdgeInsets.all(ComponentInset.small.r),
        assetPath: Assets.iconOptions,
        assetColor: DynamicTheme.get(context).white(),
        onPressed: onTap);
  }
}
