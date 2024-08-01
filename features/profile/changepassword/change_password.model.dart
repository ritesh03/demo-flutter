import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/util/validator.dart';

class ChangePasswordModel with ChangeNotifier {
  //=

  TextEditingController currentPasswordEditingController =
      TextEditingController();
  TextEditingController newPasswordEditingController = TextEditingController();
  TextEditingController repeatPasswordEditingController =
      TextEditingController();

  @override
  void dispose() {
    _changePasswordOp?.cancel();
    super.dispose();
  }

  bool get canSave {
    return currentPasswordEditingController.text.isNotEmpty &&
        newPasswordEditingController.text.isNotEmpty &&
        repeatPasswordEditingController.text.isNotEmpty;
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
   * Current Password Input
   */

  String? _currentPasswordInputError;

  String? get currentPasswordInputError => _currentPasswordInputError;

  void onCurrentPasswordInputChanged(String text) {
    _notifyCurrentPasswordInputError(null);
  }

  void _notifyCurrentPasswordInputError(String? error) {
    _currentPasswordInputError = error;
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
   * Change Password
   */

  async.CancelableOperation<Result>? _changePasswordOp;

  Future<Result?> changePassword(BuildContext context) async {
    final localization = LocaleResources.of(context);

    final currentPasswordInput = currentPasswordEditingController.text;
    final newPasswordInput = newPasswordEditingController.text;
    final repeatPasswordInput = repeatPasswordEditingController.text;

    String? currentPasswordInputError;
    if (currentPasswordInput.isEmpty) {
      currentPasswordInputError =
          localization.errorCurrentPasswordCannotBeEmpty;
    }

    String? newPasswordInputError =
        Validator.validatePassword(context, newPasswordInput);

    String? repeatPasswordInputError;
    if (repeatPasswordInput.isEmpty) {
      repeatPasswordInputError = localization.errorRepeatPasswordCannotBeEmpty;
    } else if (repeatPasswordInput != newPasswordInput) {
      repeatPasswordInputError = localization.errorRepeatPasswordMismatch;
    }

    _notifyCurrentPasswordInputError(currentPasswordInputError);
    _notifyNewPasswordInputError(newPasswordInputError);
    _notifyRepeatPasswordInputError(repeatPasswordInputError);

    if (currentPasswordInputError != null ||
        newPasswordInputError != null ||
        repeatPasswordInputError != null) {
      return null;
    }

    // Create request
    final request = ChangePasswordRequest(
      currentPassword: currentPasswordInput,
      newPassword: newPasswordInput,
    );

    // Create operation
    final changePasswordOp = async.CancelableOperation.fromFuture(
        locator<KwotData>().accountRepository.changePassword(request));
    _changePasswordOp = changePasswordOp;

    // Listen for result
    return await changePasswordOp.value;
  }
}
