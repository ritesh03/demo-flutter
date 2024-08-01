import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/core.dart';
import 'package:kwotdata/models/address.dart';
import 'package:kwotmusic/features/auth/phoneverification/phone_otp_verification.state.dart';

import 'profile_phone_verification.model.dart';

class ProfilePhoneVerificationPage extends StatefulWidget {
  const ProfilePhoneVerificationPage({Key? key}) : super(key: key);

  @override
  State<ProfilePhoneVerificationPage> createState() =>
      _ProfilePhoneVerificationPageState();
}

class _ProfilePhoneVerificationPageState
    extends PhoneOtpVerificationPageState<ProfilePhoneVerificationPage> {
  //=

  @override
  void onPhoneVerificationComplete({
    required Country country,
    required String phoneNumber,
  }) {
    final args = ProfilePhoneVerificationResultArgs(
        country: country, phoneNumber: phoneNumber, verified: true);
    DashboardNavigation.pop(context, args);
  }
}
