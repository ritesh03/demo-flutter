import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kwotmusic/core.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as dev;

import '../../../components/kit/assets.dart';
import '../../../components/kit/component_inset.dart';
import '../../../components/kit/component_size.dart';
import '../../../components/kit/textstyles.dart';
import '../../../components/kit/theme/dynamic_theme.dart';
import '../../../components/widgets/alert_box_buy_token.dart';
import '../../../components/widgets/button.dart';
import '../../../components/widgets/notificationbar/notification_bar.dart';
import '../../../components/widgets/page/title/page_title_bar_wrapper.dart';
import '../../../components/widgets/photo/photo.dart';
import '../../../components/widgets/photo/svg_asset_photo.dart';
import '../../../components/widgets/textfield.dart';
import '../../../l10n/localizations.dart';
import '../../../navigation/dashboard_navigation.dart';
import '../../../router/routes.dart';
import '../../../util/prefs.dart';
import '../../../util/util_url_launcher.dart';
import 'artist_tip.args.dart';
import 'buy_token_bottomsheet.dart';

class ArtistTipPage extends StatefulWidget {
  const ArtistTipPage({Key? key}) : super(key: key);

  @override
  State<ArtistTipPage> createState() => _ArtistTipPageState();
}

class _ArtistTipPageState extends State<ArtistTipPage> {
  ArtistTipModel get artistTipModel => context.read<ArtistTipModel>();

  @override
  void initState() {
    artistTipModel.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final localeResource = LocaleResources.of(context);
    return SafeArea(
        child: Scaffold(
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: ComponentInset.normal.h),
        child: Selector<ArtistTipModel, bool>(
            selector: (_, model) => model.isTokenEmpty,
            builder: (_, plan, __) {
              if (!plan) return const SizedBox.shrink();
              return _buildAppButton(context, artistTipModel);
            }),
      ),
      body: Selector<ArtistTipModel, bool>(
          selector: (_, model) => model.isTokenEmpty,
          builder: (_, plan, __) {
            if (!plan) return const Center(child: CircularProgressIndicator());
            return HeaderWidget(
              localeResource: localeResource,
              model: artistTipModel,
            );
          }),
    ));
  }
}

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({
    Key? key,
    required this.localeResource,
    required this.model,
  }) : super(key: key);

  final TextLocaleResource localeResource;
  final ArtistTipModel model;

  @override
  Widget build(BuildContext context) {
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
          child: Text(localeResource.sendATipToTheArtist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.boldHeading2
                  .copyWith(color: DynamicTheme.get(context).white())),
        ),
        SizedBox(
          height: ComponentInset.normal.h,
        ),
        _BuildArtistProfile(
          model: model,
        ),
        SizedBox(
          height: ComponentInset.normal.h,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
          child: Container(
            height: model.haveToken ? 184.h : 128.h,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: DynamicTheme.get(context).secondary10(),
                borderRadius: BorderRadius.circular(ComponentInset.small.r)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 24.h,
                ),
                const _Title(),
                SizedBox(
                  height: ComponentInset.small.h,
                ),
                _AmountWidget(
                  model: model,
                ),
                SizedBox(
                  height: 24.h,
                ),
                model.haveToken
                    ? _buildBuyButton(context, model)
                    : const SizedBox.shrink()
              ],
            ),
          ),
        ),
        SizedBox(
          height: 24.h,
        ),
        model.haveToken
            ? _TokenTextField(
                model: model,
              )
            : const _NoToken(),
      ]),
    );
  }
}

Widget _buildBuyButton(BuildContext context, ArtistTipModel model) {
  return GestureDetector(
    onTap: () {
      _onTappedBuyToken(context, model,false);
    },
    child: Container(
      height: 30.h,
      width: 130.w,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
              color: DynamicTheme.get(context).secondary100(), width: 2.w)),
      child: Center(
        child: Text(LocaleResources.of(context).buyTokens,
            style: TextStyles.boldHeading5
                .copyWith(color: DynamicTheme.get(context).secondary100())),
      ),
    ),
  );
}

class _Title extends StatelessWidget {
  const _Title({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(LocaleResources.of(context).yourBalance,
        style: TextStyles.heading4
            .copyWith(color: DynamicTheme.get(context).white()));
  }
}

class _BuildArtistProfile extends StatelessWidget {
  final ArtistTipModel model;
  _BuildArtistProfile({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _buildProfilePhoto(model.artist.thumbnail ?? ""),
          SizedBox(
            width: 8.w,
          ),
          Expanded(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileName(model.artist.name),
                  _buildArtistFollower(
                      context, model.artist.followerCount.toString()),
                ]),
          )
        ],
      ),
    );
  }
}

Widget _buildProfileName(String name) {
  return Text(name,
      style: TextStyles.boldHeading5, overflow: TextOverflow.ellipsis);
}

Widget _buildProfilePhoto(String photoPath) {
  return Photo.artist(photoPath,
      options: PhotoOptions(
        width: 48.r,
        height: 48.r,
        shape: BoxShape.circle,
      ));
}

Widget _buildArtistFollower(
  BuildContext context,
  String follower,
) {
  return Text("$follower ${LocaleResources.of(context).followers}",
      style: TextStyles.heading6
          .copyWith(color: DynamicTheme.get(context).neutral10()),
      overflow: TextOverflow.ellipsis);
}

class _AmountWidget extends StatelessWidget {
  final ArtistTipModel model;
  const _AmountWidget({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ComponentInset.small.w),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _buildTokenWidget(context, model),
            SizedBox(
              width: 24.w,
            ),
            Text(LocaleResources.of(context).equal,
                textAlign: TextAlign.center,
                style: TextStyles.caption
                    .copyWith(color: DynamicTheme.get(context).neutral10())),
            SizedBox(
              width: 25.w,
            ),
            _buildMoneyWidget(context, model),
          ]),
    );
  }
}

Widget _buildTokenWidget(BuildContext context, ArtistTipModel model) {
  return Container(
    width: 128.w,

    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SvgAssetPhoto(
              Assets.iconTokens,
              width: 22.w,
              height: 22.h,
              fit: BoxFit.cover,
              color: DynamicTheme.get(context).white(),
            ),
            SizedBox(
              width: 100.w,
              child: Selector<ArtistTipModel, String>(
                  selector: (_, model) => model.tokens??"",
                  builder: (_, plan, __) {
                    return Text(plan,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyles.boldHeading1
                            .copyWith(
                            color: DynamicTheme.get(context).white()));
                  }
                  ),
            ),
          ],
        ),
        Text(LocaleResources.of(context).tokens,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyles.heading6
                .copyWith(color: DynamicTheme.get(context).white()))
      ],
    ),
  );
}

Widget _buildMoneyWidget(BuildContext context, ArtistTipModel model) {
  String planPrice = "${double.parse(SharedPref.prefs!.getString(SharedPref.userAmount) == null ? "1" : SharedPref.prefs!.getString(SharedPref.userAmount) == "" ? "1" : SharedPref.prefs!.getString(SharedPref.userAmount) ?? "1") * (double.parse(model.resultTotalTokens!.data().walletAmount))}";
  double doubleValue = double.parse(planPrice);
  int intValue = doubleValue.toInt();
  return Container(
    width: 128.w,
    child: Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(SharedPref.prefs!.getString(SharedPref.currencySymbol)?? model.resultTotalTokens!.data().currencySymbol,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyles.robotoBoldHeading9
                      .copyWith(color: DynamicTheme.get(context).white())),
              SizedBox(
                width: 100.w,
                child: Text(intValue.toString(),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyles.boldHeading1
                        .copyWith(color: DynamicTheme.get(context).white())),
              ),
            ],
          ),
          Text(LocaleResources.of(context).money,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyles.heading6
                  .copyWith(color: DynamicTheme.get(context).white()))
        ],
      ),
    ),
  );
}

class _TokenTextField extends StatelessWidget {
  final ArtistTipModel model;
  const _TokenTextField({Key? key, required this.model})
      : super(
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(LocaleResources.of(context).howManyTokensDoYouWantToGive,
              textAlign: TextAlign.start,
              style: TextStyles.boldHeading4
                  .copyWith(color: DynamicTheme.get(context).neutral10())),
          SizedBox(
            height: ComponentInset.normal.h,
          ),
          _buildAddressLine1Input(model, context),
        ],
      ),
    );
  }
}

Widget _buildAddressLine1Input(ArtistTipModel model, BuildContext context) {
  return Selector<ArtistTipModel, String?>(
      selector: (_, model) => model.addressLine1InputError,
      builder: (_, error, __) {
        return TextInputField(
          controller: model.tokenController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
          ],
          errorText: error,
          height: ComponentSize.large.h,
          hintText: LocaleResources.of(context).typeAQuantityOfTokens,
          labelText: LocaleResources.of(context).tokens,
          onChanged: (text) => model.onAddressLine1InputChanged(text),
        );
      });
}

class _NoToken extends StatelessWidget {
  const _NoToken({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(LocaleResources.of(context).youHaveNoTokensYet,
              textAlign: TextAlign.center,
              style: TextStyles.boldHeading4
                  .copyWith(color: DynamicTheme.get(context).white())),
          SizedBox(
            height: ComponentInset.small.h,
          ),
          Text(
              LocaleResources.of(context)
                  .pleaseBuyTokensIfYouWantToGiveAwayToThisArtist,
              textAlign: TextAlign.center,
              style: TextStyles.heading5
                  .copyWith(color: DynamicTheme.get(context).neural100())),
        ],
      ),
    );
  }
}

Widget _buildAppButton(BuildContext context, ArtistTipModel model) {
  return Button(
    margin: EdgeInsets.only(
      top: ComponentInset.normal.r,
      left: ComponentInset.normal.r,
      right: ComponentInset.normal.r,
    ),
    text: model.haveToken
        ? LocaleResources.of(context).sendToken
        : LocaleResources.of(context).buyTokens,
    height: ComponentSize.large.h,
    type: ButtonType.primary,
    width: MediaQuery.of(context).size.width,
    onPressed: () {
      String? addressLine1InputError;
      if (model.tokenController.text.isEmpty) {
        addressLine1InputError = "Can't be empty";
      }
      model.notifyAddressLine1InputError(addressLine1InputError);
      if (model.haveToken) {
        if (addressLine1InputError != "Can't be empty") {
          if ((int.parse(model.resultTotalTokens!.data().walletTokens)) <
              (int.parse(model.tokenController.text))) {
            BuyTokenBottomSheet.show(
              context,
              model: model,
            );
          } else {
            model.sendTip(context).then((value) {
              if (value) {
                Navigator.pop(context, true);
                showDefaultNotificationBar(
                  NotificationBarInfo.success(
                      message: LocaleResources.of(context)
                          .youHaveSentTokensSuccesfully),
                );
              }
            });
          }
        }
      } else {
        _onTappedBuyToken(context, model,true);
      }
    },
  );
}

void _onTappedBuyToken(BuildContext context, ArtistTipModel _model,bool idFromBottomSheet) {
    if (_model.billingDetailResult!.message != "Successful") {
      ShowAlertBox.showAlertForAddBillingDetails(context, onTapCancel: () {
        Navigator.of(context, rootNavigator: true).pop();
      }, onTapBuy: () {
        DashboardNavigation.pushNamed(context, Routes.addBillingDetails)
            .then((value) {
          _model.fetchBillingDetail();
        });
        Navigator.of(context, rootNavigator: true).pop();
      });
    } else {
      if(Platform.isIOS) {
        DashboardNavigation.pushNamed(context, Routes.myWalletPage).then((value) {
          print("This is hit in then tha purchase:::");
          _model.fetchTotalTokens();
        });
      }else{
        UrlLauncherUtil.buyToken(context).then((value) {
          _model.fetchTotalTokens();
        });
      }
      idFromBottomSheet ?Navigator.of(context, rootNavigator: true).pop():null;
    }

}
