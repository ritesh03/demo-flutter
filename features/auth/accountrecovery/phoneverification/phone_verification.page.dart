import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/blocking_progress.dialog.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/notificationbar/notification_bar.dart';
import 'package:kwotmusic/components/widgets/page/page_state.dart';
import 'package:kwotmusic/components/widgets/textfield.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/auth/accountrecovery/setpassword/set_password.model.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:provider/provider.dart';

import 'phone_verification.model.dart';

class PhoneVerificationPage extends StatefulWidget {
  const PhoneVerificationPage({Key? key}) : super(key: key);

  @override
  State<PhoneVerificationPage> createState() => _PhoneVerificationPageState();
}

class _PhoneVerificationPageState extends PageState<PhoneVerificationPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(ComponentSize.large.h),
            child: _buildAppBar(),
          ),
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
                      SizedBox(height: ComponentInset.small.h),
                      _buildSubtitle(),
                      SizedBox(height: ComponentInset.larger.h),
                      _buildCodeInput(),
                      SizedBox(height: ComponentInset.medium.h),
                      _buildValidateButton(),
                      SizedBox(height: ComponentInset.small.h),
                      _buildResendButton(),
                      SizedBox(height: ComponentInset.medium.h),
                    ]),
              ),
            ),
          )),
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
          style: TextStyles.boldHeading1),
    );
  }

  Widget _buildSubtitle() {
    final phoneNumber = context.read<PhoneVerificationModel>().phoneNumber;
    final subtitle = LocaleResources.of(context).phoneVerificationPageSubtitle(phoneNumber);
    return Container(
      height: ComponentSize.large.h,
      alignment: Alignment.centerLeft,
      child: Text(subtitle,
          style: TextStyles.body.copyWith(
            color: DynamicTheme.get(context).neutral20(),
          )),
    );
  }

  Widget _buildCodeInput() {
    return PinInputField(
        height: ComponentSize.large.h,
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.small.w),
        pinLength: 6,
        controller:
            context.read<PhoneVerificationModel>().pinEditingController);
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
          text:
              LocaleResources.of(context).phoneVerificationResendCodeButtonText,
          type: ButtonType.text,
          onPressed: _onResendCodeButtonPressed),
    );
  }

  /*
   * Actions
   */

  void _onBackPressed() => DashboardNavigation.pop(context);

  void _onValidateButtonPressed() {
    if (FocusScope.of(context).hasFocus) {
      FocusScope.of(context).unfocus();
    }

    showBlockingProgressDialog(context);

    context
        .read<PhoneVerificationModel>()
        .validatePhoneVerificationCode(context)
        .then((result) {
      // hide progress dialog
      hideBlockingProgressDialog(context);

      if (result == null) return;

      if (!result.isSuccess()) {
        showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()),
        );
        return;
      }

      final response = result.data();
      switch (response.type) {
        case PhoneVerificationType.accountRecovery:
          {
            final sourceRouteName =
                context.read<PhoneVerificationModel>().sourceRouteName ??
                    Routes.authSignIn;

            // Set Password
            DashboardNavigation.pushNamedAndRemoveUntil(context, Routes.setPassword,
                (route) => (route.settings.name == sourceRouteName),
                arguments: SetPasswordArgs(
                    country: response.country,
                    phoneNumber: response.phoneNumber,
                    requestToken: response.approvalToken!,
                    sourceRouteName: sourceRouteName));
            return;
          }
      }
    });
  }

  void _onResendCodeButtonPressed() {
    if (FocusScope.of(context).hasFocus) {
      FocusScope.of(context).unfocus();
    }

    showBlockingProgressDialog(context);

    context
        .read<PhoneVerificationModel>()
        .resendPhoneVerificationCode()
        .then((result) {
      // hide progress dialog
      hideBlockingProgressDialog(context);

      if (result == null) return;

      if (!result.isSuccess()) {
        showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()),
        );
        return;
      }

      showDefaultNotificationBar(
        NotificationBarInfo.success(message: result.message),
      );
    });
  }
}
