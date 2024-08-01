import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/button/buttons.dart';

class BillingDetailListItem extends StatelessWidget {
  const BillingDetailListItem({
    Key? key,
     this.billingDetail,
    required this.onTap,
    required this.onEditTap,
  }) : super(key: key);

  final BillingDetail? billingDetail;
  final VoidCallback? onTap;
  final VoidCallback? onEditTap;

  @override
  Widget build(BuildContext context) {
    return TappableButton(
        backgroundColor: DynamicTheme.get(context).secondary20(),
        overlayColor: DynamicTheme.get(context).secondary40(),
        padding: EdgeInsets.all(ComponentInset.normal.r),
        onTap: onTap,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Expanded(child: _buildTitleText(context)),
            if (onEditTap != null) _buildEditButton(context),
          ]),
          SizedBox(height: ComponentInset.small.h),
          _buildAddressText(context),
        ]));
  }

  Widget _buildTitleText(BuildContext context) {
    return SizedBox(
        height: ComponentSize.smaller.h,
        child: Text(
         billingDetail != null? billingDetail!.name:"Billing details",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyles.boldHeading3
              .copyWith(color: DynamicTheme.get(context).white()),
          textAlign: TextAlign.left,
        ));
  }

  Widget _buildAddressText(BuildContext context) {
    return Text(
      billingDetail != null? billingDetail!.address:"ZIP Address, 29, 03004, City, Province, Country",
      maxLines: 4,
      overflow: TextOverflow.ellipsis,
      style: TextStyles.heading4
          .copyWith(color: DynamicTheme.get(context).neutral10()),
      textAlign: TextAlign.left,
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return AppIconButton(
        width: ComponentSize.small.r,
        height: ComponentSize.small.r,
        assetColor: DynamicTheme.get(context).secondary100(),
        assetPath: Assets.iconEdit,
        onPressed: onEditTap);
  }
}
