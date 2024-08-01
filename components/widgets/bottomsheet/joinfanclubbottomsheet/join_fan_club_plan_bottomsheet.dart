import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotdata/models/artist/subscription.artist.model.dart';
import '../../../../features/artist/profile/artist.model.dart';
import '../../../../l10n/localizations.dart';
import '../../../../navigation/dashboard_navigation.dart';
import '../../../../navigation/root_navigation.dart';
import '../../../../router/routes.dart';
import '../../../../util/util_url_launcher.dart';
import '../../../kit/component_inset.dart';
import '../../../kit/component_size.dart';
import '../../../kit/textstyles.dart';
import '../../../kit/theme/dynamic_theme.dart';
import '../../alert_box_buy_token.dart';
import '../../button.dart';
import '../../looping_page_view.dart';
import '../../notificationbar/notification_bar.dart';
import '../bottomsheet_drag_handle.widget.dart';
import 'fan_club_plan_widget.dart';

class JoinFanClubPlanBottomSheet extends StatefulWidget {
  String? artistName;
  Result<List<SubscriptionArtistPlanModel>> subscriptionPlans;
  ArtistModel artistModel;
  bool isFromUpgrade;

  JoinFanClubPlanBottomSheet(
      {Key? key,
      this.artistName,
      required this.subscriptionPlans,
      required this.artistModel,
      required this.isFromUpgrade})
      : super(key: key);

  @override
  State<JoinFanClubPlanBottomSheet> createState() =>
      _JoinFanClubPlanBottomSheetState();
}

class _JoinFanClubPlanBottomSheetState
    extends State<JoinFanClubPlanBottomSheet> {
  late final LoopingPageController _loopingPageController;
  bool isButtonEnable = false;
  int? _selectdIndex;

  @override
  void initState() {
    _loopingPageController = LoopingPageController(
      maxItemCount: widget.subscriptionPlans.data().length,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return Container(
        height: 520.h,
        color: DynamicTheme.get(context).neutral80(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: BottomSheetDragHandle(
                margin: EdgeInsets.only(top: ComponentInset.small.h),
              ),
            ),
            SizedBox(
              height: ComponentInset.inset22.h,
            ),
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
              child: Text("Join the ${widget.artistName} Fan Club",
                  style: TextStyles.boldHeading2,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start),
            ),
            SizedBox(
              height: ComponentInset.medium.h,
            ),
            Container(
              constraints: BoxConstraints(maxHeight: 256.h),
              child: LoopingPageView(
                  controller: _loopingPageController,
                  itemCount: widget.subscriptionPlans.data().length,
                  itemBuilder: (BuildContext context, int index) {
                    final plan = widget.subscriptionPlans.data()[index];
                    return FanClubPlanWidget(
                      plan: plan,
                      planId: plan.id!,
                      artistModel: widget.artistModel,
                      isButtonEnable: _selectdIndex == index,
                      onaTap: () {
                        setState(() {
                          widget.artistModel.planId = plan.id!;
                          widget.artistModel.toBuyPlanToken = plan.tokens;
                          widget.artistModel.planName = plan.plan!.name;
                          _selectdIndex = index;
                          if (widget.subscriptionPlans.data()[index].id ==
                              plan.id) {
                            isButtonEnable = true;
                          }
                        });
                      },
                    );
                  }),
            ),
            SizedBox(
              height: ComponentInset.normal.h,
            ),
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                      LocaleResources.of(context)
                          .subscriptionPlanAutoRenewalNote,
                      style: TextStyles.heading5,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start),
                  Button(
                    margin: EdgeInsets.only(
                      top: ComponentInset.medium.r,
                    ),
                    text: LocaleResources.of(context).joinFanClub,
                    height: ComponentSize.large.h,
                    type: isButtonEnable == true
                        ? ButtonType.primary
                        : ButtonType.disable,
                    width: MediaQuery.of(context).size.width,
                    onPressed:
                        isButtonEnable == true ? _onTapJoinButton : () {},
                  ),
                ],
              ),
            )
          ],
        ),
      );
    });
  }

  @override
  LoopingPageController getSubscriptionPlansPageController() {
    return _loopingPageController;
  }

  @override
  void onActiveSubscriptionPlanTap(SubscriptionPlan plan) {
    // TODO: implement onActiveSubscriptionPlanTap
  }

  @override
  void onCancelSubscriptionPlanTap() {
    // TODO: implement onCancelSubscriptionPlanTap
  }

  @override
  void onChangeSubscriptionPlanTap() {
    // TODO: implement onChangeSubscriptionPlanTap
  }

  @override
  void onRefreshActiveSubscriptionPlanTap() {
    // TODO: implement onRefreshActiveSubscriptionPlanTap
  }

  @override
  void onRefreshSubscriptionPlansTap() {
    // TODO: implement onRefreshSubscriptionPlansTap
  }

  @override
  void onRenewSubscriptionPlanTap() {
    // TODO: implement onRenewSubscriptionPlanTap
  }

  @override
  void onSubscriptionPlanTap(SubscriptionPlan plan) {
    // TODO: implement onSubscriptionPlanTap
  }
  _onTapJoinButton() {
    if (widget.artistModel.profileResult!.data().tokens! > widget.artistModel.toBuyPlanToken!) {
      ShowAlertBox.showAlertConfirmSubscription(context, onTapCancel: () {
        Navigator.pop(context, false);
      }, onTapBuy: () {
        widget.artistModel.buySubscription().then((value) {
          Navigator.pop(context, false);
          if (value) {
            Navigator.pop(context, true);
            showDefaultNotificationBar(
               NotificationBarInfo.success(message: widget.isFromUpgrade?"Fan plan upgraded successfully!":"Congrats! You are fan now"),
            );
          } else { Navigator.pop(context, false);
          showDefaultNotificationBar(
             NotificationBarInfo.error(message:  widget.isFromUpgrade?"You are already subscribed to this plan":"Oops, something went wrong."),
          );
          }
        });
      }, planName: widget.artistModel.planName!, tokens: widget.artistModel.toBuyPlanToken.toString(), isFromAEvent: false);
    } else {
    ShowAlertBox.showAlertInsufficientKMBeats(context, onTapCancel: () {
      Navigator.pop(context, false);
    }, onTapBuy: () {
      if (widget.artistModel.billingDetailResult!.message != "Successful") {
        ShowAlertBox.showAlertForAddBillingDetails(context, onTapCancel: () {
          Navigator.pop(context, false);
        }, onTapBuy: () {
          DashboardNavigation.pushNamed(context, Routes.addBillingDetails).then((value) {
            widget.artistModel.fetchBillingDetail();
          });
          Navigator.pop(context, false);
          Navigator.pop(context, false);
          Navigator.pop(context, false);
        });
      } else {
        if(Platform.isIOS) {
          DashboardNavigation.pushNamed(context, Routes.myWalletPage).then((value) {
            widget.artistModel.fetchProfile();
          });
          Navigator.pop(context, false);
        }else {
          UrlLauncherUtil.buyToken(context).then((value) {
            widget.artistModel.fetchProfile();
          });
        }
       Navigator.pop(context, false);
      }
    });
  }

  }
}
