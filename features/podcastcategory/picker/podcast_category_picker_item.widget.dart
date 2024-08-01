import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';

class PodcastCategoryPickerItemWidget extends StatelessWidget {
  const PodcastCategoryPickerItemWidget({
    Key? key,
    required this.category,
    required this.isSelected,
    required this.onPressed,
  }) : super(key: key);

  final PodcastCategory category;
  final bool isSelected;
  final Function(PodcastCategory category) onPressed;

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
        onPressed: () => onPressed(category),
        child: Container(
            height: ComponentSize.large.h,
            decoration: BoxDecoration(
              color: DynamicTheme.get(context).background(),
              border: Border.all(color: obtainBorderColor(context)),
              borderRadius: BorderRadius.circular(ComponentRadius.normal.r),
            ),
            padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
            margin: EdgeInsets.symmetric(
                horizontal: ComponentInset.normal.r,
                vertical: ComponentInset.smaller.r),
            clipBehavior: Clip.antiAlias,
            child: _buildName(context)));
  }

  Widget _buildName(BuildContext context) {
    return Container(
        height: ComponentSize.smaller.h,
        alignment: Alignment.centerLeft,
        child: Text(category.title,
            overflow: TextOverflow.ellipsis, style: obtainTextStyle(context)));
  }

  Color obtainBorderColor(BuildContext context) {
    return isSelected ? DynamicTheme.get(context).white() : Colors.transparent;
  }

  TextStyle obtainTextStyle(BuildContext context) {
    final textColor = isSelected
        ? DynamicTheme.get(context).white()
        : DynamicTheme.get(context).neutral20();

    return isSelected
        ? TextStyles.boldBody.copyWith(color: textColor)
        : TextStyles.body.copyWith(color: textColor);
  }
}
