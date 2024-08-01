import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/app_config.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';

class VideoPagePlaceholderBuilder extends StatelessWidget {
  const VideoPagePlaceholderBuilder({
    Key? key,
    this.title,
    this.subtitle,
    this.thumbnail,
    required this.photoKind,
    required this.child,
  }) : super(key: key);

  final String? title;
  final String? subtitle;
  final String? thumbnail;
  final PhotoKind photoKind;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _buildThumbnail(),
      Padding(
          padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: ComponentInset.normal.h),
                _buildTitle(context),
                _buildSubtitle(context),
                SizedBox(height: ComponentInset.larger.h),
                child,
              ])),
    ]);
  }

  Widget _buildThumbnail() {
    return AspectRatio(
        aspectRatio: AppConfig.videoPlaybackAspectRatio,
        child: Photo.kind(
          thumbnail,
          kind: photoKind,
          options: PhotoOptions(width: 1.sw),
        ));
  }

  Widget _buildTitle(BuildContext context) {
    return Text(title ?? "",
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.boldHeading2
            .copyWith(color: DynamicTheme.get(context).white()));
  }

  Widget _buildSubtitle(BuildContext context) {
    final subtitle = this.subtitle;
    if (subtitle == null) return Container();
    return Text(subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.body
            .copyWith(color: DynamicTheme.get(context).neutral10()));
  }
}
