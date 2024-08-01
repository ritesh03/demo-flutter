import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';

class ShowGridItem extends StatelessWidget {
  const ShowGridItem({
    Key? key,
    required this.width,
    required this.show,
    required this.onTap,
  }) : super(key: key);

  final double width;
  final Show show;
  final Function(Show show) onTap;

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
        onPressed: () => onTap(show),
        child: Container(
            width: width,

            /// For ScaleTap to recognize whole item as tappable
            color: Colors.transparent,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildThumbnail(context),
                  SizedBox(height: ComponentInset.small.h),
                  _buildTitle(context),
                  _buildSubtitle(context),
                  SizedBox(height: ComponentInset.small.h),
                ])));
  }

  Widget _buildThumbnail(BuildContext context) {
    // Design aspect ratio is 152 x 88 (1.72)
    return AspectRatio(
      aspectRatio: 1.72,
      child: Photo.show(
        show.thumbnail,
        options: PhotoOptions(
            width: 1.72 * 88.r,
            height: 88.r,
            borderRadius: BorderRadius.circular(ComponentRadius.normal.r)),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(show.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.boldBody
            .copyWith(color: DynamicTheme.get(context).white()));
  }

  Widget _buildSubtitle(BuildContext context) {
    return Text(show.artist.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.heading6
            .copyWith(color: DynamicTheme.get(context).neutral10()));
  }
}
