import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button/buttons.dart';
import 'package:kwotmusic/features/skit/skit_actions.model.dart';
import 'package:kwotmusic/l10n/localizations.dart';

class SkitSortOrderTile extends StatelessWidget {
  const SkitSortOrderTile({
    Key? key,
    required this.sortOrder,
    required this.onTap,
  }) : super(key: key);

  final SkitSortOrder sortOrder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TappableButton(
      onTap: onTap,
      backgroundColor: DynamicTheme.get(context).background(),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(ComponentRadius.normal.r),
        topRight: Radius.circular(ComponentRadius.normal.r),
      ),
      overlayColor: DynamicTheme.get(context).secondary10(),
      padding: EdgeInsets.symmetric(
        horizontal: ComponentInset.medium.r,
        vertical: ComponentInset.normal.r,
      ),
      child: Row(children: [
        Expanded(child: _buildLabel(context)),
        _buildSortOrderValueText(context),
        SizedBox(width: ComponentInset.small.r),
        _buildIndicatorArrow(context),
      ]),
    );
  }

  Widget _buildLabel(BuildContext context) {
    return Text(
      LocaleResources.of(context).sortBy,
      style: TextStyles.boldBody
          .copyWith(color: DynamicTheme.get(context).white()),
    );
  }

  Widget _buildSortOrderValueText(BuildContext context) {
    return Text(
      locator<SkitActionsModel>().getSkitSortOrderText(context, sortOrder),
      style: TextStyles.boldBody
          .copyWith(color: DynamicTheme.get(context).secondary100()),
    );
  }

  Widget _buildIndicatorArrow(BuildContext context) {
    return SvgPicture.asset(Assets.iconArrowDown,
        color: DynamicTheme.get(context).secondary100(),
        width: 16.r,
        height: 16.r);
  }
}
