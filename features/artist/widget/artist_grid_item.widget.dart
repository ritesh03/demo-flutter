import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';

class ArtistGridItem extends StatelessWidget {
  const ArtistGridItem({
    Key? key,
    required this.width,
    required this.artist,
    required this.onTap,
  }) : super(key: key);

  final double width;
  final Artist artist;
  final Function(Artist artist) onTap;

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
        onPressed: () => onTap(artist),
        child: Container(
            width: width,
            /// For ScaleTap to recognize whole item as tappable
            color: Colors.transparent,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildThumbnail(context),
                  SizedBox(height: ComponentInset.small.r),
                  _buildTitle(context),
                ])));
  }

  Widget _buildThumbnail(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Photo.artist(
        artist.thumbnail,
        options: const PhotoOptions(shape: BoxShape.circle),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      artist.name,
      overflow: TextOverflow.ellipsis,
      style: TextStyles.boldBody
          .copyWith(color: DynamicTheme.get(context).white()),
      textAlign: TextAlign.center,
      maxLines: 1,
    );
  }
}
