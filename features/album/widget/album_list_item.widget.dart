import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';
import 'package:kwotmusic/features/album/options/album_options.bottomsheet.dart';
import 'package:kwotmusic/features/album/options/album_options.model.dart';

class AlbumListItem extends StatelessWidget {
  const AlbumListItem({
    Key? key,
    required this.album,
    required this.onTap,
  }) : super(key: key);

  final Album album;
  final ValueSetter<Album> onTap;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: _buildContent(context)),
      _buildOptionsButton(context)
    ]);
  }

  Widget _buildContent(BuildContext context) {
    return ScaleTap(
        onPressed: () => onTap(album),
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
                    children: [
                      _buildTitle(context),
                      _buildSubtitle(context),
                    ]),
              ),
            ])));
  }

  Widget _buildPhoto() {
    return Photo.album(
      album.images.isEmpty ? null : album.images.first,
      options: PhotoOptions(
          width: ComponentSize.large.r,
          height: ComponentSize.large.r,
          borderRadius: BorderRadius.circular(ComponentRadius.normal.r)),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return SizedBox(
        height: ComponentSize.smaller.h,
        child: Text(album.title,
            style: TextStyles.boldBody
                .copyWith(color: DynamicTheme.get(context).white()),
            overflow: TextOverflow.ellipsis,
            maxLines: 1));
  }

  Widget _buildSubtitle(BuildContext context) {
    return SizedBox(
        height: ComponentSize.smallest.h,
        child: Text(
          album.subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyles.heading6
              .copyWith(color: DynamicTheme.get(context).neutral10()),
        ));
  }

  Widget _buildOptionsButton(BuildContext context) {
    return AppIconButton(
        width: ComponentSize.normal.r,
        height: ComponentSize.small.r,
        assetPath: Assets.iconOptions,
        assetColor: DynamicTheme.get(context).white(),
        onPressed: () => _onOptionsTap(context));
  }

  void _onOptionsTap(BuildContext context) {
    final args = AlbumOptionsArgs(album: album);
    AlbumOptionsBottomSheet.show(context, args: args);
  }
}
