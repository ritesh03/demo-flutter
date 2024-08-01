import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';

class PodcastCategoryChip extends StatelessWidget {
  const PodcastCategoryChip({
    Key? key,
    required this.category,
    required this.onTap,
  }) : super(key: key);

  final PodcastCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
          onPressed: onTap,
          child: Container(
            decoration: BoxDecoration(
                color: DynamicTheme.get(context).black(),
                borderRadius: BorderRadius.circular(ComponentRadius.normal.r)),
            padding: EdgeInsets.all(ComponentInset.small.r),
            child: Text(category.title, style: TextStyles.heading6),
          ));
  }
}
