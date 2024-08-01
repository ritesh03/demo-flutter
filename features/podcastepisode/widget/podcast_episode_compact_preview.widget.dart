import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';
import 'package:kwotmusic/util/util.dart';

class PodcastEpisodeCompactPreview extends StatelessWidget {
  const PodcastEpisodeCompactPreview({
    Key? key,
    required this.episode,
    this.margin,
    this.padding,
  }) : super(key: key);

  final PodcastEpisode episode;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: margin,
        padding: padding,
        child: Row(children: [
          _buildThumbnail(),
          SizedBox(width: ComponentInset.normal.w),
          Expanded(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle(context),
                  _buildSubtitle(context),
                  _buildDate(context),
                ]),
          )
        ]));
  }

  Widget _buildThumbnail() {
    return Photo.podcastEpisode(
      episode.thumbnail,
      options: PhotoOptions(
        width: 104.r,
        height: 104.r,
        borderRadius: BorderRadius.circular(ComponentRadius.normal.r),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      episode.title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyles.boldHeading3,
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    return Text(episode.podcastTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.heading5.copyWith(
          color: DynamicTheme.get(context).neutral20(),
        ));
  }

  Widget _buildDate(BuildContext context) {
    return Text(episode.createdAt.toDefaultDateFormat(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.heading5.copyWith(
          color: DynamicTheme.get(context).neutral20(),
        ));
  }
}
