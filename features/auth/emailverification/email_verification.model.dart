import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';

abstract class EmailVerificationModel with ChangeNotifier {
  Future<Result> onCreateRequestOtpRequest({
    required String email,
  });

  Future<Result> onCreateVerifyOtpRequest({
    required String email,
  });

  final String email;
  final bool shouldRequestOtp;

  EmailVerificationModel({
    required this.email,
    this.shouldRequestOtp = false,
  }) {
    if (shouldRequestOtp) {
      createInitialOtpRequest();
    }
  }

  @override
  void dispose() {
    _emailOtpRequestOp?.cancel();
    _emailOtpVerificationOp?.cancel();
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

    _initialOtpRequestResult = await requestEmailVerificationOtp();
    notifyListeners();
  }

  /*
   * Request Email Verification
   */

  async.CancelableOperation<Result>? _emailOtpRequestOp;

  Future<Result?> requestEmailVerificationOtp() async {
    // Cancel previous operation if active
    _emailOtpRequestOp?.cancel();

    // Create request
    _emailOtpRequestOp = async.CancelableOperation.fromFuture(
        onCreateRequestOtpRequest(email: email));

    // Listen for result
    return await _emailOtpRequestOp!.value;
  }

  /*
   * Validate Email Verification
   */

  async.CancelableOperation<Result>? _emailOtpVerificationOp;

  Future<Result?> verifyEmailOtp() async {
    //=

    // Cancel previous operation if active
    _emailOtpVerificationOp?.cancel();

    // Create request
    _emailOtpVerificationOp = async.CancelableOperation.fromFuture(
      onCreateVerifyOtpRequest(
        email: email,
      ),
    );

    // Listen for result
    return await _emailOtpVerificationOp!.value;
  }
}
