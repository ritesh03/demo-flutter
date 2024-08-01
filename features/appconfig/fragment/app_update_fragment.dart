import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/features/appconfig/app_config.model.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:provider/provider.dart';
import 'package:store_redirect/store_redirect.dart';

class AppUpdateFragment extends StatelessWidget {
  const AppUpdateFragment({
    Key? key,
    required this.updateInfo,
  }) : super(key: key);

  final AppUpdateInfo updateInfo;

  @override
  Widget build(BuildContext context) {
    final localization = LocaleResources.of(context);
    return Column(children: [
      /// TITLE
      _PageTitle(title: localization.appUpdatePageTitle),
      SizedBox(height: ComponentInset.small.r),

      /// SUBTITLE
      Expanded(child: _UpdateSummary(message: updateInfo.message)),
      SizedBox(height: ComponentInset.medium.h),

      /// Update Button
      _UpdateButton(
          title: localization.appUpdateActionUpdate,
          onTap: () => StoreRedirect.redirect()),
      SizedBox(height: ComponentInset.small.r),

      /// Skip Button
      if (!updateInfo.required)
        _SkipButton(
            title: localization.appUpdateActionSkip,
            onTap: () => context.read<AppConfigModel>().skipUpdate()),
      SizedBox(height: ComponentInset.large.r),
    ]);
  }
}

class _PageTitle extends StatelessWidget {
  const _PageTitle({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.boldHeading2);
  }
}

class _UpdateSummary extends StatelessWidget {
  const _UpdateSummary({
    Key? key,
    required this.message,
  }) : super(key: key);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      textAlign: TextAlign.center,
      style: TextStyles.body.copyWith(
        color: DynamicTheme.get(context).white(),
      ),
    );
  }
}

class _UpdateButton extends StatelessWidget {
  const _UpdateButton({
    Key? key,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Button(
        width: double.infinity,
        height: ComponentSize.large.r,
        text: title,
        type: ButtonType.primary,
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.larger.w),
        onPressed: onTap);
  }
}

class _SkipButton extends StatelessWidget {
  const _SkipButton({
    Key? key,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Button(
        width: double.infinity,
        height: ComponentSize.normal.r,
        text: title,
        type: ButtonType.text,
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.large.w),
        onPressed: onTap);
  }
}
