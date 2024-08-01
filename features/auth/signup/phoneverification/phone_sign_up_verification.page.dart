import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/models/address.dart';
import 'package:kwotmusic/components/widgets/notificationbar/notification_bar.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/auth/phoneverification/phone_otp_verification.state.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';

class PhoneSignUpVerificationPage extends StatefulWidget {
  const PhoneSignUpVerificationPage({Key? key}) : super(key: key);

  @override
  State<PhoneSignUpVerificationPage> createState() =>
      _PhoneSignUpVerificationPageState();
}

class _PhoneSignUpVerificationPageState
    extends PhoneOtpVerificationPageState<PhoneSignUpVerificationPage> {
  //=

  @override
  void onPhoneVerificationComplete({
    required Country country,
    required String phoneNumber,
  }) {
    if (!mounted) return;
    showDefaultNotificationBar(NotificationBarInfo.success(
        message: LocaleResources.of(context).signUpCompletionFeedback));

    // Select Genres
    DashboardNavigation.pushNamedAndRemoveUntil(
        context, Routes.onboardingGenreSelection, (route) => false);
  }
}
