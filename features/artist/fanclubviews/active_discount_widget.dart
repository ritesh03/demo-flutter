import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kwotdata/models/artist/artist_discounts.dart';
import 'package:kwotmusic/components/kit/component_inset.dart';
import 'package:kwotmusic/components/kit/textstyles.dart';
import 'package:kwotmusic/components/kit/theme/dynamic_theme.dart';

import '../../../components/kit/assets.dart';
import '../../../components/widgets/photo/svg_asset_photo.dart';

class ActiveDiscountWidget extends StatelessWidget {
  ActiveDiscounts discounts;
   ActiveDiscountWidget({Key? key,required this.discounts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.h,
      decoration:BoxDecoration(
        color: discounts.isActive!? DynamicTheme.get(context).secondary140():Colors.transparent,
        borderRadius: BorderRadius.circular(ComponentInset.small.r)
      ),
      child: Padding(
        padding:  EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
        child: Row(
          children: <Widget>[
            SvgAssetPhoto(Assets.discountIcon,width: 19.w, height: 19.h,color: discounts.isActive!?DynamicTheme.get(context).white():DynamicTheme.get(context).neutral20(),),
            SizedBox(width: 22.w,),
             _buildDiscountCode(discounts: discounts,),
             _buildDiscountPriceWidget(discounts: discounts,),
            Expanded(child: Container()),
            ScaleTap(
                onPressed: ()
                {
                  discounts.isActive!?copyDiscountCoupons(discounts.discountCode,context):null;
                },
                child: SvgAssetPhoto(Assets.copyIcon,width: 19.w, height: 19.h,)),
          ],
        ),
      ),

    );
  }


  void copyDiscountCoupons(String text, context) {
    FlutterClipboard.copy(text).then((value) {
      ScaffoldMessenger.of(context)
          .showSnackBar( SnackBar(
          backgroundColor:DynamicTheme.get(context).background(),
          content: const Text("Copied to clipboard")));
    });
  }
}
class _buildDiscountCode extends StatelessWidget {
  ActiveDiscounts discounts;
   _buildDiscountCode({Key? key,required this.discounts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: 175.w,maxWidth:175.w),
      child: Text(
        discounts.discountCode,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.heading5.copyWith(color: discounts.isActive!?DynamicTheme.get(context).white():DynamicTheme.get(context).neutral20(),),
      ),
    );
  }
}
class _buildDiscountPriceWidget extends StatelessWidget {
  ActiveDiscounts discounts;
   _buildDiscountPriceWidget({Key? key,required this.discounts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return discounts.type == "percentage"
        ? Text(
      "${discounts.typeValue}% OFF",
      style: TextStyles.boldHeading5.copyWith(color: discounts.isActive!?DynamicTheme.get(context).white():DynamicTheme.get(context).neutral20()),
    )
        : Text(
      "₦${discounts.typeValue}",
      style: TextStyles.robotoBoldHeading7.copyWith(color: discounts.isActive!?DynamicTheme.get(context).white():DynamicTheme.get(context).neutral20()),
    );
  }
}