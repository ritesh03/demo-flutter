import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/app_config.dart';
import 'package:kwotmusic/util/validator.dart';

class RequestAccountRecoveryModel with ChangeNotifier {
  //=

  TextEditingController emailEditingController = TextEditingController();
  TextEditingController phoneEditingController = TextEditingController();

  @override
  void dispose() {
    _requestResetPasswordOp?.cancel();
    _requestResetPasswordOp = null;
    super.dispose();
  }

  /*
   * Recovery Identity Type
   */

  IdentityType _identityType = IdentityType.email;

  IdentityType get identityType => _identityType;

  void toggleIdentityType() {
    if (_identityType == IdentityType.email) {
      _identityType = IdentityType.phoneNumber;
    } else if (_identityType == IdentityType.phoneNumber) {
      _identityType = IdentityType.email;
    } else {
      throw Exception("Unknown identity-type for recovery: $identityType");
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
   * Request Account Recovery
   */

  async.CancelableOperation? _requestResetPasswordOp;

  Future<Result<AccountRecoveryRequestResponse>?> requestAccountRecovery(
      BuildContext context) async {
    final emailInput = emailEditingController.text.trim().toLowerCase();
    final phoneNumberInput = phoneEditingController.text.trim();

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

    if (emailInputError != null || phoneInputError != null) {
      // One of the validations failed.
      return null;
    }

    // Create request
    final AccountRecoveryRequestRequest request;
    switch (_identityType) {
      case IdentityType.email:
        request = AccountRecoveryRequestRequest.email(email: emailInput);
        break;
      case IdentityType.phoneNumber:
        request = AccountRecoveryRequestRequest.phoneNumber(
            country: selectedCountry, phoneNumber: phoneNumberInput);
        break;
      default:
        throw Exception("Unknown identity for recovery: $_identityType");
    }

    // Create operation
    final requestResetPasswordOp = async.CancelableOperation<
            Result<AccountRecoveryRequestResponse>>.fromFuture(
        locator<KwotData>().authRepository.requestAccountRecovery(request));
    _requestResetPasswordOp = requestResetPasswordOp;

    // Listen for result
    return await requestResetPasswordOp.value.then((result) async {
      return result;
    });
  }
}
