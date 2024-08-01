import 'package:flutter/material.dart'  hide SearchBar;

import '../countdown_timer_config.dart';
import 'countdown_digit.dart';

enum CountdownDigitValueType { days, hours, minutes, seconds }

class CountdownDigitGroup extends StatelessWidget {
  const CountdownDigitGroup({
    Key? key,
    required this.config,
    required this.valueType,
    required this.firstDigitNotifier,
    required this.secondDigitNotifier,
  }) : super(key: key);

  final CountdownTimerConfig config;
  final CountdownDigitValueType valueType;
  final ValueNotifier<int> firstDigitNotifier;
  final ValueNotifier<int> secondDigitNotifier;

  @override
  Widget build(BuildContext context) {
    //=
    final firstDigit = CountdownDigit(
      width: config.digitWidth,
      height: config.digitHeight,
      animationDuration: config.animationDuration,
      notifier: firstDigitNotifier,
      textStyle: config.timerTextStyle,
      direction: config.direction,
      curve: config.curve,
    );

    final secondDigit = CountdownDigit(
      width: config.digitWidth,
      height: config.digitHeight,
      animationDuration: config.animationDuration,
      notifier: secondDigitNotifier,
      textStyle: config.timerTextStyle,
      direction: config.direction,
      curve: config.curve,
    );

    final child = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: config.spacing),
          firstDigit,
          SizedBox(width: config.spacing),
          secondDigit,
          SizedBox(width: config.spacing),
        ]);

    return Column(mainAxisSize: MainAxisSize.min, children: [
      /// TIMER TEXT
      Container(
          height: config.height,
          decoration: config.decoration,
          clipBehavior: Clip.hardEdge,
          alignment: Alignment.center,
          child: Visibility(
              visible: false,
              child: SizedBox.expand(child: child),
              replacement: ClipRect(child: child))),

      /// TITLE
      _buildTitle(),
    ]);
  }

  Widget _buildTitle() {
    final String? title;
    switch (valueType) {
      case CountdownDigitValueType.days:
        title = config.daysTitleText;
        break;
      case CountdownDigitValueType.hours:
        title = config.hoursTitleText;
        break;
      case CountdownDigitValueType.minutes:
        title = config.minutesTitleText;
        break;
      case CountdownDigitValueType.seconds:
        title = config.secondsTitleText;
        break;
    }

    if (title == null) {
      return Container();
    }

    return Container(
        padding: config.titlePadding,
        child: Text(title, style: config.titleTextStyle));
  }
}
