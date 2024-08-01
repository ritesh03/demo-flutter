import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/animation/countdowntimer/countdown_timer.dart';
import 'package:kwotmusic/components/widgets/animation/countdowntimer/countdown_timer_config.dart';
import 'package:kwotmusic/features/appconfig/app_config.model.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:provider/provider.dart';

class AppMaintenanceFragment extends StatelessWidget {
  const AppMaintenanceFragment({
    Key? key,
    required this.maintenanceInfo,
  }) : super(key: key);

  final AppMaintenanceInfo maintenanceInfo;

  @override
  Widget build(BuildContext context) {
    final remainingDuration =
        maintenanceInfo.endDateTime.difference(DateTime.now());

    final localization = LocaleResources.of(context);
    return Column(children: [
      /// TITLE
      _PageTitle(title: localization.appMaintenancePageTitle),
      SizedBox(height: ComponentInset.small.r),

      /// SUBTITLE
      Expanded(child: _UpdateSummary(message: maintenanceInfo.message)),
      SizedBox(height: ComponentInset.medium.h),

      /// TIMER
      if (!remainingDuration.isNegative && remainingDuration.inSeconds > 10)
        _CountDownTimer(
            duration: remainingDuration,
            onDone: () => context.read<AppConfigModel>().fetchAppConfig()),
      SizedBox(height: ComponentInset.large.h),
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

class _CountDownTimer extends StatelessWidget {
  const _CountDownTimer({
    Key? key,
    required this.duration,
    required this.onDone,
  }) : super(key: key);

  final Duration duration;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final localization = LocaleResources.of(context);
    return CountdownTimer(
        duration: duration,
        config: CountdownTimerConfig(
            height: 48.r,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(ComponentRadius.normal.r),
                color: DynamicTheme.get(context).background()),
            digitWidth: 20.r,
            digitHeight: 48.r,
            separatorHeight: 48.r,
            separatorPadding:
                EdgeInsets.symmetric(horizontal: ComponentInset.small.r),
            separatorTextStyle: TextStyles.boldHeading2
                .copyWith(color: DynamicTheme.get(context).white()),
            shouldShowDaysCallback: (duration) => duration.inDays > 0,
            shouldShowSecondsCallback: (duration) => duration.inDays == 0,
            spacing: 8.r,
            timerTextStyle: TextStyles.boldHeading2
                .copyWith(color: DynamicTheme.get(context).white()),
            daysTitleText: localization.days,
            hoursTitleText: localization.hours,
            minutesTitleText: localization.minutes,
            secondsTitleText: localization.seconds,
            titlePadding: EdgeInsets.only(top: ComponentInset.small.r),
            titleTextStyle: TextStyles.boldHeading6
                .copyWith(color: DynamicTheme.get(context).neutral10()),
            onDone: onDone));
  }
}
