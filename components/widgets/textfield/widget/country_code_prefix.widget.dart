import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';

class CountryCodeSelectorPrefix extends StatelessWidget {
  const CountryCodeSelectorPrefix({
    Key? key,
    this.country,
    required this.onPressed,
  }) : super(key: key);

  final Country? country;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
      onPressed: onPressed,
      child: Container(
          color: Colors.transparent,
          child: Row(children: [
            SizedBox(width: ComponentInset.normal.w),
            _buildFlag(context, country),
            SizedBox(width: ComponentInset.smaller.w),
            _buildDropdownArrow(context),
            SizedBox(width: ComponentInset.smaller.w),
            _buildPhoneCodeText(context, country),
          ])),
    );
  }

  Widget _buildFlag(BuildContext context, Country? country) {
    final flagSize = ComponentSize.smaller.r;

    final Widget child;
    if (country == null) {
      child = Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ComponentRadius.small.r),
              border: Border.all(
                  color: DynamicTheme.get(context).neutral20(), width: 1.r)));
    } else {
      child = Photo.country(
        country.thumbnail,
        options: PhotoOptions(
          width: flagSize,
          height: flagSize,
          fit: BoxFit.contain,
          placeholder: const SizedBox.shrink(),
        ),
      );
    }

    return SizedBox(width: flagSize, height: flagSize, child: child);
  }

  Widget _buildDropdownArrow(BuildContext context) {
    final dropdownSize = ComponentSize.smaller.r;
    return SizedBox(
        width: dropdownSize,
        height: dropdownSize,
        child: SvgPicture.asset(
          Assets.iconArrowDown,
          color: (country != null)
              ? DynamicTheme.get(context).neutral10()
              : DynamicTheme.get(context).neutral20(),
          width: dropdownSize,
          height: dropdownSize,
        ));
  }

  Widget _buildPhoneCodeText(BuildContext context, Country? country) {
    if (country == null) {
      return Container();
    }

    return Row(children: [
      Text("+${country.phoneCode}",
          style: TextStyles.heading5
              .copyWith(color: DynamicTheme.get(context).neutral20())),
      Text(" · ", style: TextStyles.heading5),
    ]);
  }
}
