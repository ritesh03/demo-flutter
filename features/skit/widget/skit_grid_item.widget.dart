import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';

class SkitGridItem extends StatelessWidget {
  const SkitGridItem({
    Key? key,
    required this.width,
    required this.skit,
    required this.onTap,
  }) : super(key: key);

  final double width;
  final Skit skit;
  final Function(Skit skit) onTap;

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
        onPressed: () => onTap(skit),
        child: Container(
            width: width,

            /// For ScaleTap to recognize whole item as tappable
            color: Colors.transparent,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildThumbnailArea(context),
                  SizedBox(height: ComponentInset.small.h),
                  _buildTitle(context),
                  _buildSubtitle(context),
                  SizedBox(height: ComponentInset.small.h),
                ])));
  }

  Widget _buildThumbnailArea(BuildContext context) {
    return Stack(children: [
      _buildThumbnail(context),
      Positioned(top: 0, left: 0, child: _buildTypeIndicator(context))
    ]);
  }

  Widget _buildThumbnail(BuildContext context) {
    // Design aspect ratio is 152 x 88 (1.72)
    return AspectRatio(
      aspectRatio: 1.72,
      child: Photo.skit(
        skit.thumbnail,
        options: PhotoOptions(
            width: 1.72 * 88.r,
            height: 88.r,
            borderRadius: BorderRadius.circular(ComponentRadius.normal.r)),
      ),
    );
  }

  Widget _buildTypeIndicator(BuildContext context) {
    final size = ComponentSize.small.r;
    final String skitIndicatorAssetPath;
    switch (skit.type) {
      case SkitType.audio:
        skitIndicatorAssetPath = Assets.iconMicrophone;
        break;
      case SkitType.video:
        skitIndicatorAssetPath = Assets.iconVideo;
        break;
    }

    return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            color: DynamicTheme.displayBlack.withOpacity(0.5),
            shape: BoxShape.circle),
        margin: EdgeInsets.all(ComponentInset.small.r),
        child: SvgPicture.asset(
          skitIndicatorAssetPath,
          color: DynamicTheme.get(context).white(),
        ));
  }

  Widget _buildTitle(BuildContext context) {
    return Text(skit.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.boldBody
            .copyWith(color: DynamicTheme.get(context).white()));
  }

  Widget _buildSubtitle(BuildContext context) {
    return Text(skit.artist.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.heading6
            .copyWith(color: DynamicTheme.get(context).neutral10()));
  }
}
