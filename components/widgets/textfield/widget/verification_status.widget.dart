import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/l10n/localizations.dart';

class VerificationStatusWidget extends StatelessWidget {
  const VerificationStatusWidget({
    Key? key,
    required this.verified,
    required this.onVerifyTap,
  }) : super(key: key);

  final bool? verified;
  final VoidCallback onVerifyTap;

  @override
  Widget build(BuildContext context) {
    final verified = this.verified;
    if (verified == null) {
      return Container();
    }

    if (!verified) {
      return Button(
          padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
          text: LocaleResources.of(context).verify,
          type: ButtonType.text,
          onPressed: onVerifyTap);
    }

    return Padding(
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
        child: Text(LocaleResources.of(context).verified,
            style: TextStyles.boldHeading5.copyWith(
              color: DynamicTheme.get(context).success(),
            )));
  }
}
