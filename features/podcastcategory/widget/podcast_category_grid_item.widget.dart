import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';

class PodcastCategoryGridItem extends StatelessWidget {
  const PodcastCategoryGridItem({
    Key? key,
    required this.width,
    required this.index,
    required this.category,
    required this.onTap,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  final double width;
  final int index;
  final PodcastCategory category;
  final Function(PodcastCategory category) onTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
        onPressed: () => onTap(category),
        child: Container(
            width: width,
            padding: padding,

            /// For ScaleTap to recognize whole item as tappable
            color: Colors.transparent,
            child: _buildThumbnail(context)));
  }

  Widget _buildThumbnail(BuildContext context) {
    final radius = ComponentRadius.normal.r;

    return AspectRatio(
        aspectRatio: 1,
        child: Stack(alignment: Alignment.bottomCenter, children: [
          Photo.podcastCategory(
            category.thumbnail,
            options: PhotoOptions(
                width: width,
                height: width,
                borderRadius: BorderRadius.circular(radius)),
          ),
          Container(
              height: ComponentSize.large.h,
              alignment: Alignment.bottomLeft,
              padding: EdgeInsets.all(ComponentInset.small.r),
              decoration: BoxDecoration(
                  image: _buildDecorationImage(),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(radius),
                      bottomRight: Radius.circular(radius))),
              child: SizedBox(
                height: ComponentSize.smaller.h,
                child: Text(category.title,
                    style: TextStyles.boldHeading3,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1),
              )),
        ]));
  }

  DecorationImage _buildDecorationImage() {
    return DecorationImage(
      image: AssetImage(Assets.graphicPodcastCategoryTitleBackground(index)),
      fit: BoxFit.fill,
    );
  }
}
