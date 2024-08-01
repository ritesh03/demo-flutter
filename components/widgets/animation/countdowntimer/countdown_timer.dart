import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/widgets/animation/countdowntimer/countdown_timer_config.dart';

import 'internal/countdown_digit_group.dart';
import 'internal/countdown_duration_notifier.dart';
import 'internal/countdown_stream_duration.dart';

class CountdownTimer extends StatefulWidget {
  const CountdownTimer({Key? key, required this.duration, required this.config})
      : super(key: key);

  /// [Duration] is the duration of the countdown slide,
  /// if the duration has finished it will call [CountdownTimerConfig.onDone]
  final Duration duration;

  /// Configuration settings for timer
  final CountdownTimerConfig config;

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> with CountdownMixin {
  late StreamDuration _streamDuration;
  late CountdownDurationNotifier _durationNotifier;
  bool disposed = false;

  @override
  void initState() {
    super.initState();

    _durationNotifier = CountdownDurationNotifier(widget.duration);
    _streamDurationListener();
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    return ValueListenableBuilder(
        valueListenable: _durationNotifier,
        builder: (_, Duration duration, __) {
          //=

          final days = CountdownDigitGroup(
              config: config,
              valueType: CountdownDigitValueType.days,
              firstDigitNotifier: daysFirstDigitNotifier,
              secondDigitNotifier: daysSecondDigitNotifier);

          final hours = CountdownDigitGroup(
              config: config,
              valueType: CountdownDigitValueType.hours,
              firstDigitNotifier: hoursFirstDigitNotifier,
              secondDigitNotifier: hoursSecondDigitNotifier);

          final minutes = CountdownDigitGroup(
              config: config,
              valueType: CountdownDigitValueType.minutes,
              firstDigitNotifier: minutesFirstDigitNotifier,
              secondDigitNotifier: minutesSecondDigitNotifier);

          final seconds = CountdownDigitGroup(
              config: config,
              valueType: CountdownDigitValueType.seconds,
              firstDigitNotifier: secondsFirstDigitNotifier,
              secondDigitNotifier: secondsSecondDigitNotifier);

          final separator = Container(
              alignment: Alignment.center,
              height: config.height,
              padding: config.separatorPadding,
              child: Text(config.separator, style: config.separatorTextStyle));

          final shouldShowDays =
              config.shouldShowDaysCallback?.call(duration) ?? true;
          final shouldShowHours =
              config.shouldShowHoursCallback?.call(duration) ?? true;
          final shouldShowMinutes =
              config.shouldShowMinutesCallback?.call(duration) ?? true;
          final shouldShowSeconds =
              config.shouldShowSecondsCallback?.call(duration) ?? true;

          return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (shouldShowDays) days,
                if (shouldShowDays && shouldShowHours) separator,
                if (shouldShowHours) hours,
                if (shouldShowHours && shouldShowMinutes) separator,
                if (shouldShowMinutes) minutes,
                if (shouldShowMinutes && shouldShowSeconds) separator,
                if (shouldShowSeconds) seconds,
              ]);
        });
  }

  @override
  void didUpdateWidget(covariant CountdownTimer oldWidget) {
    if (widget.duration != oldWidget.duration) {
      _streamDuration.changeDuration(widget.duration);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    disposed = true;
    _streamDuration.dispose();
    super.dispose();
  }

  void _streamDurationListener() {
    final config = widget.config;
    _streamDuration = StreamDuration(widget.duration, onDone: () {
      config.onDone?.call();
    });

    if (!disposed) {
      try {
        _streamDuration.durationLeft.listen((duration) {
          _durationNotifier.update(duration);
          updateValue(duration);
        });
      } catch (ex) {
        debugPrint(ex.toString());
      }
    }
  }
}

mixin CountdownMixin<T extends StatefulWidget> on State<T> {
  final ValueNotifier<int> daysFirstDigitNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> daysSecondDigitNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> hoursFirstDigitNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> hoursSecondDigitNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> minutesFirstDigitNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> minutesSecondDigitNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> secondsFirstDigitNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> secondsSecondDigitNotifier = ValueNotifier<int>(0);

  void daysFirstDigit(Duration duration) {
    try {
      if (duration.inDays == 0) {
        daysFirstDigitNotifier.value = 0;
        return;
      } else {
        int calculate = (duration.inDays) ~/ 10;
        if (calculate != daysFirstDigitNotifier.value) {
          daysFirstDigitNotifier.value = calculate;
        }
      }
    } catch (ex) {
      debugPrint(ex.toString());
    }
  }

  void daysSecondDigit(Duration duration) {
    try {
      if (duration.inDays == 0) {
        daysSecondDigitNotifier.value = 0;
        return;
      } else {
        int calculate = (duration.inDays) % 10;
        if (calculate != daysSecondDigitNotifier.value) {
          daysSecondDigitNotifier.value = calculate;
        }
      }
    } catch (ex) {
      debugPrint(ex.toString());
    }
  }

  void hoursFirstDigit(Duration duration) {
    try {
      if (duration.inHours == 0) {
        hoursFirstDigitNotifier.value = 0;
        return;
      } else {
        int calculate = (duration.inHours % 24) ~/ 10;
        if (calculate != hoursFirstDigitNotifier.value) {
          hoursFirstDigitNotifier.value = calculate;
        }
      }
    } catch (ex) {
      debugPrint(ex.toString());
    }
  }

  void hoursSecondDigit(Duration duration) {
    try {
      if (duration.inHours == 0) {
        hoursSecondDigitNotifier.value = 0;
        return;
      } else {
        int calculate = (duration.inHours % 24) % 10;
        if (calculate != hoursSecondDigitNotifier.value) {
          hoursSecondDigitNotifier.value = calculate;
        }
      }
    } catch (ex) {
      debugPrint(ex.toString());
    }
  }

  void minutesFirstDigit(Duration duration) {
    try {
      if (duration.inMinutes == 0) {
        minutesFirstDigitNotifier.value = 0;
        return;
      } else {
        int calculate = (duration.inMinutes % 60) ~/ 10;
        if (calculate != minutesFirstDigitNotifier.value) {
          minutesFirstDigitNotifier.value = calculate;
        }
      }
    } catch (ex) {
      debugPrint(ex.toString());
    }
  }

  void minutesSecondDigit(Duration duration) {
    try {
      if (duration.inMinutes == 0) {
        minutesSecondDigitNotifier.value = 0;
        return;
      } else {
        int calculate = (duration.inMinutes % 60) % 10;
        if (calculate != minutesSecondDigitNotifier.value) {
          minutesSecondDigitNotifier.value = calculate;
        }
      }
    } catch (ex) {
      debugPrint(ex.toString());
    }
  }

  void secondsFirstDigit(Duration duration) {
    try {
      if (duration.inSeconds == 0) {
        secondsFirstDigitNotifier.value = 0;
        return;
      } else {
        int calculate = (duration.inSeconds % 60) ~/ 10;
        if (calculate != secondsFirstDigitNotifier.value) {
          secondsFirstDigitNotifier.value = calculate;
        }
      }
    } catch (ex) {
      debugPrint(ex.toString());
    }
  }

  void secondsSecondDigit(Duration duration) {
    try {
      if (duration.inSeconds == 0) {
        secondsSecondDigitNotifier.value = 0;
        return;
      } else {
        int calculate = (duration.inSeconds % 60) % 10;
        if (calculate != secondsSecondDigitNotifier.value) {
          secondsSecondDigitNotifier.value = calculate;
        }
      }
    } catch (ex) {
      debugPrint(ex.toString());
    }
  }

  void disposeDaysNotifier() {
    daysFirstDigitNotifier.dispose();
    daysSecondDigitNotifier.dispose();
  }

  void disposeHoursNotifier() {
    hoursFirstDigitNotifier.dispose();
    hoursSecondDigitNotifier.dispose();
  }

  void disposeMinutesNotifier() {
    minutesFirstDigitNotifier.dispose();
    minutesSecondDigitNotifier.dispose();
  }

  void disposeSecondsNotifier() {
    secondsFirstDigitNotifier.dispose();
    secondsSecondDigitNotifier.dispose();
  }

  void updateValue(Duration duration) {
    daysFirstDigit(duration);
    daysSecondDigit(duration);

    hoursFirstDigit(duration);
    hoursSecondDigit(duration);

    minutesFirstDigit(duration);
    minutesSecondDigit(duration);

    secondsFirstDigit(duration);
    secondsSecondDigit(duration);
  }

  @override
  void dispose() {
    disposeDaysNotifier();
    disposeHoursNotifier();
    disposeMinutesNotifier();
    disposeSecondsNotifier();
    super.dispose();
  }
}
