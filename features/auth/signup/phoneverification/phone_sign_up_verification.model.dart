import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/features/auth/phoneverification/phone_otp_verification.model.dart';

class PhoneSignUpVerificationArgs {
  final Country country;
  final String phoneNumber;

  PhoneSignUpVerificationArgs({
    required this.country,
    required this.phoneNumber,
  });
}

class PhoneSignUpVerificationModel extends PhoneOtpVerificationModel {
  PhoneSignUpVerificationModel({
    required PhoneSignUpVerificationArgs args,
  }) : super(country: args.country, phoneNumber: args.phoneNumber);

  @override
  Future<Result> onCreateRequestOtpRequest({
    required Country country,
    required String phoneNumber,
  }) {
    final request = PhoneSignUpOtpRequest(
      country: country,
      phoneNumber: phoneNumber,
    );
    return locator<KwotData>().authRepository.requestPhoneSignUpOtp(request);
  }

  @override
  Future<Result> onCreateVerifyOtpRequest({
    required Country country,
    required String phoneNumber,
    required String otp,
  }) {
    final request = PhoneSignUpOtpVerificationRequest(
      country: country,
      phoneNumber: phoneNumber,
      otp: otp,
    );
    return locator<KwotData>().authRepository.verifyPhoneSignUpOtp(request);
  }
}
