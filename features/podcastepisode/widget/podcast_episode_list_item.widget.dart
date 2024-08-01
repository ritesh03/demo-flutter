import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';

class PodcastEpisodeListItem extends StatelessWidget {
  const PodcastEpisodeListItem({
    Key? key,
    required this.podcastEpisode,
    required this.onPodcastEpisodeTap,
  }) : super(key: key);

  final PodcastEpisode podcastEpisode;
  final Function(PodcastEpisode podcastEpisode) onPodcastEpisodeTap;

  @override
  Widget build(BuildContext context) {
    final itemHeight = ComponentSize.large.h;
    return ScaleTap(
        onPressed: () => onPodcastEpisodeTap(podcastEpisode),
        child: Container(
          height: itemHeight,
          decoration: BoxDecoration(
              color: DynamicTheme.get(context).background(),
              borderRadius: BorderRadius.circular(ComponentRadius.normal.r)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            _buildThumbnail(size: itemHeight),
            SizedBox(width: ComponentInset.small.w),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [_buildTitle(), _buildSubtitle(context)])),
            SizedBox(width: ComponentInset.small.w),
          ]),
        ));
  }

  Widget _buildThumbnail({required double size}) {
    return Photo.podcastEpisode(
      podcastEpisode.thumbnail,
      options: PhotoOptions(
        width: size,
        height: size,
        borderRadius: BorderRadius.circular(ComponentRadius.normal.r),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      podcastEpisode.title,
      overflow: TextOverflow.ellipsis,
      style: TextStyles.boldBody,
      maxLines: 1,
    );
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
