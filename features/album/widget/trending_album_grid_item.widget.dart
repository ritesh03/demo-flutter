import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';
import 'package:kwotmusic/features/playback/widget/playbutton/album_play_button.widget.dart';

class TrendingAlbumGridItem extends StatelessWidget {
  const TrendingAlbumGridItem({
    Key? key,
    required this.width,
    required this.album,
    required this.onTap,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  final double width;
  final Album album;
  final Function(Album) onTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
        onPressed: () => onTap(album),
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
        child: Stack(children: [
          Positioned.fill(
            child: Photo.album(
              album.images.isEmpty ? null : album.images.first,
              options: PhotoOptions(
                  width: width,
                  height: width,
                  borderRadius:
                      BorderRadius.circular(ComponentRadius.normal.r)),
            ),
          ),
          Positioned(
            bottom: ComponentInset.small.r,
            right: ComponentInset.small.r,
            child: AlbumPlayButton(album: album, size: ComponentSize.normal.r),
          )
        ]));
  }

  Widget _buildTitle() {
    return SizedBox(
        height: ComponentSize.smaller.h,
        child: Text(album.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyles.boldBody));
  }

  Widget _buildSubtitle(BuildContext context) {
    return Text(
      album.subtitle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyles.heading6
          .copyWith(color: DynamicTheme.get(context).neutral10()),
    );
  }

  void _onPlayAlbumTap() {
    // TODO: Play albums
  }
}
