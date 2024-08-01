import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kwotdata/models/artist/artist_discounts.dart';
import 'package:kwotmusic/features/artist/fanclubviews/activediscounts/active_discounts_model.dart';
import 'package:provider/provider.dart';
import '../../../../components/kit/assets.dart';
import '../../../../components/kit/component_inset.dart';
import '../../../../components/kit/component_size.dart';
import '../../../../components/kit/textstyles.dart';
import '../../../../components/kit/theme/dynamic_theme.dart';
import '../../../../components/widgets/button.dart';
import '../../../../components/widgets/list/item_list.widget.dart';
import '../../../../components/widgets/marquee/simple_marquee.dart';
import '../../../../components/widgets/photo/svg_asset_photo.dart';
import '../../../../components/widgets/sliverheader/basic_sliver_header_delegate.dart';
import '../../../../components/widgets/textfield/search/searchbar.widget.dart';
import '../../../../l10n/localizations.dart';
import '../../../../navigation/dashboard_navigation.dart';
import '../../../dashboard/dashboard_config.dart';

class ActiveDiscountsView extends StatefulWidget {
  String artistId;
  ActiveDiscountsView({Key? key, required this.artistId}) : super(key: key);

  @override
  State<ActiveDiscountsView> createState() => _ActiveDiscountsViewState();
}

class _ActiveDiscountsViewState extends State<ActiveDiscountsView> {
  ActiveDiscountsModel get activeModel => context.read<ActiveDiscountsModel>();
  @override
  void initState() {
    activeModel.artistId = widget.artistId;
    activeModel.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ItemListWidget<ActiveDiscounts, ActiveDiscountsModel>(
            columnItemSpacing: ComponentInset.normal.h,
            padding:
                EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
            headerSlivers: [
              _buildSliverAppBar(context),
              SliverToBoxAdapter(child: _buildSearchBar(context)),
            ],
            footerSlivers: [DashboardConfigAwareFooter.asSliver()],
            itemBuilder: (context, user, index) {
              return ActiveDiscountsWidget(
                discounts: user, activeModel: activeModel,
              );
            }));
  }

  SliverPersistentHeader _buildSliverAppBar(BuildContext context) {
    final toolbarHeight = ComponentSize.large.h;
    final expandedHeight = toolbarHeight * 2;
    return SliverPersistentHeader(
        pinned: true,
        delegate: BasicSliverHeaderDelegate(
          context,
          toolbarHeight: toolbarHeight,
          expandedHeight: expandedHeight,
          topBar: Row(children: [
            AppIconButton(
                width: ComponentSize.large.r,
                height: ComponentSize.large.r,
                assetColor: DynamicTheme.get(context).neutral20(),
                assetPath: Assets.iconArrowLeft,
                padding: EdgeInsets.all(ComponentInset.small.r),
                onPressed: () => DashboardNavigation.pop(context)),
          ]),
          horizontalTitlePadding: ComponentInset.normal.w,
          title: _buildTitle(context),
        ));
  }
  Widget _buildTitle(BuildContext context) {
    return SimpleMarquee(
        text: LocaleResources.of(context).discounts,
        textStyle: TextStyles.boldHeading2.copyWith(
          color: DynamicTheme.get(context).white(),
        ));
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(ComponentInset.normal.r),
        child: SearchBar(
          hintText: LocaleResources.of(context).searchDiscount,
          onQueryChanged: activeModel.updateSearchQuery,
          onQueryCleared: activeModel.clearSearchQuery,
        ));
  }
}

class ActiveDiscountsWidget extends StatelessWidget {
  ActiveDiscounts discounts;
  ActiveDiscountsModel activeModel;
  ActiveDiscountsWidget({Key? key, required this.discounts,required this.activeModel}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
          color: discounts.isActive!? DynamicTheme.get(context).secondary140():Colors.transparent,
          borderRadius: BorderRadius.circular(ComponentInset.small.r)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
        child: Row(
          children: <Widget>[
            SvgAssetPhoto(
              Assets.discountIcon,
              width: 19.w,
              height: 19.h,
              color: discounts.isActive!?DynamicTheme.get(context).white():DynamicTheme.get(context).neutral20(),
            ),
            SizedBox(
              width: 22.w,
            ),
             _buildDiscountCode(discounts),
             _buildDiscountPriceWidget(discounts),
            Expanded(child: Container()),
            ScaleTap(
                onPressed: () {
                discounts.isActive!? activeModel.copyDiscountCoupons(discounts.discountCode,context):null;
                },
                child: SvgAssetPhoto(
                  discounts.isActive!? Assets.copyIcon:Assets.disableDiscount,
                  width: 19.w,
                  height: 19.h,
                )),
          ],
        ),
      ),
    );
  }
}

class _buildDiscountCode extends StatelessWidget {
  ActiveDiscounts discounts;

  _buildDiscountCode(this.discounts, {Key? key}) : super(key: key);

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
  _buildDiscountPriceWidget(
    this.discounts, {
    Key? key,
  }) : super(key: key);

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
