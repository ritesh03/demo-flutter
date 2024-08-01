import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';
import '../../l10n/localizations.dart';
import '../kit/component_inset.dart';
import '../kit/component_radius.dart';
import '../kit/component_size.dart';
import '../kit/textstyles.dart';
import '../kit/theme/dynamic_theme.dart';
import 'button.dart';

class ShowAlertBox {
  static showAlertInsufficientKMBeats(BuildContext context,
      {required VoidCallback onTapCancel, required VoidCallback onTapBuy}) {
    // set up the buttons
    Widget cancelButton = Padding(
      padding: EdgeInsets.only(bottom: ComponentInset.inset12.h),
      child: GestureDetector(
        onTap: onTapCancel,
        child: Container(
          height: ComponentSize.small.h,
          width: 100.w,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ComponentRadius.normal.r),
              border: Border.all(
                  color: DynamicTheme.get(context).secondary10(), width: 2.w)),
          child: Center(
            child: Text(LocaleResources.of(context).cancel,
                style: TextStyles.boldHeading5
                    .copyWith(color: DynamicTheme.get(context).secondary10()),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.center),
          ),
        ),
      ),
    );
    Widget continueButton = Padding(
      padding: EdgeInsets.only(
          bottom: ComponentInset.inset12.h, right: ComponentInset.inset12.w),
      child:Button(
          text:LocaleResources.of(context).buyKMBeats,
          height: ComponentSize.small.h,
          type: ButtonType.primary,
          width: 140.w,
          onPressed:onTapBuy

      ),


    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r)
      ),
      content: Text(LocaleResources.of(context).insufficientKMBeatsPleaseCheckYourWallet,
          style: TextStyles.heading5
              .copyWith(color: DynamicTheme.get(context).secondary10())),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static showAlertConfirmSubscription(BuildContext context, {required VoidCallback onTapCancel, required VoidCallback onTapBuy, required String planName, required String tokens, required bool isFromAEvent}) {
    // set up the buttons
    Widget cancelButton = Padding(
      padding: EdgeInsets.only(bottom: ComponentInset.inset12.h),
      child: GestureDetector(
        onTap: onTapCancel,
        child: Container(
          height: ComponentSize.small.h,
          width: 100.w,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ComponentRadius.normal.r),
              border: Border.all(
                  color: DynamicTheme.get(context).secondary10(), width: 2.w)),
          child: Center(
            child: Text(LocaleResources.of(context).cancel,
                style: TextStyles.boldHeading5
                    .copyWith(color: DynamicTheme.get(context).secondary10()),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.center),
          ),
        ),
      ),
    );
    Widget continueButton = Padding(
      padding: EdgeInsets.only(
          bottom: ComponentInset.inset12.h, right: ComponentInset.inset12.w),
      child:Button(
        text:LocaleResources.of(context).confirm,
          height: ComponentSize.small.h,
        type: ButtonType.primary,
        width: 140.w,
        onPressed:onTapBuy

      ),
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r)
      ),
      title: Text(isFromAEvent ?LocaleResources.of(context).confirmEvent:LocaleResources.of(context).joinFanClubCap,
          style: TextStyles.heading5
              .copyWith(color: DynamicTheme.get(context).secondary10())),
      content: Text("You have chosen $planName. We will deduct $tokens KM-Beats from your wallet. ",
          style: TextStyles.heading5
              .copyWith(color: DynamicTheme.get(context).secondary10())),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static showPhotosAlert(BuildContext context,String imageUrl) {
    AlertDialog alert = AlertDialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r)
      ),
      contentPadding: EdgeInsets.zero,
      content: InteractiveViewer(
        clipBehavior: Clip.none,
        minScale: 0.1,
        maxScale: 4.0,
        child: Photo.track(
          imageUrl,
          options: PhotoOptions(
              height: 300.h,
              fit: BoxFit.cover,
              borderRadius: BorderRadius.circular(8.r)),
        ),
      ),
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }




  static showAlertForAddBillingDetails(BuildContext context,
      {required VoidCallback onTapCancel, required VoidCallback onTapBuy}) {
    // set up the buttons
    Widget cancelButton = Padding(
      padding: EdgeInsets.only(bottom: ComponentInset.inset12.h),
      child: GestureDetector(
        onTap: onTapCancel,
        child: Container(
          height: ComponentSize.small.h,
          width: 100.w,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ComponentRadius.normal.r),
              border: Border.all(
                  color: DynamicTheme.get(context).secondary10(), width: 2.w)),
          child: Center(
            child: Text(LocaleResources.of(context).cancel,
                style: TextStyles.boldHeading5
                    .copyWith(color: DynamicTheme.get(context).secondary10()),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.center),
          ),
        ),
      ),
    );
    Widget continueButton = Padding(
      padding: EdgeInsets.only(
          bottom: ComponentInset.inset12.h, right: ComponentInset.inset12.w),
      child:Button(
          text:LocaleResources.of(context).confirm,
          height: ComponentSize.small.h,
          type: ButtonType.primary,
          width: 140.w,
          onPressed:onTapBuy

      ),


    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r)
      ),
      content: Text(LocaleResources.of(context).pleaseConfirmYourBillingDetailsBeforePurchasingTheToken,
          style: TextStyles.heading5
              .copyWith(color: DynamicTheme.get(context).secondary10())),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static showAlertConfirmPlatformSubscription(BuildContext context, {required VoidCallback onTapCancel, required VoidCallback onTapBuy, required String planName, required String tokens, required bool isFromAEvent}) {
    // set up the buttons
    Widget cancelButton = Padding(
      padding: EdgeInsets.only(bottom: ComponentInset.inset12.h),
      child: GestureDetector(
        onTap: onTapCancel,
        child: Container(
          height: ComponentSize.small.h,
          width: 100.w,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ComponentRadius.normal.r),
              border: Border.all(
                  color: DynamicTheme.get(context).secondary10(), width: 2.w)),
          child: Center(
            child: Text(LocaleResources.of(context).cancel,
                style: TextStyles.boldHeading5
                    .copyWith(color: DynamicTheme.get(context).secondary10()),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.center),
          ),
        ),
      ),
    );
    Widget continueButton = Padding(
      padding: EdgeInsets.only(
          bottom: ComponentInset.inset12.h, right: ComponentInset.inset12.w),
      child:Button(
          text:LocaleResources.of(context).confirm,
          height: ComponentSize.small.h,
          type: ButtonType.primary,
          width: 140.w,
          onPressed:onTapBuy

      ),
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r)
      ),
      title: Text(isFromAEvent ?LocaleResources.of(context).confirmEvent:LocaleResources.of(context).buySubscription,
          style: TextStyles.heading5
              .copyWith(color: DynamicTheme.get(context).secondary10())),
      content: Text("You have chosen $planName. We will deduct $tokens KM-Beats from your wallet. ",
          style: TextStyles.heading5
              .copyWith(color: DynamicTheme.get(context).secondary10())),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static showAlertConfirmFreePlatformSubscription(BuildContext context,
      {required VoidCallback onTapCancel, required VoidCallback onTapBuy, required String planName, }) {
    // set up the buttons
    Widget cancelButton = Padding(
      padding: EdgeInsets.only(bottom: ComponentInset.inset12.h,left: ComponentInset.inset12.w),
      child: GestureDetector(
        onTap: onTapCancel,
        child: Container(
          height: ComponentSize.small.h,
          width: 100.w,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ComponentRadius.normal.r),
              border: Border.all(
                  color: DynamicTheme.get(context).secondary10(), width: 2.w)),
          child: Center(
            child: Text(LocaleResources.of(context).cancel,
                style: TextStyles.boldHeading5
                    .copyWith(color: DynamicTheme.get(context).secondary10()),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.center),
          ),
        ),
      ),
    );
    Widget continueButton = Padding(
      padding: EdgeInsets.only(
          bottom: ComponentInset.inset12.h, right: ComponentInset.inset12.w),
      child:Button(
          text:LocaleResources.of(context).confirm,
          height: ComponentSize.small.h,
          type: ButtonType.primary,
          width: 140.w,
          onPressed:onTapBuy

      ),
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r)
      ),
      title: Text(LocaleResources.of(context).buySubscription,
          style: TextStyles.heading5
              .copyWith(color: DynamicTheme.get(context).secondary10())),
      content: Text("You have chosen $planName.",
          style: TextStyles.heading5.copyWith(color: DynamicTheme.get(context).secondary10())),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }


  static showAlertUpgradePlan(BuildContext context, {required VoidCallback onTapCancel, required VoidCallback onTapBuy, required String alertText}) {
    // set up the buttons
    Widget cancelButton = Padding(
      padding: EdgeInsets.only(bottom: ComponentInset.inset12.h),
      child: GestureDetector(
        onTap: onTapCancel,
        child: Container(
          height: ComponentSize.small.h,
          width: 100.w,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ComponentRadius.normal.r),
              border: Border.all(
                  color: DynamicTheme.get(context).secondary10(), width: 2.w)),
          child: Center(
            child: Text(LocaleResources.of(context).cancel,
                style: TextStyles.boldHeading5
                    .copyWith(color: DynamicTheme.get(context).secondary10()),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.center),
          ),
        ),
      ),
    );
    Widget continueButton = Padding(
      padding: EdgeInsets.only(
          bottom: ComponentInset.inset12.h, right: ComponentInset.inset12.w),
      child:Button(
          text:LocaleResources.of(context).upgrade,
          height: ComponentSize.small.h,
          type: ButtonType.primary,
          width: 140.w,
          onPressed:onTapBuy

      ),
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r)
      ),
      content: Text(alertText,
          style: TextStyles.heading5
              .copyWith(color: DynamicTheme.get(context).secondary10())),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
















}
