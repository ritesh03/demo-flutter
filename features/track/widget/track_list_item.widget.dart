import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';
import 'package:kwotmusic/features/playback/audio/audio_playback_actions.model.dart';
import 'package:kwotmusic/features/track/options/track_options.bottomsheet.dart';
import 'package:kwotmusic/features/track/options/track_options.model.dart';

class TrackListItem extends StatelessWidget {
  const TrackListItem({
    Key? key,
    required this.track,
    this.trailing,
    this.onTap,
    this.onOptionsButtonTap,
  }) : super(key: key);

  final Track track;
  final Widget? trailing;
  final bool Function(Track)? onTap;
  final bool Function(Track)? onOptionsButtonTap;

  @override
  Widget build(BuildContext context) {
    final size = ComponentSize.large.r;
    return Row(
      children: [
        Expanded(
          child: ScaleTap(
              onPressed: _onTrackTap,
              child: Container(
                  height: size,
                  color: Colors.transparent,
                  child: Row(children: [
                    _TrackPhoto(track: track, size: size),
                    SizedBox(width: ComponentInset.small.w),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _TrackTitle(text: track.name),
                            _TrackSubtitle(text: track.subtitle),
                          ]),
                    ),
                  ]))),
        ),
        trailing ??
            _TrackOptionsButton(
              track: track,
              size: size,
              onTap: () => _onTrackOptionsTap(context),
            )
      ],
    );
  }

  void _onTrackTap() {
    bool handled = false;
    if (onTap != null) {
      handled = onTap!(track);
    }

    if (handled) return;

    locator<AudioPlaybackActionsModel>().playTrack(track);
  }

  void _onTrackOptionsTap(BuildContext context) {
    bool handled = false;
    if (onOptionsButtonTap != null) {
      handled = onOptionsButtonTap!(track);
    }

    if (handled) return;

    final args = TrackOptionsArgs(track: track);
    TrackOptionsBottomSheet.show(context, args: args);
  }
}

class _TrackPhoto extends StatelessWidget {
  const _TrackPhoto({
    Key? key,
    required this.track,
    required this.size,
  }) : super(key: key);

  final Track track;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Photo.track(
      track.images.isEmpty ? null : track.images.first,
      options: PhotoOptions(
          width: size,
          height: size,
          borderRadius: BorderRadius.circular(ComponentRadius.normal.r)),
    );
  }
}

class _TrackTitle extends StatelessWidget {
  const _TrackTitle({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ComponentSize.smaller.r,
      child: Text(text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyles.boldBody.copyWith(
            color: DynamicTheme.get(context).white(),
          )),
    );
  }
}

class _TrackSubtitle extends StatelessWidget {
  const _TrackSubtitle({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ComponentSize.smallest.r,
      child: Text(text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyles.heading6
              .copyWith(color: DynamicTheme.get(context).neutral10())),
    );
  }
}

class _TrackOptionsButton extends StatelessWidget {
  const _TrackOptionsButton({
    Key? key,
    required this.track,
    required this.size,
    required this.onTap,
  }) : super(key: key);

  final Track track;
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
