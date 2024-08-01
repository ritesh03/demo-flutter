import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/widgets/notificationbar/notification_bar.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/auth/emailverification/email_verification.state.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';

class EmailSignUpVerificationPage extends StatefulWidget {
  const EmailSignUpVerificationPage({Key? key}) : super(key: key);

  @override
  State<EmailSignUpVerificationPage> createState() =>
      _EmailSignUpVerificationPageState();
}

class _EmailSignUpVerificationPageState
    extends EmailVerificationPageState<EmailSignUpVerificationPage> {
  //=

  @override
  void onEmailVerificationComplete({required String email}) {
    if (!mounted) return;
    showDefaultNotificationBar(NotificationBarInfo.success(
        message: LocaleResources.of(context).signUpCompletionFeedback));

    // Select Genres
    DashboardNavigation.pushNamedAndRemoveUntil(
        context, Routes.onboardingGenreSelection, (route) => false);
  }
}
