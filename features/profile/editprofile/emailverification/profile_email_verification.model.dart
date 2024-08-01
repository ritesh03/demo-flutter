import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/features/auth/emailverification/email_verification.model.dart';

class ProfileEmailVerificationArgs {
  final String email;
  final String emailVerificationPendingText;

  ProfileEmailVerificationArgs({
    required this.email,
    required this.emailVerificationPendingText,
  });
}

class ProfileEmailVerificationResultArgs {
  final String email;
  final bool verified;

  ProfileEmailVerificationResultArgs({
    required this.email,
    required this.verified,
  });
}

class ProfileEmailVerificationModel extends EmailVerificationModel {
  ProfileEmailVerificationModel({
    required ProfileEmailVerificationArgs args,
  })  : emailVerificationPendingText = args.emailVerificationPendingText,
        super(
          email: args.email,
          shouldRequestOtp: true,
        );

  final String emailVerificationPendingText;

  @override
  Future<Result> onCreateRequestOtpRequest({
    required String email,
  }) {
    final request = ProfileEmailOtpRequest(email: email);
    return locator<KwotData>()
        .accountRepository
        .requestProfileEmailOtp(request);
  }

  @override
  Future<Result> onCreateVerifyOtpRequest({
    required String email,
  }) async {
    final result = await locator<KwotData>().accountRepository.fetchProfile();
    if (result.isSuccess()) {
      final profile = result.data();
      final emailVerified = profile.email == email && profile.emailVerified;
      if (emailVerified) {
        return Result.empty();
      } else {
        return Result.error(emailVerificationPendingText);
      }
    }

    return result;
  }
}
