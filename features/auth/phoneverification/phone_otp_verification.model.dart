import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/l10n/localizations.dart';

abstract class PhoneOtpVerificationModel with ChangeNotifier {
  Future<Result> onCreateRequestOtpRequest({
    required Country country,
    required String phoneNumber,
  });

  Future<Result> onCreateVerifyOtpRequest({
    required Country country,
    required String phoneNumber,
    required String otp,
  });

  final Country country;
  final String phoneNumber;
  final bool shouldRequestOtp;

  PhoneOtpVerificationModel({
    required this.country,
    required this.phoneNumber,
    this.shouldRequestOtp = false,
  }) {
    if (shouldRequestOtp) {
      createInitialOtpRequest();
    }
  }

  TextEditingController pinEditingController = TextEditingController();

  @override
  void dispose() {
    _phoneOtpRequestOp?.cancel();
    _phoneOtpVerificationOp?.cancel();
    super.dispose();
  }

  Result? _initialOtpRequestResult;

  Result? get initialOtpRequestResult {
    if (!shouldRequestOtp) return Result.empty();
    return _initialOtpRequestResult;
  }

  void createInitialOtpRequest() async {
    if (_initialOtpRequestResult != null) {
      _initialOtpRequestResult = null;
      notifyListeners();
    }

    _initialOtpRequestResult = await requestPhoneVerificationOtp();
    notifyListeners();
  }

  /*
   * Request Phone Verification Code
   */

  async.CancelableOperation<Result>? _phoneOtpRequestOp;

  Future<Result?> requestPhoneVerificationOtp() async {
    // Cancel previous operation if active
    _phoneOtpRequestOp?.cancel();

    // Create request
    _phoneOtpRequestOp = async.CancelableOperation.fromFuture(
        onCreateRequestOtpRequest(country: country, phoneNumber: phoneNumber));

    // Listen for result
    return await _phoneOtpRequestOp!.value;
  }

  /*
   * Validate Phone Verification Code
   */

  async.CancelableOperation<Result>? _phoneOtpVerificationOp;

  Future<Result?> verifyPhoneSignUpOtp(BuildContext context) async {
    //=
    final localization = LocaleResources.of(context);

    // Cancel previous operation if active
    _phoneOtpVerificationOp?.cancel();

    // Validate Code Input
    final pinInput = pinEditingController.text;
    if (pinInput.isEmpty || pinInput.length != 6) {
      return Result.error(localization.errorEnterVerificationCode);
    }

    // Create request
    _phoneOtpVerificationOp = async.CancelableOperation.fromFuture(
      onCreateVerifyOtpRequest(
        country: country,
        phoneNumber: phoneNumber,
        otp: pinInput,
      ),
    );

    // Listen for result
    return await _phoneOtpVerificationOp!.value;
  }
}
