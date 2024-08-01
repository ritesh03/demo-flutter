import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kwotmusic/components/kit/kit.dart';

class FilterIconSuffix extends StatelessWidget {
  const FilterIconSuffix({
    Key? key,
    required this.isSelected,
    required this.onPressed,
  }) : super(key: key);

  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
        onPressed: onPressed,
        child: Container(
            width: ComponentSize.normal.w,
            color: Colors.transparent,
            alignment: Alignment.center,
            child: SvgPicture.asset(
              isSelected ? Assets.iconFilterFilled : Assets.iconFilter,
              width: ComponentSize.smaller.r,
              height: ComponentSize.smaller.r,
              color: isSelected
                  ? DynamicTheme.get(context).secondary100()
                  : DynamicTheme.get(context).white(),
            )));
  }
}
