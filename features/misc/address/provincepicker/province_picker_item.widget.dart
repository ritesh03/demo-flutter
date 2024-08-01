import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';

class ProvincePickerItemWidget extends StatelessWidget {
  const ProvincePickerItemWidget({
    Key? key,
    required this.province,
    required this.isSelected,
    required this.onPressed,
  }) : super(key: key);

  final Province province;
  final bool isSelected;
  final Function(Province province) onPressed;

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
      onPressed: () => onPressed(province),
      child: Container(
          height: ComponentSize.large.h,
          decoration: BoxDecoration(
            color: DynamicTheme.get(context).black(),
            border: Border.all(color: obtainBorderColor(context)),
            borderRadius: BorderRadius.circular(ComponentRadius.normal.r),
          ),
          margin: EdgeInsets.symmetric(
              horizontal: ComponentInset.normal.r,
              vertical: ComponentInset.smaller.r),
          padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
          clipBehavior: Clip.antiAlias,
          child: _buildName(context)),
    );
  }

  Widget _buildName(BuildContext context) {
    return Container(
        height: ComponentSize.smaller.h,
        alignment: Alignment.centerLeft,
        child: Text(province.name,
            overflow: TextOverflow.ellipsis,
            style: TextStyles.body.copyWith(
              color: obtainForegroundColor(context),
            )));
  }

  Color obtainBorderColor(BuildContext context) {
    return isSelected ? DynamicTheme.get(context).white() : Colors.transparent;
  }

  Color obtainForegroundColor(BuildContext context) {
    return isSelected
        ? DynamicTheme.get(context).white()
        : DynamicTheme.get(context).neutral20();
  }
}
