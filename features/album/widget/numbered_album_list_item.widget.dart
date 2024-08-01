import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';
import 'package:kwotmusic/components/widgets/photo/svg_asset_photo.dart';

class NumberedAlbumListItem extends StatelessWidget {
  const NumberedAlbumListItem({
    Key? key,
    required this.index,
    required this.album,
    required this.onTap,
  }) : super(key: key);

  final int index;
  final Album album;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
      onPressed: onTap,
      opacityMinValue: 0.7,
      child: Row(children: [
        Expanded(child: _buildContent(context)),
        _buildArrowIcon(context)
      ]),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Container(
        color: Colors.transparent,
        child: Row(children: [
          _buildIndex(context),
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
        ]));
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

  Widget _buildIndex(BuildContext context) {
    return Container(
        constraints: BoxConstraints(minWidth: ComponentSize.small.w),
        height: ComponentSize.smaller.h,
        child: Text("${index + 1}.",
            style: TextStyles.heading3
                .copyWith(color: DynamicTheme.get(context).white()),
            overflow: TextOverflow.ellipsis,
            maxLines: 1));
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
      child: Text(album.subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyles.heading6
              .copyWith(color: DynamicTheme.get(context).neutral10())),
    );
  }

  Widget _buildArrowIcon(BuildContext context) {
    return SvgAssetPhoto(
      Assets.iconArrowRight,
      width: ComponentSize.normal.r,
      height: ComponentSize.smaller.r,
      color: DynamicTheme.get(context).neutral10(),
    );
  }
}
