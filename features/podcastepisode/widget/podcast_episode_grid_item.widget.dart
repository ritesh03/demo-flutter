import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';

class PodcastEpisodeGridItem extends StatelessWidget {
  const PodcastEpisodeGridItem({
    Key? key,
    required this.width,
    required this.podcastEpisode,
    required this.onPodcastEpisodeTap,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  final double width;
  final PodcastEpisode podcastEpisode;
  final Function(PodcastEpisode podcastEpisode) onPodcastEpisodeTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
        onPressed: () => onPodcastEpisodeTap(podcastEpisode),
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
        child: Photo.podcastEpisode(
          podcastEpisode.thumbnail,
          options: PhotoOptions(
            width: width,
            height: width,
            borderRadius: BorderRadius.circular(ComponentRadius.normal.r),
          ),
        ));
  }

  Widget _buildTitle() {
    return SizedBox(
        height: ComponentSize.smaller.h,
        child: Text(
          podcastEpisode.title,
          overflow: TextOverflow.ellipsis,
          style: TextStyles.boldBody,
          maxLines: 1,
        ));
  }

  Widget _buildSubtitle(BuildContext context) {
    return SizedBox(
        height: ComponentSize.smallest.h,
        child: Text(podcastEpisode.subtitle,
            overflow: TextOverflow.ellipsis,
            style: TextStyles.heading6
                .copyWith(color: DynamicTheme.get(context).neutral10()),
            maxLines: 1));
  }
}
