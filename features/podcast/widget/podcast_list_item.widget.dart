import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';

class PodcastListItem extends StatelessWidget {
  const PodcastListItem({
    Key? key,
    required this.podcast,
    required this.onPodcastTap,
  }) : super(key: key);

  final Podcast podcast;
  final Function(Podcast podcast) onPodcastTap;

  @override
  Widget build(BuildContext context) {
    final itemHeight = 80.h;
    return ScaleTap(
        onPressed: () => onPodcastTap(podcast),
        child: Container(
          height: itemHeight,

          /// For ScaleTap to recognize whole item as tappable
          color: Colors.transparent,
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
    return Photo.podcast(
      podcast.thumbnail,
      options: PhotoOptions(
          width: size,
          height: size,
          borderRadius: BorderRadius.circular(ComponentRadius.normal.r)),
    );
  }

  Widget _buildTitle() {
    return Text(
      podcast.title,
      overflow: TextOverflow.ellipsis,
      style: TextStyles.boldBody,
      maxLines: 2,
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    return SizedBox(
        height: ComponentSize.smallest.h,
        child: Text(podcast.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyles.heading6
                .copyWith(color: DynamicTheme.get(context).neutral10())));
  }
}
