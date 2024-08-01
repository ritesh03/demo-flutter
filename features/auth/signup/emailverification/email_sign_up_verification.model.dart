import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/features/auth/emailverification/email_verification.model.dart';

class EmailSignUpVerificationArgs {
  final String email;
  final String password;

  EmailSignUpVerificationArgs({
    required this.email,
    required this.password,
  });
}

class EmailSignUpVerificationModel extends EmailVerificationModel {
  final String password;

  EmailSignUpVerificationModel({
    required EmailSignUpVerificationArgs args,
  })  : password = args.password,
        super(email: args.email);

  @override
  Future<Result> onCreateRequestOtpRequest({
    required String email,
  }) {
    final request = EmailSignUpOtpRequest(email: email);
    return locator<KwotData>().authRepository.requestEmailSignUpOtp(request);
  }

  @override
  Future<Result> onCreateVerifyOtpRequest({
    required String email,
  }) {
    final request = AuthRequest(
      email: email,
      password: password,
      type: AuthType.email,
    );
    return locator<KwotData>().authRepository.authenticate(request);
  }
}
