import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter/services.dart';
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/app_config.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/blocking_progress.dialog.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/notificationbar/notification_bar.dart';
import 'package:kwotmusic/components/widgets/textfield.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/auth/auth_actions.model.dart';
import 'package:kwotmusic/features/auth/authentication_state.dart';
import 'package:kwotmusic/features/auth/signin/sign_in_args.dart';
import 'package:kwotmusic/features/auth/signup/emailverification/email_sign_up_verification.model.dart';
import 'package:kwotmusic/features/auth/signup/phoneverification/phone_sign_up_verification.model.dart';
import 'package:kwotmusic/features/misc/address/countrypicker/country_picker.bottomsheet.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:kwotmusic/util/util.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import 'sign_in.model.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends AuthenticationState<SignInPage> {
  @override
  String get pageTag => "sign-in";

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final signInPageArgs = obtainRouteArgs<SignInPageArgs?>(context);

      // Show startup notification (if present)
      final notificationBarInfo = signInPageArgs?.startupNotificationBarInfo;
      if (notificationBarInfo != null) {
        showDefaultNotificationBar(notificationBarInfo);
      }
    });
  }

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
                      _buildLogo(),
                      SizedBox(height: ComponentInset.normal.h),
                      _buildTitle(),
                      SizedBox(height: ComponentInset.medium.h),
                      _buildIdentityInputField(),
                      SizedBox(height: ComponentInset.normal.h),
                      _buildAlternateSignInOption(),
                      SizedBox(height: ComponentInset.medium.h),
                      _buildPasswordInputField(),
                      SizedBox(height: ComponentInset.normal.h),
                      _buildForgotPasswordButton(),
                      SizedBox(height: ComponentInset.medium.h),
                      _buildSignInButton(),
                      // SizedBox(height: ComponentInset.medium.h),
                      // _buildSignInOptionsSeparator(),
                      // SizedBox(height: ComponentInset.medium.h),
                      // _buildSignInOptions(),
                      SizedBox(height: ComponentInset.medium.h),
                      _buildRegistrationPrompt(),
                      SizedBox(height: ComponentInset.medium.h),
                    ]),
              )),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
        height: ComponentSize.normal.h,
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.only(top: ComponentInset.small.h),
        child: Image.asset(Assets.graphicLogoRoundedSmall));
  }

  Widget _buildTitle() {
    return Container(
        height: ComponentSize.normal.h,
        alignment: Alignment.centerLeft,
        child: Text(LocaleResources.of(context).signInPageTitle,
            style: TextStyles.boldHeading1));
  }

  Widget _buildIdentityInputField() {
    return Selector<SignInModel, IdentityType>(
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
    return Selector<SignInModel, String?>(
        selector: (_, model) => model.emailInputError,
        builder: (_, error, __) {
          return TextInputField(
            controller: context.read<SignInModel>().emailEditingController,
            errorText: error,
            height: ComponentSize.large.h,
            hintText: LocaleResources.of(context).emailInputHint,
            labelText: LocaleResources.of(context).emailInputLabel,
            onChanged: (text) =>
                context.read<SignInModel>().onEmailInputChanged(text),
            keyboardType: TextInputType.emailAddress,
          );
        });
  }

  Widget _buildPhoneInputField() {
    return Selector<SignInModel, Tuple2<String?, Country>>(
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
            controller: context.read<SignInModel>().phoneEditingController,
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
                context.read<SignInModel>().onPhoneNumberInputChanged(text),
          );
        });
  }

  Widget _buildAlternateSignInOption() {
    return Selector<SignInModel, IdentityType>(
        selector: (_, model) => model.identityType,
        builder: (_, identityType, __) {
          final String buttonText;
          switch (identityType) {
            case IdentityType.email:
              buttonText = LocaleResources.of(context).signInWithPhoneNumber;
              break;
            case IdentityType.phoneNumber:
              buttonText = LocaleResources.of(context).signInWithEmail;
              break;
          }
          return Button(
              height: ComponentSize.smaller.h,
              text: buttonText,
              type: ButtonType.text,
              onPressed: _onSignInMethodToggleTapped);
        });
  }

  Widget _buildPasswordInputField() {
    return Selector<SignInModel, Tuple2<String?, bool>>(
        selector: (_, model) => Tuple2(
              model.passwordInputError,
              model.isPasswordVisible,
            ),
        builder: (_, tuple, __) {
          final passwordInputError = tuple.item1;
          final isPasswordVisible = tuple.item2;

          final height = ComponentSize.large.h;

          return TextInputField(
            controller: context.read<SignInModel>().passwordEditingController,
            errorText: passwordInputError,
            hintText: LocaleResources.of(context).passwordInputHint,
            height: height,
            isPassword: !isPasswordVisible,
            labelText: LocaleResources.of(context).passwordInputLabel,
            onChanged: (text) =>
                context.read<SignInModel>().onPasswordInputChanged(text),
            suffixes: [
              PasswordVisibilityToggleSuffix(
                  hasError: (passwordInputError != null),
                  isPasswordVisible: isPasswordVisible,
                  size: height,
                  onPressed: _onPasswordVisibilityToggleTapped),
            ],
          );
        });
  }

  Widget _buildForgotPasswordButton() {
    return Button(
        height: ComponentSize.smaller.h,
        text: LocaleResources.of(context).forgotPasswordButton,
        type: ButtonType.text,
        onPressed: _onForgotPasswordButtonPressed);
  }

  Widget _buildSignInButton() {
    return Button(
        width: 1.sw,
        height: ComponentSize.large.h,
        text: LocaleResources.of(context).signInButton,
        type: ButtonType.primary,
        onPressed: _onSignInButtonPressed);
  }

  Widget _buildSignInOptionsSeparator() {
    return Container(
        width: 1.sw,
        height: ComponentSize.smallest.h,
        alignment: Alignment.center,
        child: Text(LocaleResources.of(context).signInOptionsSeparator,
            textAlign: TextAlign.center,
            style: TextStyles.heading6.copyWith(
              color: DynamicTheme.get(context).neutral20(),
            )));
  }

  Widget _buildSignInOptions() {
    final buttonSize = 40.sm;
    final borderRadius = BorderRadius.circular(ComponentRadius.normal.r);
    final rightInsetMargin = EdgeInsets.only(right: ComponentInset.normal.w);
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      AppIconButton(
          width: buttonSize,
          height: buttonSize,
          assetPath: Assets.graphicGoogle,
          borderRadius: borderRadius,
          margin: rightInsetMargin,
          onPressed: _onGoogleSignInButtonPressed),
      AppIconButton(
          width: buttonSize,
          height: buttonSize,
          assetPath: Assets.graphicInstagram,
          borderRadius: borderRadius,
          margin: rightInsetMargin,
          onPressed: _onInstagramSignInButtonPressed),
      AppIconButton(
          width: buttonSize,
          height: buttonSize,
          assetPath: Assets.graphicLinkedin,
          borderRadius: borderRadius,
          margin: rightInsetMargin,
          onPressed: _onLinkedinSignInButtonPressed),
      AppIconButton(
          width: buttonSize,
          height: buttonSize,
          assetPath: Assets.graphicTwitter,
          borderRadius: borderRadius,
          margin: rightInsetMargin,
          onPressed: _onTwitterSignInButtonPressed),
      AppIconButton(
          width: buttonSize,
          height: buttonSize,
          assetPath: Assets.graphicFacebook,
          borderRadius: borderRadius,
          margin: rightInsetMargin,
          onPressed: _onFacebookSignInButtonPressed),
      AppIconButton(
          width: buttonSize,
          height: buttonSize,
          assetPath: Assets.graphicApple,
          borderRadius: borderRadius,
          onPressed: _onAppleSignInButtonPressed),
    ]);
  }

  Widget _buildRegistrationPrompt() {
    return Container(
      height: ComponentSize.smaller.h,
      alignment: Alignment.center,
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(LocaleResources.of(context).registerButtonPrompt,
                textAlign: TextAlign.center, style: TextStyles.heading5),
            SizedBox(width: ComponentInset.smaller.w),
            Button(
                height: ComponentSize.small.h,
                text: LocaleResources.of(context).registerButton,
                type: ButtonType.text,
                onPressed: _onRegisterButtonPressed)
          ]),
    );
  }

  /*
   * ACTIONS
   */

  void _hideKeyboard() {
    if (FocusScope.of(context).hasFocus) {
      FocusScope.of(context).unfocus();
    }
  }

  void _onCountryButtonTapped() async {
    analytics.onTap(where: "choose-country");

    hideKeyboard(context);

    final selectedCountry = context.read<SignInModel>().selectedCountry;
    final country =
        await CountryPickerBottomSheet.show(context, selectedCountry);

    if (!mounted) return;
    if (country != null) {
      context.read<SignInModel>().updateCountry(country);
    }
  }

  void _onSignInMethodToggleTapped() {
    analytics.onTap(where: "switch-sign-in-method");
    context.read<SignInModel>().toggleIdentityType();
  }

  void _onPasswordVisibilityToggleTapped() {
    analytics.onTap(where: "password-visibility");
    context.read<SignInModel>().togglePasswordVisibility();
  }

  void _onForgotPasswordButtonPressed() {
    analytics.onTap(where: "forgot-password");
    DashboardNavigation.pushNamed(context, Routes.requestAccountRecovery);
  }

  void _onSignInButtonPressed() {
    analytics.onTap(where: "sign-in");

    _hideKeyboard();
    showBlockingProgressDialog(context);

    context.read<SignInModel>()
        .authenticateWithPassword(context)
        .then((result) => _onSignInResultAvailable(result));
  }

  void _onGoogleSignInButtonPressed() {
    //=
    _hideKeyboard();
    showBlockingProgressDialog(context);

    context
        .read<SignInModel>()
        .authenticateWithGoogle()
        .then((result) => _onSignInResultAvailable(result));
  }

  void _onInstagramSignInButtonPressed() {
    //=
    _hideKeyboard();
    showBlockingProgressDialog(context);

    context
        .read<SignInModel>()
        .authenticateWithInstagram()
        .then((result) => _onSignInResultAvailable(result));
  }

  void _onLinkedinSignInButtonPressed() {
    //=
    _hideKeyboard();
    showBlockingProgressDialog(context);

    context
        .read<SignInModel>()
        .authenticateWithLinkedin()
        .then((result) => _onSignInResultAvailable(result));
  }

  void _onTwitterSignInButtonPressed() {
    //=
    _hideKeyboard();
    showBlockingProgressDialog(context);

    context
        .read<SignInModel>()
        .authenticateWithTwitter()
        .then((result) => _onSignInResultAvailable(result));
  }

  void _onFacebookSignInButtonPressed() {
    //=
    _hideKeyboard();
    showBlockingProgressDialog(context);

    context
        .read<SignInModel>()
        .authenticateWithFacebook()
        .then((result) => _onSignInResultAvailable(result));
  }

  void _onAppleSignInButtonPressed() {
    //=
    _hideKeyboard();
    showBlockingProgressDialog(context);

    context
        .read<SignInModel>()
        .authenticateWithApple()
        .then((result) => _onSignInResultAvailable(result));
  }

  void _onSignInResultAvailable(Result<AuthResult>? result) async {
    if (!mounted) return;
    hideBlockingProgressDialog(context);

    if (result == null) return;

    if (!result.isSuccess()) {
      if (result.isForbidden) {
        final handled = await _handleAccountVerificationError(result: result);
        if (handled) return;
      }

      showDefaultNotificationBar(
        NotificationBarInfo.error(message: result.error()),
      );
      return;
    }

    // TODO: Has selected genres?
    _showDashboardPage();
  }

  void _onRegisterButtonPressed() {
    analytics.onTap(where: "sign-up");
    DashboardNavigation.pushNamed(context, Routes.authSignUp);
  }

  void _showDashboardPage() {
    if (!mounted) return;
    DashboardNavigation.pushNamedAndRemoveUntil(
        context, Routes.dashboard, (route) => false);
  }

  Future<bool> _handleAccountVerificationError({
    required Result<AuthResult?> result,
  }) async {
    if (!mounted) return false;

    final authRequest = context.read<SignInModel>().authRequest;
    if (authRequest == null) {
      return false;
    }

    switch (authRequest.type) {

      /// EMAIL is not verified
      case AuthType.email:
        final success = await _requestEmailSignUpOtp(email: authRequest.email!);
        if (success && mounted) {
          Navigator.pushNamed(context, Routes.authSignUpEmailVerification,
              arguments: EmailSignUpVerificationArgs(
                  email: authRequest.email!, password: authRequest.password!));
        }
        return success;

      /// PHONE is not verified
      case AuthType.phoneNumber:
        final success = await _requestPhoneSignUpOtp(
          country: authRequest.country!,
          phoneNumber: authRequest.phoneNumber!,
        );
        if (success && mounted) {
          Navigator.pushNamed(context, Routes.authSignUpPhoneVerification,
              arguments: PhoneSignUpVerificationArgs(
                  country: authRequest.country!,
                  phoneNumber: authRequest.phoneNumber!));
        }
        return success;
      default:
        return false;
    }
  }

  Future<bool> _requestEmailSignUpOtp({
    required String email,
  }) async {
    if (!mounted) return false;
    showBlockingProgressDialog(context);

    final result = await locator<AuthActionsModel>().requestEmailSignUpOtp(
      email: email,
    );

    if (!mounted) return false;
    hideBlockingProgressDialog(context);

    return result.isSuccess();
  }

  Future<bool> _requestPhoneSignUpOtp({
    required Country country,
    required String phoneNumber,
  }) async {
    if (!mounted) return false;
    showBlockingProgressDialog(context);

    final result = await locator<AuthActionsModel>().requestPhoneSignUpOtp(
      country: country,
      phoneNumber: phoneNumber,
    );

    if (!mounted) return false;
    hideBlockingProgressDialog(context);

    return result.isSuccess();
  }
}
