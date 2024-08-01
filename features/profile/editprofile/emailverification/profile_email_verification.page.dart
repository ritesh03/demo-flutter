import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/auth/emailverification/email_verification.state.dart';

import 'profile_email_verification.model.dart';

class ProfileEmailVerificationPage extends StatefulWidget {
  const ProfileEmailVerificationPage({Key? key}) : super(key: key);

  @override
  State<ProfileEmailVerificationPage> createState() =>
      _ProfileEmailVerificationPageState();
}

class _ProfileEmailVerificationPageState
    extends EmailVerificationPageState<ProfileEmailVerificationPage> {
  //=

  @override
  void onEmailVerificationComplete({required String email}) {
    final args = ProfileEmailVerificationResultArgs(
      email: email,
      verified: true,
    );
    DashboardNavigation.pop(context, args);
  }
}
