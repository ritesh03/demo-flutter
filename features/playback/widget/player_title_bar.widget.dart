import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/features/playback/playback.dart';

class PlayerTitleBar extends StatelessWidget {
  const PlayerTitleBar({
    Key? key,
    required this.onLikeTap,
  }) : super(key: key);

  final VoidCallback onLikeTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 90.h,
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                _buildTitle(context),
                _buildSubtitle(context),
              ])),
          SizedBox(width: ComponentInset.normal.r),
          _buildLikeButton(context)
        ]));
  }

  Widget _buildTitle(BuildContext context) {
    return ValueListenableBuilder<String?>(
        valueListenable: audioPlayerManager.titleNotifier,
        builder: (_, title, __) {
          return Text(title ?? "",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.boldHeading2);
        });
  }

  Widget _buildSubtitle(BuildContext context) {
    return SizedBox(
        height: ComponentSize.smaller.h,
        child: ValueListenableBuilder<String?>(
            valueListenable: audioPlayerManager.subtitleNotifier,
            builder: (_, subtitle, __) {
              return Text(subtitle ?? "",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.heading4
                      .copyWith(color: DynamicTheme.get(context).neutral10()));
            }));
  }

  Widget _buildLikeButton(BuildContext context) {
    return ValueListenableBuilder<bool>(
        valueListenable: audioPlayerManager.isFavoriteNotifier,
        builder: (_, isFavorite, __) {
          return AppIconButton(
              width: ComponentSize.small.r,
              height: ComponentSize.small.r,
              assetColor: DynamicTheme.get(context).neutral10(),
              assetPath: isFavorite
                  ? Assets.iconHeartFilled
                  : Assets.iconHeartOutline,
              onPressed: onLikeTap);
        });
  }
}
