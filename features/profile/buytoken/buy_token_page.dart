import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:kwotmusic/features/profile/buytoken/buy_token_model.dart';
import 'package:provider/provider.dart';

import '../../../components/kit/assets.dart';
import '../../../components/kit/component_inset.dart';
import '../../../components/kit/component_size.dart';
import '../../../components/kit/textstyles.dart';
import '../../../components/kit/theme/dynamic_theme.dart';
import '../../../components/widgets/button.dart';
import '../../../components/widgets/photo/svg_asset_photo.dart';
import '../../../l10n/localizations.dart';
import '../../../navigation/dashboard_navigation.dart';
import 'dart:math' as math;

class BuyTokenPage extends StatefulWidget {
  const BuyTokenPage({Key? key}) : super(key: key);

  @override
  State<BuyTokenPage> createState() => _BuyTokenPageState();
}

class _BuyTokenPageState extends State<BuyTokenPage> {
  BuyTokenModel get _model => context.read<BuyTokenModel>();

  @override
  void initState() {
    _model.init(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final localeResource = LocaleResources.of(context);
    return SafeArea(
        child: Scaffold(
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: ComponentInset.normal.h),
        child: _buildAppButton(
          context,
          _model
        ),
      ),
      body:  HeaderWidget(
            buyTokenModel: _model,
            localeResource: localeResource,
          )

      ),
    );
  }
}

Widget _buildAppButton(BuildContext context, BuyTokenModel buyTokenModel) {
  return Selector<BuyTokenModel,int>(
      selector: (_, model) =>model.selectedIndex??8,
      builder: (_, model, __) {
        return Button(
          margin: EdgeInsets.only(
            top: ComponentInset.normal.r,
            left: ComponentInset.normal.r,
            right: ComponentInset.normal.r,
          ),
          text: LocaleResources.of(context).buyTokens,
          height: ComponentSize.large.h,
          type:model != 8? ButtonType.primary:ButtonType.disable,
          width: MediaQuery.of(context).size.width,
          onPressed: () {
            buyTokenModel.buyProduct(context);
          },
        );
      },
  );
}

class HeaderWidget extends StatelessWidget {
  HeaderWidget({
    Key? key,
    required this.buyTokenModel,
    required this.localeResource,
  }) : super(key: key);
  BuyTokenModel buyTokenModel;
  final TextLocaleResource localeResource;


  @override
  Widget build(BuildContext context) {
    final logoMaskOffset =
        _obtainLogoMaskOffset(contentPadding: ComponentInset.small.r);
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // TOP BAR: BACK BUTTON
        Row(children: [
          AppIconButton(
              width: ComponentSize.large.r,
              height: ComponentSize.large.r,
              assetColor: DynamicTheme.get(context).neutral20(),
              assetPath: Assets.iconArrowLeft,
              padding: EdgeInsets.all(ComponentInset.small.r),
              onPressed: () => DashboardNavigation.pop(context)),
        ]),
        SizedBox(
          height: 10.h,
        ),
        // TITLE BAR
        Padding(
          padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
          child: Text(localeResource.buyTokens,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.boldHeading2
                  .copyWith(color: DynamicTheme.get(context).white())),
        ),
        SizedBox(
          height: ComponentInset.small.h,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
          child: Text(localeResource.chooseYourPreferredOption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.heading5
                  .copyWith(color: DynamicTheme.get(context).neutral10())),
        ),

        Selector<BuyTokenModel,BuyTokenModel>(
            selector: (_, model) =>model,
            shouldRebuild: (prev, next) => true,
            builder: (_, model, __) {
              return  Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  childAspectRatio: (1 / .7),
                  crossAxisCount: 2,
                  children: List.generate(
                    buyTokenModel.products.length,
                    (index) {
                      return InkWell(
                        onTap: (){

                          buyTokenModel.onTapProduct(buyTokenModel.products[index],index);
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 8.h),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(ComponentInset.small.r),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: (model.selectedIndex == index)? Colors.white:Colors.transparent,width: 2),
                                gradient: LinearGradient(
                                  colors: buyTokenModel.colorList[index],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(
                                    ComponentInset.small.r),
                              ),
                              child: Stack(
                                clipBehavior: Clip.hardEdge,
                                children: <Widget>[
                                  Positioned(
                                      right: logoMaskOffset.dx,
                                      bottom: -56,
                                      child: const _ShadowMask()),
                                  Center(
                                      child: _Content(
                                    productDetails: buyTokenModel.products[index],
                                  ))
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ));
          }
        ),
      ]),
    );
  }
}

Offset _obtainLogoMaskOffset({
  required double contentPadding,
}) {
  double childHeight = 0 ?? 0;
  if (childHeight != 0) {
    childHeight += contentPadding * 2;
  }

  return Offset(
    -24.r,
    -36.r + childHeight,
  );
}

class _ShadowMask extends StatelessWidget {
  const _ShadowMask({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: math.pi / 15,
      child: SvgAssetPhoto(
        Assets.iconKwot,
        width: 144.r,
        height: 144.r,
        color: Colors.white.withOpacity(0.05),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  ProductDetails productDetails;

  _Content({Key? key, required this.productDetails}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ComponentInset.inset20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: ComponentInset.normal.h,
          ),
          Text(productDetails.price,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.boldHeading4
                  .copyWith(color: DynamicTheme.get(context).white())),
          Text(productDetails.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.boldHeading2
                  .copyWith(color: DynamicTheme.get(context).white())),
          Text("TOKENS",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.heading6
                  .copyWith(color: DynamicTheme.get(context).neutral10())),

        ],
      ),
    );
  }
}
