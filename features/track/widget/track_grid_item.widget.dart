import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';
import 'package:kwotmusic/components/widgets/photo/stacked_photos.dart';
import 'package:kwotmusic/features/playback/audio/audio_playback_actions.model.dart';

class TrackGridItem extends StatelessWidget {
  const TrackGridItem({
    Key? key,
    required this.width,
    required this.track,
    this.onTap,
    this.showCreatorThumbnail = false,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  final double width;
  final Track track;
  final bool Function(Track)? onTap;
  final bool showCreatorThumbnail;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
        onPressed: _onTap,
        child: Container(
            width: width,
            padding: padding,

            /// For ScaleTap to recognize whole item as tappable
            color: Colors.transparent,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildThumbnail(),
                  SizedBox(height: ComponentInset.small.h),
                  _buildTitle(),
                  _buildSubtitle(context),
                ])));
  }

  Widget _buildThumbnail() {
    return AspectRatio(
        aspectRatio: 1,
        child: Photo.track(
          track.images.isEmpty ? null : track.images.first,
          options: PhotoOptions(
              width: width,
              height: width,
              borderRadius: BorderRadius.circular(ComponentRadius.normal.r)),
        ));
  }

  Widget _buildTitle() {
    return SizedBox(
        height: ComponentSize.smaller.h,
        child: Text(track.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyles.boldBody));
  }

  Widget _buildSubtitle(BuildContext context) {
    final creatorNameWidget = Text(track.subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.heading6
            .copyWith(color: DynamicTheme.get(context).neutral10()));

    if (!showCreatorThumbnail) {
      return creatorNameWidget;
    }

    final creatorThumbnailSize = ComponentSize.smaller.r;
    return Row(children: [
      StackedPhotosWidget(
        PhotoKind.artist,
        photoPaths: track.artists.map((artist) => artist.thumbnail).toList(),
        size: creatorThumbnailSize,
        textStyle: TextStyles.boldCaption
            .copyWith(color: DynamicTheme.get(context).neutral10()),
      ),
      SizedBox(width: ComponentInset.small.w),
      Expanded(child: creatorNameWidget)
    ]);
  }

  void _onTap() {
    bool handled = false;
    if (onTap != null) {
      handled = onTap!(track);
    }

    if (handled) return;

    locator<AudioPlaybackActionsModel>().playTrack(track);
  }
}
