import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/util/validator.dart';

class SetPasswordArgs {
  final Country country;
  final String phoneNumber;
  final String requestToken;
  final String? sourceRouteName;

  SetPasswordArgs({
    required this.country,
    required this.phoneNumber,
    required this.requestToken,
    this.sourceRouteName,
  });
}

class SetPasswordModel with ChangeNotifier {
  final Country country;
  final String phoneNumber;
  final String requestToken;
  final String? sourceRouteName;

  SetPasswordModel({
    required SetPasswordArgs args,
  })  : country = args.country,
        phoneNumber = args.phoneNumber,
        requestToken = args.requestToken,
        sourceRouteName = args.sourceRouteName;

  TextEditingController newPasswordEditingController = TextEditingController();
  TextEditingController repeatPasswordEditingController =
      TextEditingController();

  @override
  void dispose() {
    _setPasswordOp?.cancel();
    super.dispose();
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
   * New Password Input
   */

  String? _newPasswordInputError;

  String? get newPasswordInputError => _newPasswordInputError;

  void onNewPasswordInputChanged(String text) {
    _notifyNewPasswordInputError(null);
  }

  void _notifyNewPasswordInputError(String? error) {
    _newPasswordInputError = error;
    notifyListeners();
  }

  /*
   * Repeat Password Input
   */

  String? _repeatPasswordInputError;

  String? get repeatPasswordInputError => _repeatPasswordInputError;

  void _notifyRepeatPasswordInputError(String? error) {
    _repeatPasswordInputError = error;
    notifyListeners();
  }

  void onRepeatPasswordInputChanged(String text) {
    _notifyRepeatPasswordInputError(null);
  }

  /*
   * Set Password
   */

  async.CancelableOperation? _setPasswordOp;

  Future<Result<SetPasswordResponse>?> setPassword(BuildContext context) async {
    final localization = LocaleResources.of(context);

    final newPasswordInput = newPasswordEditingController.text;
    final repeatPasswordInput = repeatPasswordEditingController.text;

    String? newPasswordInputError =
        Validator.validatePassword(context, newPasswordInput);

    String? repeatPasswordInputError;
    if (repeatPasswordInput.isEmpty) {
      repeatPasswordInputError = localization.errorRepeatPasswordCannotBeEmpty;
    } else if (repeatPasswordInput != newPasswordInput) {
      repeatPasswordInputError = localization.errorRepeatPasswordMismatch;
    }

    _notifyNewPasswordInputError(newPasswordInputError);
    _notifyRepeatPasswordInputError(repeatPasswordInputError);

    if (newPasswordInputError != null || repeatPasswordInputError != null) {
      return null;
    }

    // Create request
    final request = SetPasswordRequest(
      country: country,
      phoneNumber: phoneNumber,
      password: newPasswordInput,
      requestToken: requestToken,
    );

    // Create operation
    final setPasswordOp =
        async.CancelableOperation<Result<SetPasswordResponse>>.fromFuture(
            locator<KwotData>().authRepository.setPassword(request));
    _setPasswordOp = setPasswordOp;

    // Listen for result
    return await setPasswordOp.value.then((result) async {
      return result;
    });
  }
}
