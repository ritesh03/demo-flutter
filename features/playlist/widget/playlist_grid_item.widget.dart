import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';
import 'package:kwotmusic/features/playlist/playlist_actions.model.dart';

class PlaylistGridItem extends StatelessWidget {
  const PlaylistGridItem({
    Key? key,
    required this.width,
    required this.playlist,
    required this.onTap,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  final double width;
  final Playlist playlist;
  final VoidCallback onTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
        onPressed: onTap,
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
        child: Photo.playlist(
          playlist.images.isEmpty ? null : playlist.images.first,
          options: PhotoOptions(
              width: width,
              height: width,
              borderRadius: BorderRadius.circular(ComponentRadius.normal.r)),
        ));
  }

  Widget _buildTitle() {
    return SizedBox(
        height: ComponentSize.smaller.h,
        child: Text(playlist.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyles.boldBody));
  }

  Widget _buildSubtitle(BuildContext context) {
    final text = locator<PlaylistActionsModel>()
        .generateCompactPlaylistSubtitle(context,
            duration: playlist.duration, trackCount: playlist.totalTracks);
    return Text(text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.heading6
            .copyWith(color: DynamicTheme.get(context).neutral10()));
  }
}
