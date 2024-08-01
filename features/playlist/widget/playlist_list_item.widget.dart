import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';
import 'package:kwotmusic/l10n/localizations.dart';

class PlaylistListItem extends StatelessWidget {
  const PlaylistListItem({
    Key? key,
    required this.playlist,
    required this.onTap,
    this.onOptionsTap,
  }) : super(key: key);

  final Playlist playlist;
  final VoidCallback onTap;
  final VoidCallback? onOptionsTap;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: _buildContent(context)),
      _buildOptionsButton(context)
    ]);
  }

  Widget _buildContent(BuildContext context) {
    return ScaleTap(
        onPressed: onTap,
        scaleMinValue: 0.99,
        opacityMinValue: 0.7,
        child: Container(
            color: Colors.transparent,
            child: Row(children: [
              _buildPhoto(),
              SizedBox(width: ComponentInset.small.w),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [_buildTitle(), _buildSubtitle(context)]),
              ),
            ])));
  }

  Widget _buildPhoto() {
    return Photo.playlist(
      playlist.images.isEmpty ? null : playlist.images.first,
      options: PhotoOptions(
          width: ComponentSize.large.r,
          height: ComponentSize.large.r,
          borderRadius: BorderRadius.circular(ComponentRadius.normal.r)),
    );
  }

  Widget _buildTitle() {
    return SizedBox(
        height: ComponentSize.smaller.h,
        child: Text(playlist.name,
            style: TextStyles.boldBody,
            overflow: TextOverflow.ellipsis,
            maxLines: 1));
  }

  Widget _buildSubtitle(BuildContext context) {
    final localization = LocaleResources.of(context);
    String subtitle = localization.integerSongCountFormat(playlist.totalTracks);
    if (!playlist.public) {
      subtitle = "${localization.private} · $subtitle";
    }

    return SizedBox(
        height: ComponentSize.smallest.h,
        child: Text(subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyles.heading6
                .copyWith(color: DynamicTheme.get(context).neutral10())));
  }

  Widget _buildOptionsButton(BuildContext context) {
    if (onOptionsTap != null) {
      return AppIconButton(
          width: ComponentSize.normal.r,
          height: ComponentSize.small.r,
          assetPath: Assets.iconOptions,
          assetColor: DynamicTheme.get(context).white(),
          onPressed: onOptionsTap);
    } else {
      return SizedBox(
          width: ComponentSize.normal.r, height: ComponentSize.small.r);
    }
  }
}
