import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/app_config.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/util/validator.dart';

class SignUpModel with ChangeNotifier {
  TextEditingController firstNameEditingController = TextEditingController();
  TextEditingController lastNameEditingController = TextEditingController();
  TextEditingController emailEditingController = TextEditingController();
  TextEditingController phoneEditingController = TextEditingController();
  TextEditingController passwordEditingController = TextEditingController();

  @override
  void dispose() {
    _signUpOp?.cancel();
    _signUpOp = null;
    super.dispose();
  }

  /*
   * Registration Identity Type
   */

  IdentityType _registrationIdentityType = IdentityType.email;

  IdentityType get registrationIdentityType => _registrationIdentityType;

  void toggleRegistrationIdentityType() {
    if (_registrationIdentityType == IdentityType.email) {
      _registrationIdentityType = IdentityType.phoneNumber;
    } else if (_registrationIdentityType == IdentityType.phoneNumber) {
      _registrationIdentityType = IdentityType.email;
    } else {
      throw Exception(
          "Unknown identity-type for registration: $registrationIdentityType");
    }
    notifyListeners();
  }

  /*
   * Password Visibility On/Off
   */

  bool _isPasswordVisible = false;

  bool get isPasswordVisible => _isPasswordVisible;

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  /*
   * First Name Input
   */

  String? _firstNameInputError;

  String? get firstNameInputError => _firstNameInputError;

  void onFirstNameInputChanged(String text) {
    _notifyFirstNameInputError(null);
  }

  void _notifyFirstNameInputError(String? error) {
    _firstNameInputError = error;
    notifyListeners();
  }

  /*
   * Last Name Input
   */

  String? _lastNameInputError;

  String? get lastNameInputError => _lastNameInputError;

  void onLastNameInputChanged(String text) {
    _notifyLastNameInputError(null);
  }

  void _notifyLastNameInputError(String? error) {
    _lastNameInputError = error;
    notifyListeners();
  }

  /*
   * Email Input
   */

  String? _emailInputError;

  String? get emailInputError => _emailInputError;

  void onEmailInputChanged(String text) {
    _notifyEmailInputError(null);
  }

  void _notifyEmailInputError(String? error) {
    _emailInputError = error;
    notifyListeners();
  }

  /*
   * Country
   */

  Country selectedCountry = AppConfig.defaultCountry;

  void updateCountry(Country country) {
    selectedCountry = country;
    notifyListeners();
  }

  /*
   * Phone Number Input
   */

  String? _phoneNumberInputError;

  String? get phoneNumberInputError => _phoneNumberInputError;

  void onPhoneNumberInputChanged(String text) {
    _notifyPhoneNumberInputError(null);
  }

  void _notifyPhoneNumberInputError(String? error) {
    _phoneNumberInputError = error;
    notifyListeners();
  }

  /*
   * Password Input
   */

  String? _passwordInputError;

  String? get passwordInputError => _passwordInputError;

  void onPasswordInputChanged(String text) {
    _notifyPasswordInputError(null);
  }

  void _notifyPasswordInputError(String? error) {
    _passwordInputError = error;
    notifyListeners();
  }

  /*
   * Terms Agreement
   */

  bool _hasAgreedToTerms = false;

  bool get hasAgreedToTerms => _hasAgreedToTerms;

  void setHasAgreedToTerms(bool hasAgreedToTerms) {
    _hasAgreedToTerms = hasAgreedToTerms;
    notifyListeners();
  }

  /*
   * Sign Up
   */

  async.CancelableOperation<Result>? _signUpOp;

  Future<Result<SignUpRequest>?> signUp(BuildContext context) async {
    final localization = LocaleResources.of(context);

    final firstNameInput = firstNameEditingController.text.trim();
    final lastNameInput = lastNameEditingController.text.trim();
    final emailInput = emailEditingController.text.trim().toLowerCase();
    final phoneNumberInput = phoneEditingController.text.trim();
    final passwordInput = passwordEditingController.text;

    // Validate First Name
    String? firstNameInputError;
    if (firstNameInput.isEmpty) {
      firstNameInputError = localization.errorEnterFirstName;
    }
    _notifyFirstNameInputError(firstNameInputError);

    // Validate Last Name
    String? lastNameInputError;
    if (lastNameInput.isEmpty) {
      lastNameInputError = localization.errorEnterLastName;
    }
    _notifyLastNameInputError(lastNameInputError);

    // Validate Email or Phone Number based on registration-type
    String? emailInputError;
    String? phoneInputError;
    switch (registrationIdentityType) {
      case IdentityType.email:
        emailInputError = Validator.validateEmail(context, emailInput);
        break;
      case IdentityType.phoneNumber:
        phoneInputError =
            Validator.validatePhoneNumber(context, phoneNumberInput);
        break;
    }
    _notifyEmailInputError(emailInputError);
    _notifyPhoneNumberInputError(phoneInputError);

    // Validate Password
    String? passwordInputError =
        Validator.validatePassword(context, passwordInput);
    _notifyPasswordInputError(passwordInputError);

    if (firstNameInputError != null ||
        lastNameInputError != null ||
        emailInputError != null ||
        phoneNumberInputError != null ||
        passwordInputError != null) {
      // One of the validations failed.
      return null;
    }

    // Validate Terms Agreement
    if (!hasAgreedToTerms) {
      return Result.error(localization.errorTermsAgreementNotAccepted);
    }

    // Create operation
    final type = registrationIdentityType;
    final request = SignUpRequest(
      firstName: firstNameInput,
      lastName: lastNameInput,
      type: type,
      email: (type == IdentityType.email) ? emailInput : null,
      country: (type == IdentityType.phoneNumber) ? selectedCountry : null,
      phoneNumber: (type == IdentityType.phoneNumber) ? phoneNumberInput : null,
      password: passwordInput,
      hasAgreedToTerms: hasAgreedToTerms,
    );

    final signUpOp = async.CancelableOperation.fromFuture(
        locator<KwotData>().authRepository.signUp(request));
    _signUpOp = signUpOp;

    // Listen for result
    final result = await signUpOp.value;
    return result.replaceData(request);
  }
}
