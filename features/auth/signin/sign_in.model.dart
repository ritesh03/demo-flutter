import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/app_config.dart';
import 'package:kwotmusic/util/validator.dart';

class SignInModel with ChangeNotifier {
  //=

  TextEditingController emailEditingController = TextEditingController();
  TextEditingController phoneEditingController = TextEditingController();
  TextEditingController passwordEditingController = TextEditingController();

  @override
  void dispose() {
    _authenticateOp?.cancel();
    _authenticateOp = null;
    super.dispose();
  }

  /*
   * Identity Type
   */

  IdentityType _identityType = IdentityType.email;

  IdentityType get identityType => _identityType;

  void toggleIdentityType() {
    if (_identityType == IdentityType.email) {
      _identityType = IdentityType.phoneNumber;
    } else if (_identityType == IdentityType.phoneNumber) {
      _identityType = IdentityType.email;
    } else {
      throw Exception("Unknown identity-type for signing in: $identityType");
    }
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
   * Password Visibility On/Off
   */

  bool _isPasswordVisible = false;

  bool get isPasswordVisible => _isPasswordVisible;

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
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
   * Authentication
   */

  AuthRequest? _currentAuthRequest;

  AuthRequest? get authRequest => _currentAuthRequest;

  async.CancelableOperation? _authenticateOp;

  Future<Result<AuthResult>?> authenticateWithPassword(
      BuildContext context) async {
    final emailInput = emailEditingController.text.trim().toLowerCase();
    final phoneNumberInput = phoneEditingController.text.trim();
    final passwordInput = passwordEditingController.text;

    // Validate Email or Phone Number based on identity-type
    String? emailInputError;
    String? phoneInputError;
    switch (identityType) {
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

    // Validate password
    final passwordInputError = Validator.validatePassword(
      context,
      passwordInput,
      checkExistenceOnly: true,
    );
    _notifyPasswordInputError(passwordInputError);

    if (emailInputError != null ||
        phoneInputError != null ||
        passwordInputError != null) {
      // One of the validations failed.
      return null;
    }

    // Create request
    final AuthRequest request;
    switch (identityType) {
      case IdentityType.email:
        request = AuthRequest.email(email: emailInput, password: passwordInput);
        break;
      case IdentityType.phoneNumber:
        request = AuthRequest.phoneNumber(
            country: selectedCountry,
            phoneNumber: phoneNumberInput,
            password: passwordInput);
        break;
      default:
        throw Exception(
            "Unknown identity-type for password authentication: $identityType");
    }

    return _enqueueAuthentication(request);
  }

  Future<Result<AuthResult>?> authenticateWithGoogle() async {
    final request = AuthRequest.google(
      identifier: "google-user",
      accessToken: "some-access-token",
    );

    return _enqueueAuthentication(request);
  }

  Future<Result<AuthResult>?> authenticateWithInstagram() async {
    final request = AuthRequest.instagram(
      identifier: "instagram-user",
      accessToken: "some-access-token",
    );

    return _enqueueAuthentication(request);
  }

  Future<Result<AuthResult>?> authenticateWithLinkedin() async {
    final request = AuthRequest.linkedin(
      identifier: "linkedin-user",
      accessToken: "some-access-token",
    );

    return _enqueueAuthentication(request);
  }

  Future<Result<AuthResult>?> authenticateWithTwitter() async {
    final request = AuthRequest.twitter(
      identifier: "twitter-user",
      accessToken: "some-access-token",
    );

    return _enqueueAuthentication(request);
  }

  Future<Result<AuthResult>?> authenticateWithFacebook() async {
    final request = AuthRequest.facebook(
      identifier: "facebook-user",
      accessToken: "some-access-token",
    );

    return _enqueueAuthentication(request);
  }

  Future<Result<AuthResult>?> authenticateWithApple() async {
    final request = AuthRequest.facebook(
      identifier: "apple-user",
      accessToken: "some-access-token",
    );

    return _enqueueAuthentication(request);
  }

  Future<Result<AuthResult>?> _enqueueAuthentication(
    AuthRequest request,
  ) async {
    _currentAuthRequest = request;
    _authenticateOp?.cancel();

    // Create operation
    final authenticateOp =
        async.CancelableOperation<Result<AuthResult>>.fromFuture(
            locator<KwotData>().authRepository.authenticate(request));
    _authenticateOp = authenticateOp;

    // Listen for result
    return await authenticateOp.value;
  }
}
