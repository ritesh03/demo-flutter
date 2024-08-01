import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/button/buttons.dart';
import 'package:kwotmusic/components/widgets/glow/glow.widget.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';
import 'package:kwotmusic/features/playback/playback.dart';
import 'package:kwotmusic/features/playback/widget/playbutton/podcast_episode_play_button.widget.dart';
import 'package:kwotmusic/util/util.dart';

class PodcastEpisodeDetailItem extends StatelessWidget {
  const PodcastEpisodeDetailItem({
    Key? key,
    required this.episode,
    required this.onTap,
    required this.onOptionsTap,
    required this.onDownloadTap,
    required this.onShareTap,
  }) : super(key: key);

  final PodcastEpisode episode;
  final VoidCallback onTap;
  final VoidCallback onOptionsTap;
  final VoidCallback onDownloadTap;
  final VoidCallback onShareTap;

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.center, children: [
      Glow(blurRadius: 50.r, spreadRadius: 24.h),
      Container(
          decoration: BoxDecoration(
              color: DynamicTheme.get(context).black(),
              borderRadius: BorderRadius.circular(ComponentRadius.normal.r)),
          child: TappableButton(
              onTap: onTap,
              child: Padding(
                  padding: EdgeInsets.all(ComponentInset.normal.r),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context),
                        SizedBox(height: ComponentInset.small.h),
                        _buildDescription(context),
                        SizedBox(height: ComponentInset.small.h),
                        _buildInfo(context),
                        SizedBox(height: ComponentInset.small.h),
                        _buildFooter(context),
                      ])))),
      Positioned(
          bottom: 0, left: 0, right: 0, child: _buildProgressBar(context))
    ]);
  }

  Widget _buildHeader(BuildContext context) {
    final size = ComponentSize.large.r;
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Photo.podcastEpisode(
        episode.thumbnail,
        options: PhotoOptions(
            width: size,
            height: size,
            borderRadius: BorderRadius.circular(ComponentRadius.normal.r)),
      ),
      SizedBox(width: ComponentInset.small.w),
      Expanded(
        child: Text(episode.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyles.boldBody),
      ),
      SizedBox(width: ComponentInset.small.w),
      AppIconButton(
          width: size / 2,
          height: size,
          assetColor: DynamicTheme.get(context).white(),
          assetPath: Assets.iconOptions,
          padding: EdgeInsets.all(ComponentInset.small.r),
          onPressed: onOptionsTap)
    ]);
  }

  Widget _buildDescription(BuildContext context) {
    return Text(episode.description ?? "No description",
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.body
            .copyWith(color: DynamicTheme.get(context).neutral10()));
  }

  Widget _buildInfo(BuildContext context) {
    final dateText = episode.createdAt.toDefaultDateFormat();
    final durationText = episode.duration.toCompactEpisodeDuration();
    String text = "$dateText · $durationText";
    return Text(text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.heading6
            .copyWith(color: DynamicTheme.get(context).neutral20()));
  }

  Widget _buildFooter(BuildContext context) {
    final size = ComponentSize.small.r;
    return Row(children: [
      // AppIconButton(
      //     width: size,
      //     height: size,
      //     assetColor: DynamicTheme.get(context).white(),
      //     assetPath: Assets.iconDownload,
      //     onPressed: onDownloadTap),
      // SizedBox(width: ComponentInset.normal.w),
      AppIconButton(
          width: size,
          height: size,
          assetColor: DynamicTheme.get(context).white(),
          assetPath: Assets.iconShare,
          onPressed: onShareTap),
      const Spacer(),
      PodcastEpisodePlayButton(episode: episode, size: ComponentSize.normal.r),
    ]);
  }

  Widget _buildProgressBar(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(ComponentRadius.normal.r),
                bottomRight: Radius.circular(ComponentRadius.normal.r))),
        clipBehavior: Clip.antiAlias,
        child: AudioPlayerSeekBar(
          compact: true,
          trackColor: DynamicTheme.get(context).primary20(),
          scopeId: episode.id,
        ));
  }
}
