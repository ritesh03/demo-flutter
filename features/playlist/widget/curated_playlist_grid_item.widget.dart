import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';
import 'package:kwotmusic/util/util.dart';

class CuratedPlaylistGridItem extends StatelessWidget {
  const CuratedPlaylistGridItem({
    Key? key,
    required this.width,
    required this.playlist,
    required this.onTap,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  final double width;
  final Playlist playlist;
  final Function(Playlist playlist) onTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
        onPressed: () => onTap(playlist),
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
                  SizedBox(height: ComponentInset.small.r),
                  _buildSummary(context),
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

  Widget _buildSummary(BuildContext context) {
    return Text(
      withExtraNextLineCharacters(playlist.name, 2),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyles.body.copyWith(color: DynamicTheme.get(context).white()),
    );
  }
}
