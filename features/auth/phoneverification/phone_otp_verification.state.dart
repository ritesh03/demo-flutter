import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/models/models.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/blocking_progress.dialog.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/indicator/indicators.dart';
import 'package:kwotmusic/components/widgets/notificationbar/notification_bar.dart';
import 'package:kwotmusic/components/widgets/page/page_state.dart';
import 'package:kwotmusic/components/widgets/textfield.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:provider/provider.dart';

import 'phone_otp_verification.model.dart';

abstract class PhoneOtpVerificationPageState<T extends StatefulWidget>
    extends PageState<T> {
  //=

  PhoneOtpVerificationModel get phoneOtpVerificationModel =>
      context.read<PhoneOtpVerificationModel>();

  void onPhoneVerificationComplete({
    required Country country,
    required String phoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: PreferredSize(
              preferredSize: Size.fromHeight(ComponentSize.large.h),
              child: _buildAppBar()),
          body: ScrollConfiguration(
            behavior: const ScrollBehavior().copyWith(overscroll: false),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: ComponentInset.normal.h),
                      _buildTitle(),
                      _buildContent(),
                    ]),
              ),
            ),
          )),
    );
  }

  Widget _buildContent() {
    return Container(
      constraints: BoxConstraints(
        /// To make it a square; This wouldn't work on tablet-scale devices
        minHeight: MediaQuery.of(context).size.width,
      ),
      child: Selector<PhoneOtpVerificationModel, Result?>(
          selector: (_, model) => model.initialOtpRequestResult,
          builder: (_, result, __) {
            if (result == null) {
              return const LoadingIndicator();
            }

            if (!result.isSuccess()) {
              return Center(
                  child: ErrorIndicator(
                      error: result.error(),
                      onTryAgain: () =>
                          phoneOtpVerificationModel.createInitialOtpRequest()));
            }

            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: ComponentInset.small.h),
                  _buildSubtitle(),
                  SizedBox(height: ComponentInset.larger.h),
                  _buildCodeInput(),
                  SizedBox(height: ComponentInset.medium.h),
                  _buildValidateButton(),
                  SizedBox(height: ComponentInset.small.h),
                  _buildResendButton(),
                  SizedBox(height: ComponentInset.medium.h),
                ]);
          }),
    );
  }

  Widget _buildAppBar() {
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      AppIconButton(
        width: ComponentSize.normal.r,
        height: ComponentSize.normal.r,
        assetColor: DynamicTheme.get(context).neutral20(),
        assetPath: Assets.iconCrossBold,
        padding: EdgeInsets.all(ComponentInset.small.r),
        onPressed: _onBackPressed,
      ),
    ]);
  }

  Widget _buildTitle() {
    return Container(
        height: 80.h,
        alignment: Alignment.centerLeft,
        child: Text(LocaleResources.of(context).phoneVerificationPageTitle,
            style: TextStyles.boldHeading1
                .copyWith(color: DynamicTheme.get(context).white())));
  }

  Widget _buildSubtitle() {
    final phoneNumber = phoneOtpVerificationModel.phoneNumber;
    final subtitle =
        LocaleResources.of(context).phoneVerificationPageSubtitle(phoneNumber);
    return Container(
      height: ComponentSize.large.h,
      alignment: Alignment.centerLeft,
      child: Text(subtitle,
          style: TextStyles.body
              .copyWith(color: DynamicTheme.get(context).neutral20())),
    );
  }

  Widget _buildCodeInput() {
    return PinInputField(
        height: ComponentSize.large.h,
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.small.w),
        pinLength: 6,
        controller: phoneOtpVerificationModel.pinEditingController);
  }

  Widget _buildValidateButton() {
    return Button(
        width: 1.sw,
        height: ComponentSize.large.h,
        text: LocaleResources.of(context).phoneVerificationButtonText,
        type: ButtonType.primary,
        onPressed: _onValidateButtonPressed);
  }

  Widget _buildResendButton() {
    return Center(
        child: Button(
            height: ComponentSize.large.h,
            text: LocaleResources.of(context)
                .phoneVerificationResendCodeButtonText,
            type: ButtonType.text,
            onPressed: _onResendCodeButtonPressed));
  }

  /*
   * Actions
   */

  void _onBackPressed() => DashboardNavigation.pop(context);

  void _onValidateButtonPressed() async {
    if (FocusScope.of(context).hasFocus) {
      FocusScope.of(context).unfocus();
    }

    showBlockingProgressDialog(context);

    final result =
        await phoneOtpVerificationModel.verifyPhoneSignUpOtp(context);

    if (!mounted) return;
    hideBlockingProgressDialog(context);

    if (result == null) return;

    if (!result.isSuccess()) {
      showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()));
      return;
    }

    onPhoneVerificationComplete(
      country: phoneOtpVerificationModel.country,
      phoneNumber: phoneOtpVerificationModel.phoneNumber,
    );
  }

  void _onResendCodeButtonPressed() async {
    if (FocusScope.of(context).hasFocus) {
      FocusScope.of(context).unfocus();
    }

    showBlockingProgressDialog(context);

    final result =
        await phoneOtpVerificationModel.requestPhoneVerificationOtp();

    if (!mounted) return;
    hideBlockingProgressDialog(context);

    if (result == null) return;

    if (!result.isSuccess()) {
      showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()));
      return;
    }

    showDefaultNotificationBar(
        NotificationBarInfo.success(message: result.message));
  }
}
