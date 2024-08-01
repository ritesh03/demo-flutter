import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';

class CountryPickerItemWidget extends StatelessWidget {
  const CountryPickerItemWidget({
    Key? key,
    required this.country,
    required this.isSelected,
    required this.onPressed,
  }) : super(key: key);

  final Country country;
  final bool isSelected;
  final Function(Country country) onPressed;

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
      onPressed: () => onPressed(country),
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
          clipBehavior: Clip.antiAlias,
          child: Row(children: [
            _buildFlag(),
            Expanded(child: _buildName(context)),
            _buildPhoneCode(context),
          ])),
    );
  }

  Widget _buildFlag() {
    return Container(
        width: ComponentSize.smaller.h,
        height: ComponentSize.smaller.h,
        margin: EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
        child: Photo.country(
          country.thumbnail,
          options: PhotoOptions(
            fit: BoxFit.contain,
            width: ComponentSize.smaller.h,
            height: ComponentSize.smaller.h,
            placeholder: const SizedBox.shrink(),
          ),
        ));
  }

  Widget _buildName(BuildContext context) {
    return Container(
        height: ComponentSize.smaller.h,
        alignment: Alignment.centerLeft,
        child: Text(country.name,
            overflow: TextOverflow.ellipsis,
            style: TextStyles.body.copyWith(
              color: obtainForegroundColor(context),
            )));
  }

  Widget _buildPhoneCode(BuildContext context) {
    return Container(
        height: ComponentSize.smaller.h,
        alignment: Alignment.center,
        margin: EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
        child: Text("+${country.phoneCode}",
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
