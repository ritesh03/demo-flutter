import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter/services.dart';
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/app_config.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/blocking_progress.dialog.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/notificationbar/notification_bar.dart';
import 'package:kwotmusic/components/widgets/page/page_state.dart';
import 'package:kwotmusic/components/widgets/textfield.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/auth/accountrecovery/phoneverification/phone_verification.model.dart';
import 'package:kwotmusic/features/auth/session/session.model.dart';
import 'package:kwotmusic/features/misc/address/countrypicker/country_picker.bottomsheet.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:kwotmusic/util/util.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import 'request_account_recovery.model.dart';

class RequestAccountRecoveryPageArgs {
  RequestAccountRecoveryPageArgs({
    required this.sourceRouteName,
  });

  final String sourceRouteName;
}

class RequestAccountRecoveryPage extends StatefulWidget {
  const RequestAccountRecoveryPage({Key? key}) : super(key: key);

  @override
  State<RequestAccountRecoveryPage> createState() =>
      _RequestAccountRecoveryPageState();
}

class _RequestAccountRecoveryPageState
    extends PageState<RequestAccountRecoveryPage> {
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
                      SizedBox(height: ComponentInset.small.h),
                      _buildSubtitle(),
                      SizedBox(height: ComponentInset.medium.h),
                      _buildIdentityInputField(),
                      SizedBox(height: ComponentInset.normal.h),
                      _buildAlternateRecoveryOption(),
                      SizedBox(height: ComponentInset.medium.h),
                      _buildRequestButton(),
                      SizedBox(height: ComponentInset.medium.h),
                    ]),
              ),
            ),
          )),
    );
  }

  Widget _buildAppBar() {
    return Row(children: [
      AppIconButton(
          width: ComponentSize.large.r,
          height: ComponentSize.large.r,
          assetColor: DynamicTheme.get(context).neutral20(),
          assetPath: Assets.iconArrowLeft,
          padding: EdgeInsets.all(ComponentInset.small.r),
          onPressed: () => DashboardNavigation.pop(context)),
    ]);
  }

  Widget _buildTitle() {
    return Container(
      height: 80.h,
      alignment: Alignment.centerLeft,
      child: Text(LocaleResources.of(context).requestAccountRecoveryPageTitle,
          style: TextStyles.boldHeading1),
    );
  }

  Widget _buildSubtitle() {
    return Container(
      height: ComponentSize.large.h,
      alignment: Alignment.centerLeft,
      child:
          Text(LocaleResources.of(context).requestAccountRecoveryPageSubtitle,
              style: TextStyles.body.copyWith(
                color: DynamicTheme.get(context).neutral20(),
              )),
    );
  }

  Widget _buildIdentityInputField() {
    return Selector<RequestAccountRecoveryModel, IdentityType>(
        selector: (_, model) => model.identityType,
        builder: (_, identityType, __) {
          switch (identityType) {
            case IdentityType.email:
              return _buildEmailInputField();
            case IdentityType.phoneNumber:
              return _buildPhoneInputField();
          }
        });
  }

  Widget _buildEmailInputField() {
    return Selector<RequestAccountRecoveryModel, String?>(
        selector: (_, model) => model.emailInputError,
        builder: (_, error, __) {
          return TextInputField(
            controller: context
                .read<RequestAccountRecoveryModel>()
                .emailEditingController,
            errorText: error,
            height: ComponentSize.large.h,
            hintText: LocaleResources.of(context).emailInputHint,
            labelText: LocaleResources.of(context).emailInputLabel,
            onChanged: (text) => context
                .read<RequestAccountRecoveryModel>()
                .onEmailInputChanged(text),
            keyboardType: TextInputType.emailAddress,
          );
        });
  }

  Widget _buildPhoneInputField() {
    return Selector<RequestAccountRecoveryModel, Tuple2<String?, Country>>(
        selector: (_, model) =>
            Tuple2(model.phoneNumberInputError, model.selectedCountry),
        builder: (_, tuple, __) {
          final error = tuple.item1;
          final country = tuple.item2;

          return TextInputField(
            prefixes: [
              CountryCodeSelectorPrefix(
                country: country,
                onPressed: _onCountryButtonTapped,
              ),
            ],
            controller: context
                .read<RequestAccountRecoveryModel>()
                .phoneEditingController,
            errorText: error,
            height: ComponentSize.large.h,
            hintText: LocaleResources.of(context).phoneNumberInputHint,
            keyboardType: TextInputType.phone,
            labelText: LocaleResources.of(context).phoneNumberInputLabel,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp("[0-9]")),
              LengthLimitingTextInputFormatter(
                  AppConfig.allowedPhoneNumberLength)
            ],
            onChanged: (text) => context
                .read<RequestAccountRecoveryModel>()
                .onPhoneNumberInputChanged(text),
          );
        });
  }

  Widget _buildAlternateRecoveryOption() {
    return Selector<RequestAccountRecoveryModel, IdentityType>(
        selector: (_, model) => model.identityType,
        builder: (_, identityType, __) {
          final String buttonText;
          switch (identityType) {
            case IdentityType.email:
              buttonText = LocaleResources.of(context).usePhoneNumber;
              break;
            case IdentityType.phoneNumber:
              buttonText = LocaleResources.of(context).useEmail;
              break;
          }
          return Button(
              height: ComponentSize.smaller.h,
              text: buttonText,
              type: ButtonType.text,
              onPressed: () => context
                  .read<RequestAccountRecoveryModel>()
                  .toggleIdentityType());
        });
  }

  Widget _buildRequestButton() {
    return Button(
        width: 1.sw,
        height: ComponentSize.large.h,
        text: LocaleResources.of(context).requestAccountRecoveryButtonText,
        type: ButtonType.primary,
        onPressed: _onRequestButtonPressed);
  }

  /*
   * Actions
   */

  void _onCountryButtonTapped() async {
    hideKeyboard(context);

    final selectedCountry =
        context.read<RequestAccountRecoveryModel>().selectedCountry;
    final country =
        await CountryPickerBottomSheet.show(context, selectedCountry);

    if (!mounted) return;
    if (country != null) {
      context.read<RequestAccountRecoveryModel>().updateCountry(country);
    }
  }

  void _onRequestButtonPressed() {
    if (FocusScope.of(context).hasFocus) {
      FocusScope.of(context).unfocus();
    }

    showBlockingProgressDialog(context);

    context
        .read<RequestAccountRecoveryModel>()
        .requestAccountRecovery(context)
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

      final args = obtainRouteArgs<RequestAccountRecoveryPageArgs?>(context);
      final sourceRouteName = args?.sourceRouteName;

      final response = result.data();
      if (response.type == AccountRecoveryType.phoneNumber) {
        final targetSourceRouteName = sourceRouteName ?? Routes.authSignIn;

        final country = response.country;
        final phoneNumber = response.phoneNumber;
        if (country == null || phoneNumber == null) {
          showDefaultNotificationBar(NotificationBarInfo.error(
              message: LocaleResources.of(context).somethingWentWrong));
          return;
        }

        // Validate Phone
        closeCurrentNotificationBar();
        DashboardNavigation.pushNamedAndRemoveUntil(
            context,
            Routes.phoneVerification,
            (route) => (route.settings.name == targetSourceRouteName),
            arguments: PhoneVerificationArgs(
                country: country,
                phoneNumber: phoneNumber,
                type: PhoneVerificationType.accountRecovery,
                sourceRouteName: sourceRouteName));
        return;
      }

      showDefaultNotificationBar(
          NotificationBarInfo.success(message: result.message));

      if (sourceRouteName != null && locator<SessionModel>().hasSession) {
        // External validation + Signed In, pop until source route
        DashboardNavigation.popUntil(context, (route) {
          return route.settings.name == sourceRouteName;
        });
        return;
      }

      // External validation + Not Signed In, continue to Sign In
      DashboardNavigation.pushNamedAndRemoveUntil(
          context, Routes.authSignIn, (route) => false);
    });
  }
}
