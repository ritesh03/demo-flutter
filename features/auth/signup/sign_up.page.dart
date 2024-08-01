import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter/services.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/app_config.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/blocking_progress.dialog.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/notificationbar/notification_bar.dart';
import 'package:kwotmusic/components/widgets/textfield.dart';
import 'package:kwotmusic/components/widgets/toggle_switch.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/auth/authentication_state.dart';
import 'package:kwotmusic/features/auth/signup/emailverification/email_sign_up_verification.model.dart';
import 'package:kwotmusic/features/auth/signup/phoneverification/phone_sign_up_verification.model.dart';
import 'package:kwotmusic/features/misc/address/countrypicker/country_picker.bottomsheet.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:kwotmusic/util/util_url_launcher.dart';
import 'package:kwotmusic/util/validation_util.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import 'sign_up.model.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends AuthenticationState<SignUpPage> {
  //=

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
                    _buildTopBar(),
                    SizedBox(height: ComponentInset.normal.h),
                    _buildTitle(),
                    // SizedBox(height: ComponentInset.small.h),
                    // _buildSubtitle(),
                    SizedBox(height: ComponentInset.medium.h),
                    _buildNameInputFields(),
                    SizedBox(height: ComponentInset.medium.h),
                    _buildIdentityInputField(),
                    // SizedBox(height: ComponentInset.normal.h),
                    // _buildAlternateRegistrationOption(),
                    SizedBox(height: ComponentInset.medium.h),
                    _buildPasswordInputField(),
                    SizedBox(height: ComponentInset.medium.h),
                    _buildTermsAgreementWidget(),
                    SizedBox(height: ComponentInset.medium.h),
                    _buildRegisterButton(),
                    SizedBox(height: ComponentInset.medium.h),
                    _buildSignInPrompt()
                  ]),
            )),
      )),
    );
  }

  Widget _buildTopBar() {
    final logoSize = ComponentSize.normal.h;
    return Container(
      margin: EdgeInsets.only(top: ComponentInset.small.h),
      child: Row(children: [
        /// LOGO
        SizedBox(
            height: logoSize,
            child: Image.asset(
              Assets.graphicLogoRoundedSmall,
              width: logoSize,
              height: logoSize,
            )),
        const Spacer(),

        /// CLOSE BUTTON
        AppIconButton(
          width: ComponentSize.normal.r,
          height: ComponentSize.normal.r,
          assetColor: DynamicTheme.get(context).neutral20(),
          assetPath: Assets.iconCrossBold,
          padding: EdgeInsets.all(ComponentInset.small.r),
          onPressed: _onBackPressed,
        ),
      ]),
    );
  }

  Widget _buildTitle() {
    return Container(
        height: ComponentSize.normal.h,
        alignment: Alignment.centerLeft,
        child: Text(LocaleResources.of(context).signUpPageTitle,
            style: TextStyles.boldHeading1));
  }

  Widget _buildSubtitle() {
    return Container(
        height: ComponentSize.smaller.h,
        alignment: Alignment.centerLeft,
        child: Text(LocaleResources.of(context).signUpPageSubtitle,
            style: TextStyles.body
                .copyWith(color: DynamicTheme.get(context).neutral20())));
  }

  Widget _buildNameInputFields() {
    return Row(children: [
      Expanded(child: _buildFirstNameInputField()),
      SizedBox(width: ComponentInset.normal.w),
      Expanded(child: _buildLastNameInputField())
    ]);
  }

  Widget _buildFirstNameInputField() {
    return Selector<SignUpModel, String?>(
        selector: (_, model) => model.firstNameInputError,
        builder: (_, error, __) {
          return TextInputField(
            controller: context.read<SignUpModel>().firstNameEditingController,
            errorText: error,
            height: ComponentSize.large.h,
            hintText: LocaleResources.of(context).firstNameInputHint,
            labelText: LocaleResources.of(context).firstNameInputLabel,
            inputFormatters: ValidationUtil.text.nameInputFormatters,
            onChanged: (text) =>
                context.read<SignUpModel>().onFirstNameInputChanged(text),
            textCapitalization: ValidationUtil.text.nameInputCapitalization,
          );
        });
  }

  Widget _buildLastNameInputField() {
    return Selector<SignUpModel, String?>(
        selector: (_, model) => model.lastNameInputError,
        builder: (_, error, __) {
          return TextInputField(
            controller: context.read<SignUpModel>().lastNameEditingController,
            errorText: error,
            height: ComponentSize.large.h,
            hintText: LocaleResources.of(context).lastNameInputHint,
            labelText: LocaleResources.of(context).lastNameInputLabel,
            inputFormatters: ValidationUtil.text.nameInputFormatters,
            onChanged: (text) =>
                context.read<SignUpModel>().onLastNameInputChanged(text),
            textCapitalization: ValidationUtil.text.nameInputCapitalization,
          );
        });
  }

  Widget _buildIdentityInputField() {
    return Selector<SignUpModel, IdentityType>(
        selector: (_, model) => model.registrationIdentityType,
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
    return Selector<SignUpModel, String?>(
        selector: (_, model) => model.emailInputError,
        builder: (_, error, __) {
          return TextInputField(
            controller: context.read<SignUpModel>().emailEditingController,
            errorText: error,
            height: ComponentSize.large.h,
            hintText: LocaleResources.of(context).emailInputHint,
            labelText: LocaleResources.of(context).emailInputLabel,
            onChanged: (text) =>
                context.read<SignUpModel>().onEmailInputChanged(text),
            keyboardType: TextInputType.emailAddress,
          );
        });
  }

  Widget _buildPhoneInputField() {
    return Selector<SignUpModel, Tuple2<String?, Country>>(
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
            controller: context.read<SignUpModel>().phoneEditingController,
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
            onChanged: (text) =>
                context.read<SignUpModel>().onPhoneNumberInputChanged(text),
          );
        });
  }

  Widget _buildAlternateRegistrationOption() {
    return Selector<SignUpModel, IdentityType>(
        selector: (_, model) => model.registrationIdentityType,
        builder: (_, identityType, __) {
          final String buttonText;
          switch (identityType) {
            case IdentityType.email:
              buttonText = LocaleResources.of(context).signUpWithPhoneNumber;
              break;
            case IdentityType.phoneNumber:
              buttonText = LocaleResources.of(context).signUpWithEmail;
              break;
          }
          return Button(
              height: ComponentSize.smaller.h,
              text: buttonText,
              type: ButtonType.text,
              onPressed: () =>
                  context.read<SignUpModel>().toggleRegistrationIdentityType());
        });
  }

  Widget _buildPasswordInputField() {
    return Selector<SignUpModel, Tuple2<String?, bool>>(
        selector: (_, model) => Tuple2(
              model.passwordInputError,
              model.isPasswordVisible,
            ),
        builder: (_, tuple, __) {
          final passwordInputError = tuple.item1;
          final isPasswordVisible = tuple.item2;

          final height = ComponentSize.large.h;

          return TextInputField(
            controller: context.read<SignUpModel>().passwordEditingController,
            errorText: passwordInputError,
            hintText: LocaleResources.of(context).passwordInputHint,
            height: height,
            isPassword: !isPasswordVisible,
            labelText: LocaleResources.of(context).passwordInputLabel,
            onChanged: (text) =>
                context.read<SignUpModel>().onPasswordInputChanged(text),
            suffixes: [
              PasswordVisibilityToggleSuffix(
                  hasError: (passwordInputError != null),
                  isPasswordVisible: isPasswordVisible,
                  size: height,
                  onPressed: () {
                    context.read<SignUpModel>().togglePasswordVisibility();
                  }),
            ],
          );
        });
  }

  Widget _buildTermsAgreementWidget() {
    final height = ComponentSize.smaller.r;
    return Row(children: [
      /// TOGGLE SWITCH
      Selector<SignUpModel, bool>(
          selector: (_, model) => model.hasAgreedToTerms,
          builder: (_, hasAgreedToTerms, __) {
            return ToggleSwitch(
                width: height * 2,
                height: height,
                checked: hasAgreedToTerms,
                onChanged: (checked) {
                  context.read<SignUpModel>().setHasAgreedToTerms(checked);
                });
          }),
      SizedBox(width: ComponentInset.small.w),

      /// TEXT + PRIVACY-POLICY-BUTTON + TEXT + TERMS-BUTTON
      Container(
          height: height,
          alignment: Alignment.center,
          child: Row(children: [
            Text(LocaleResources.of(context).signUpTermsAgreementPromptPart1,
                style: TextStyles.body),
            Button(
              onPressed: _onPrivacyPolicyTextTapped,
              type: ButtonType.text,
              text: LocaleResources.of(context).signUpTermsAgreementPromptPart2,
              textStyle: TextStyles.boldBody,
            ),
            Text(LocaleResources.of(context).signUpTermsAgreementPromptPart3,
                style: TextStyles.body),
            Button(
              onPressed: _onTermsTextTapped,
              type: ButtonType.text,
              text: LocaleResources.of(context).signUpTermsAgreementPromptPart4,
              textStyle: TextStyles.boldBody,
            )
          ]))
    ]);
  }

  Widget _buildRegisterButton() {
    return Button(
        width: 1.sw,
        height: ComponentSize.large.h,
        text: LocaleResources.of(context).registerButton,
        type: ButtonType.primary,
        onPressed: _onRegisterButtonPressed);
  }

  Widget _buildSignInPrompt() {
    return Container(
        height: ComponentSize.smaller.h,
        alignment: Alignment.center,
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(LocaleResources.of(context).signInButtonPrompt,
                  textAlign: TextAlign.center, style: TextStyles.heading5),
              SizedBox(width: ComponentInset.smaller.w),
              Button(
                  height: ComponentSize.small.h,
                  text: LocaleResources.of(context).signInButton,
                  type: ButtonType.text,
                  onPressed: _onSignInButtonPressed)
            ]));
  }

  /*
   * ACTIONS
   */

  void _onBackPressed() {
    DashboardNavigation.pop(context);
  }

  void _onCountryButtonTapped() async {
    _hideKeyboard();

    final selectedCountry = context.read<SignUpModel>().selectedCountry;
    final country =
        await CountryPickerBottomSheet.show(context, selectedCountry);

    if (!mounted) return;
    if (country != null) {
      context.read<SignUpModel>().updateCountry(country);
    }
  }

  void _onPrivacyPolicyTextTapped() {
    UrlLauncherUtil.openPrivacyPolicyPage(context);
  }

  void _onTermsTextTapped() {
    UrlLauncherUtil.openTermsConditionsPage(context);
  }

  void _hideKeyboard() {
    if (FocusScope.of(context).hasFocus) {
      FocusScope.of(context).unfocus();
    }
  }

  void _onRegisterButtonPressed() async {
    //=
    _hideKeyboard();
    showBlockingProgressDialog(context);

    final result = await context.read<SignUpModel>().signUp(context);

    if (!mounted) return;
    hideBlockingProgressDialog(context);

    if (result == null) return;

    if (!result.isSuccess()) {
      showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()));
      return;
    }

    final signUpRequest = result.data();
    switch (signUpRequest.type) {
      case IdentityType.email:
        {
          final email = signUpRequest.email;
          if (email == null) {
            showDefaultNotificationBar(NotificationBarInfo.error(
                message: LocaleResources.of(context).somethingWentWrong));
            return;
          }

          // Validate Email
          DashboardNavigation.pushReplacementNamed(
              context, Routes.authSignUpEmailVerification,
              arguments: EmailSignUpVerificationArgs(
                  email: email, password: signUpRequest.password));
          return;
        }
      case IdentityType.phoneNumber:
        {
          final country = signUpRequest.country;
          final phoneNumber = signUpRequest.phoneNumber;
          if (country == null || phoneNumber == null) {
            showDefaultNotificationBar(NotificationBarInfo.error(
                message: LocaleResources.of(context).somethingWentWrong));
            return;
          }

          // Validate Phone
          DashboardNavigation.pushReplacementNamed(
              context, Routes.authSignUpPhoneVerification,
              arguments: PhoneSignUpVerificationArgs(
                  country: country, phoneNumber: phoneNumber));
          return;
        }
    }
  }

  void _onSignInButtonPressed() {
    _hideKeyboard();
    DashboardNavigation.pushNamedAndRemoveUntil(
        context, Routes.authSignIn, (_) => false);
  }
}
