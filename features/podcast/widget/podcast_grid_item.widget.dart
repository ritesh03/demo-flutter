import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';
import 'package:kwotmusic/components/widgets/photo/stacked_photos.dart';

class PodcastGridItem extends StatelessWidget {
  const PodcastGridItem({
    Key? key,
    required this.width,
    required this.podcast,
    required this.onPodcastTap,
    this.showCreatorThumbnail = false,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  final double width;
  final Podcast podcast;
  final Function(Podcast podcast) onPodcastTap;
  final bool showCreatorThumbnail;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
        onPressed: () => onPodcastTap(podcast),
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
        child: Photo.podcast(
          podcast.thumbnail,
          options: PhotoOptions(
              width: width,
              height: width,
              borderRadius: BorderRadius.circular(ComponentRadius.normal.r)),
        ));
  }

  Widget _buildTitle() {
    return SizedBox(
        height: ComponentSize.smaller.h,
        child: Text(podcast.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyles.boldBody));
  }

  Widget _buildSubtitle(BuildContext context) {
    final creatorNameWidget = Text(
      podcast.subtitle,
      overflow: TextOverflow.ellipsis,
      style: TextStyles.heading6
          .copyWith(color: DynamicTheme.get(context).neutral10()),
      maxLines: 1,
    );

    if (!showCreatorThumbnail) {
      return creatorNameWidget;
    }

    final creatorThumbnailSize = ComponentSize.smaller.r;
    return Row(children: [
      StackedPhotosWidget(
        PhotoKind.artist,
        photoPaths: podcast.artists.map((artist) => artist.thumbnail).toList(),
        size: creatorThumbnailSize,
        textStyle: TextStyles.boldCaption
            .copyWith(color: DynamicTheme.get(context).neutral10()),
      ),
      SizedBox(width: ComponentInset.small.w),
      Expanded(child: creatorNameWidget)
    ]);
  }
}
