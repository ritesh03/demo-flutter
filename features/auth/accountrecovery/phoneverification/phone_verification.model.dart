import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/l10n/localizations.dart';

class PhoneVerificationArgs {
  final Country country;
  final String phoneNumber;
  final PhoneVerificationType type;
  final String? sourceRouteName;

  PhoneVerificationArgs({
    required this.country,
    required this.phoneNumber,
    required this.type,
    this.sourceRouteName,
  });
}

class PhoneVerificationResultArgs {
  final Country country;
  final String phoneNumber;
  final bool verified;

  PhoneVerificationResultArgs({
    required this.country,
    required this.phoneNumber,
    required this.verified,
  });
}

class PhoneVerificationModel with ChangeNotifier {
  final Country country;
  final String phoneNumber;
  final PhoneVerificationType verificationType;
  final String? sourceRouteName;

  PhoneVerificationModel({
    required PhoneVerificationArgs args,
  })  : country = args.country,
        phoneNumber = args.phoneNumber,
        verificationType = args.type,
        sourceRouteName = args.sourceRouteName;

  TextEditingController pinEditingController = TextEditingController();

  @override
  void dispose() {
    _resendVerificationCodeOp?.cancel();
    _validateVerificationCodeOp?.cancel();
    super.dispose();
  }

  /*
   * Resend Phone Verification Code
   */

  async.CancelableOperation? _resendVerificationCodeOp;

  Future<Result<PhoneVerificationCodeResponse>?>
      resendPhoneVerificationCode() async {
    // Cancel previous operation if active
    _resendVerificationCodeOp?.cancel();

    // Create request
    final request = PhoneVerificationCodeRequest(
      country: country,
      phoneNumber: phoneNumber,
      type: verificationType,
    );

    // Create operation
    final resendVerificationCodeOp = async.CancelableOperation<
            Result<PhoneVerificationCodeResponse>>.fromFuture(
        locator<KwotData>().authRepository.resendPhoneVerificationCode(request));
    _resendVerificationCodeOp = resendVerificationCodeOp;

    // Listen for result
    return await resendVerificationCodeOp.value.then((result) async {
      return result;
    });
  }

  /*
   * Validate Phone Verification Code
   */

  async.CancelableOperation? _validateVerificationCodeOp;

  Future<Result<PhoneVerificationResponse>?> validatePhoneVerificationCode(
      BuildContext context) async {
    //=
    final localization = LocaleResources.of(context);

    // Cancel previous operation if active
    _validateVerificationCodeOp?.cancel();

    // Validate Code Input
    final pinInput = pinEditingController.text;
    if (pinInput.isEmpty || pinInput.length != 6) {
      return Result.error(localization.errorEnterVerificationCode);
    }

    // Create request
    final request = PhoneVerificationRequest(
      country: country,
      phoneNumber: phoneNumber,
      type: verificationType,
      code: pinInput,
    );

    // Create operation
    final validateVerificationCodeOp =
        async.CancelableOperation<Result<PhoneVerificationResponse>>.fromFuture(
            locator<KwotData>().authRepository.validatePhoneVerificationCode(request));
    _validateVerificationCodeOp = validateVerificationCodeOp;

    // Listen for result
    return await validateVerificationCodeOp.value.then((result) async {
      return result;
    });
  }
}
