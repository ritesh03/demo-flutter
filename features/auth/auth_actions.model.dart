import 'package:async/async.dart' as async;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';

class AuthActionsModel {
  /*
   * API: Email - Request Sign Up Verification Email
   */

  async.CancelableOperation<Result>? _requestEmailSignUpOtpOp;

  Future<Result> requestEmailSignUpOtp({
    required String email,
  }) async {
    try {
      // Cancel current operation (if any)
      _requestEmailSignUpOtpOp?.cancel();

      // Create Request
      final request = EmailSignUpOtpRequest(email: email);
      _requestEmailSignUpOtpOp = async.CancelableOperation.fromFuture(
          locator<KwotData>().authRepository.requestEmailSignUpOtp(request));

      // Wait for result
      return await _requestEmailSignUpOtpOp!.value;
    } catch (error) {
      return Result.error("Error: $error");
    }
  }

  /*
   * API: Phone - Request Sign Up Verification OTP
   */

  async.CancelableOperation<Result>? _requestPhoneSignUpOtpOp;

  Future<Result> requestPhoneSignUpOtp({
    required Country country,
    required String phoneNumber,
  }) async {
    try {
      // Cancel current operation (if any)
      _requestPhoneSignUpOtpOp?.cancel();

      // Create Request
      final request = PhoneSignUpOtpRequest(
        country: country,
        phoneNumber: phoneNumber,
      );
      _requestPhoneSignUpOtpOp = async.CancelableOperation.fromFuture(
          locator<KwotData>().authRepository.requestPhoneSignUpOtp(request));

      // Wait for result
      return await _requestPhoneSignUpOtpOp!.value;
    } catch (error) {
      return Result.error("Error: $error");
    }
  }
}
