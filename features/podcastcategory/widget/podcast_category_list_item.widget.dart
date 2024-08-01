import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';

class PodcastCategoryListItem extends StatelessWidget {
  const PodcastCategoryListItem({
    Key? key,
    required this.category,
    required this.onTap,
  }) : super(key: key);

  final PodcastCategory category;
  final Function(PodcastCategory category) onTap;

  @override
  Widget build(BuildContext context) {
    final size = 48.r;
    return ScaleTap(
        onPressed: () => onTap(category),
        child: Container(
          height: size,

          /// For ScaleTap to recognize whole item as tappable
          color: Colors.transparent,
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Photo.podcastCategory(
              category.thumbnail,
              options: PhotoOptions(
                width: size,
                height: size,
                borderRadius: BorderRadius.circular(ComponentRadius.normal.r),
              ),
            ),
            SizedBox(width: ComponentInset.small.r),
            Expanded(
              child: Text(category.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.boldBody
                      .copyWith(color: DynamicTheme.get(context).white())),
            ),
            SizedBox(width: ComponentInset.small.r),
          ]),
        ));
  }
}
