import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/features/playback/playback.dart';

class PlaybackInfoCompactPreview extends StatelessWidget {
  const PlaybackInfoCompactPreview({
    Key? key,
    this.margin,
    this.padding,
  }) : super(key: key);

  final EdgeInsets? margin;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: margin,
        padding: padding,
        child: Row(children: [
          PlayerArtwork(size: 104.r),
          SizedBox(width: ComponentInset.normal.w),
          Expanded(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle(context),
                  _buildSubtitle(context),
                ]),
          )
        ]));
  }

  Widget _buildTitle(BuildContext context) {
    return ValueListenableBuilder<String?>(
        valueListenable: audioPlayerManager.titleNotifier,
        builder: (_, title, __) {
          return Text(title ?? "",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.boldHeading3);
        });
  }

  Widget _buildSubtitle(BuildContext context) {
    return ValueListenableBuilder<String?>(
        valueListenable: audioPlayerManager.subtitleNotifier,
        builder: (_, subtitle, __) {
          if (subtitle == null || subtitle.isEmpty) return Container();

          return SizedBox(
              height: ComponentSize.smaller.h,
              child: Text(
                subtitle,
                style: TextStyles.heading5.copyWith(
                  color: DynamicTheme.get(context).neutral10(),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ));
        });
  }
}
