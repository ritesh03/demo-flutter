import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/animation/countdowntimer/countdown_timer.dart';
import 'package:kwotmusic/components/widgets/animation/countdowntimer/countdown_timer_config.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/feed/feed_routing.dart';
import 'package:kwotmusic/components/widgets/gradient/foreground_gradient_photo.widget.dart';
import 'package:kwotmusic/components/widgets/page/page_state.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/show/countdown/live_show_countdown.model.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:provider/provider.dart';

import '../../../router/routes.dart';
import '../../livestreaming/live_streaming_view.dart';

class LiveShowCountdownPage extends StatefulWidget {
  const LiveShowCountdownPage({Key? key}) : super(key: key);

  @override
  State<LiveShowCountdownPage> createState() => _LiveShowCountdownPageState();
}

class _LiveShowCountdownPageState extends PageState<LiveShowCountdownPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            backgroundColor: DynamicTheme.get(context).black(),
            body: SizedBox.expand(
              child: Stack(
                children: [
                  ForegroundGradientPhoto(
                      photoPath: Assets.backgroundLiveShow,
                      height: 0.55.sh,
                      startColor: DynamicTheme.get(context).black(),
                      startColorShift: 0.1,
                      photoAlignment: Alignment.topCenter,
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter),
                  Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: _buildForeground(context)),
                  _buildAppBar(),
                ],
              ),
            )));
  }

  Widget _buildAppBar() {
    return Row(children: [
      AppIconButton(
          width: ComponentSize.large.r,
          height: ComponentSize.normal.r,
          assetColor: DynamicTheme.get(context).white(),
          assetPath: Assets.iconArrowLeft,
          padding: EdgeInsets.all(ComponentInset.small.r),
          onPressed: () => DashboardNavigation.pop(context)),
    ]);
  }

  Widget _buildForeground(BuildContext context) {
    return Container(
        height: 0.55.sh,
        padding: EdgeInsets.all(ComponentInset.normal.r),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          /// INDICATOR
          SvgPicture.asset(Assets.iconLive,
              width: 32.r,
              height: 32.r,
              color: DynamicTheme.get(context).white()),
          SizedBox(height: ComponentInset.small.h),

          /// TITLE
          _buildTitle(),
          SizedBox(height: ComponentInset.medium.h),

          /// Countdown Timer
          Align(alignment: Alignment.center, child: _buildCountdownTimer()),
          SizedBox(height: ComponentInset.large.h),

          /// Watch Show Button
          Align(alignment: Alignment.center, child: _buildWatchButton())
        ]));
  }

  Widget _buildTitle() {
    return Selector<LiveShowCountdownModel, String>(
        selector: (_, model) => model.showTitle,
        builder: (_, title, __) {
          return Text(title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.boldHeading3);
        });
  }

  Widget _buildCountdownTimer() {
    final localization = LocaleResources.of(context);
    DateTime utcTime = DateTime.parse(countdownModel.show.date!.toString());
    DateTime localTime = utcTime.toLocal();
    return CountdownTimer(
        duration: localTime.difference(DateTime.now()),
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
            onDone: () => countdownModel.update()));
  }

  Widget _buildWatchButton() {
    return Selector<LiveShowCountdownModel, bool>(
        selector: (_, model) => model.canWatchShow,
        builder: (_, canWatch, __) {
          return Button(
              text: LocaleResources.of(context).watchLiveShow,
              type: ButtonType.primary,
              enabled: canWatch,
              height: ComponentSize.large.h,
              padding: EdgeInsets.symmetric(horizontal: ComponentInset.large.w),
              onPressed: () {
                DashboardNavigation.pushNamed(context, Routes.liveStreaming,
                    arguments: LiveStreamingView(
                      showTitle: countdownModel.show.showTitle ?? "",
                      artistImage: countdownModel.show.artistId?.thumbnail ?? "",
                      channelName: countdownModel.show.channelName ?? "",
                      serverUrl: countdownModel.show.agoraUrl ?? "", rtcToken: countdownModel.show.rtcUrl??"",
                    ));
              });
        });
  }

  LiveShowCountdownModel get countdownModel =>
      context.read<LiveShowCountdownModel>();
}
