import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/features/auth/phoneverification/phone_otp_verification.model.dart';

class ProfilePhoneVerificationArgs {
  final Country country;
  final String phoneNumber;

  ProfilePhoneVerificationArgs({
    required this.country,
    required this.phoneNumber,
  });
}

class ProfilePhoneVerificationResultArgs {
  final Country country;
  final String phoneNumber;
  final bool verified;

  ProfilePhoneVerificationResultArgs({
    required this.country,
    required this.phoneNumber,
    required this.verified,
  });
}

class ProfilePhoneVerificationModel extends PhoneOtpVerificationModel {
  ProfilePhoneVerificationModel({
    required ProfilePhoneVerificationArgs args,
  }) : super(
          country: args.country,
          phoneNumber: args.phoneNumber,
          shouldRequestOtp: true,
        );

  @override
  Future<Result> onCreateRequestOtpRequest({
    required Country country,
    required String phoneNumber,
  }) {
    final request = ProfilePhoneOtpRequest(
      country: country,
      phoneNumber: phoneNumber,
    );
    return locator<KwotData>()
        .accountRepository
        .requestProfilePhoneOtp(request);
  }

  @override
  Future<Result> onCreateVerifyOtpRequest({
    required Country country,
    required String phoneNumber,
    required String otp,
  }) {
    final request = ProfilePhoneVerificationRequest(
      country: country,
      phoneNumber: phoneNumber,
      otp: otp,
    );
    return locator<KwotData>().accountRepository.verifyProfilePhoneOtp(request);
  }
}
