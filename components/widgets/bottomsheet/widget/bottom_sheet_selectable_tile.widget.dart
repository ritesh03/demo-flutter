import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:kwotmusic/components/kit/kit.dart';

class BottomSheetSelectableTile extends StatelessWidget {
  const BottomSheetSelectableTile({
    Key? key,
    required this.text,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
      onPressed: onTap,
      scaleMinValue: 0.98,
      child: Container(
          height: ComponentSize.large.h,
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: DynamicTheme.get(context).background(),
            border: Border.all(color: obtainBorderColor(context)),
            borderRadius: BorderRadius.circular(ComponentRadius.normal.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
          clipBehavior: Clip.antiAlias,
          child: Text(text,
              overflow: TextOverflow.ellipsis,
              style: obtainTextStyle(context)
                  .copyWith(color: obtainForegroundColor(context)))),
    );
  }

  Color obtainBorderColor(BuildContext context) {
    return isSelected ? DynamicTheme.get(context).white() : Colors.transparent;
  }

  Color obtainForegroundColor(BuildContext context) {
    return isSelected
        ? DynamicTheme.get(context).white()
        : DynamicTheme.get(context).neutral20();
  }

  TextStyle obtainTextStyle(BuildContext context) {
    return isSelected ? TextStyles.boldBody : TextStyles.body;
  }
}
