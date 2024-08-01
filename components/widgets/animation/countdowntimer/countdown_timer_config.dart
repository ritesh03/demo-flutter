import 'package:flutter/material.dart'  hide SearchBar;

import 'internal/countdown_slide_direction.dart';

/// NOTE: OUTDATED DECORATION
class CountdownTimerConfig {
  CountdownTimerConfig({
    this.animationDuration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOut,
    this.decoration,
    this.digitWidth = 20,
    this.digitHeight = 32,
    this.direction = CountdownSlideDirection.down,
    this.height = 32,
    this.onDone,
    this.separator = ":",
    this.separatorHeight,
    this.separatorPadding = EdgeInsets.zero,
    this.separatorTextStyle = const TextStyle(),
    this.shouldShowDaysCallback,
    this.shouldShowHoursCallback,
    this.shouldShowMinutesCallback,
    this.shouldShowSecondsCallback,
    this.spacing = 8,
    required this.timerTextStyle,
    this.titlePadding = EdgeInsets.zero,
    this.daysTitleText,
    this.hoursTitleText,
    this.minutesTitleText,
    this.secondsTitleText,
    this.titleTextStyle = const TextStyle(),
  });

  /// SlideAnimationDuration which will be the duration
  /// of the slide animation from above or below
  final Duration animationDuration;

  /// to customize curve in [TextAnimation] you can change the default value
  /// default [Curves.easeOut]
  final Curve curve;

  /// The decoration to paint in front of the [child].
  final Decoration? decoration;

  /// width of digit
  final double digitWidth;

  /// height of digit
  final double digitHeight;

  /// you can change the slide animation up or down by
  /// changing the enum value in this property
  final CountdownSlideDirection direction;

  /// height of widget
  final double height;

  /// function [onDone] will be called when countdown is complete
  final VoidCallback? onDone;

  /// Separator is a parameter that will separate each [duration],
  /// e.g hours by minutes, and you can change the [SeparatorType] of the symbol or title
  final String separator;

  /// The height of [separator].
  final double? separatorHeight;

  /// The amount of space by which to inset the [separator].
  final EdgeInsets separatorPadding;

  /// [TextStyle] is a parameter for all existing text,
  /// if this is null [CountdownTimer] has a default
  /// text style which will be of all text
  final TextStyle separatorTextStyle;

  /// Should we show Days in timer?
  final bool Function(Duration duration)? shouldShowDaysCallback;

  /// Should we show Hours in timer?
  final bool Function(Duration duration)? shouldShowHoursCallback;

  /// Should we show Minutes in timer?
  final bool Function(Duration duration)? shouldShowMinutesCallback;

  /// Should we show Seconds in timer?
  final bool Function(Duration duration)? shouldShowSecondsCallback;

  /// Spacing around and between digits
  final double spacing;

  /// [TextStyle] is a parameter for all existing text,
  /// if this is null [CountdownTimer] has a default
  /// text style which will be of all text
  final TextStyle timerTextStyle;

  /// title text for days is displayed under timer digit group,
  /// if this is null, days title will not be displayed
  final String? daysTitleText;

  /// title text for hours is displayed under timer digit group,
  /// if this is null, hours title will not be displayed
  final String? hoursTitleText;

  /// title text for minutes is displayed under timer digit group,
  /// if this is null, minutes title will not be displayed
  final String? minutesTitleText;

  /// title text for seconds is displayed under timer digit group,
  /// if this is null, seconds title will not be displayed
  final String? secondsTitleText;

  /// padding for title text, default is [EdgeInsets.zero]
  final EdgeInsets titlePadding;

  /// text-style for title text, default is empty instance of [TextStyle]
  final TextStyle titleTextStyle;

  CountdownTimerConfig copyWith({
    Duration? animationDuration,
    Curve? curve,
    Decoration? decoration,
    double? digitWidth,
    double? digitHeight,
    CountdownSlideDirection? direction,
    double? height,
    VoidCallback? onDone,
    String? separator,
    double? separatorHeight,
    EdgeInsets? separatorPadding,
    TextStyle? separatorTextStyle,
    bool Function(Duration duration)? shouldShowDaysCallback,
    bool Function(Duration duration)? shouldShowHoursCallback,
    bool Function(Duration duration)? shouldShowMinutesCallback,
    bool Function(Duration duration)? shouldShowSecondsCallback,
    double? spacing,
    TextStyle? timerTextStyle,
    String? daysTitleText,
    String? hoursTitleText,
    String? minutesTitleText,
    String? secondsTitleText,
    EdgeInsets? titlePadding,
    TextStyle? titleTextStyle,
  }) {
    return CountdownTimerConfig(
      animationDuration: animationDuration ?? this.animationDuration,
      curve: curve ?? this.curve,
      decoration: decoration ?? this.decoration,
      digitWidth: digitWidth ?? this.digitWidth,
      digitHeight: digitHeight ?? this.digitHeight,
      direction: direction ?? this.direction,
      height: height ?? this.height,
      onDone: onDone ?? this.onDone,
      separator: separator ?? this.separator,
      separatorHeight: separatorHeight ?? this.separatorHeight,
      separatorPadding: separatorPadding ?? this.separatorPadding,
      separatorTextStyle: separatorTextStyle ?? this.separatorTextStyle,
      shouldShowDaysCallback:
          shouldShowDaysCallback ?? this.shouldShowDaysCallback,
      shouldShowHoursCallback:
          shouldShowHoursCallback ?? this.shouldShowHoursCallback,
      shouldShowMinutesCallback:
          shouldShowMinutesCallback ?? this.shouldShowMinutesCallback,
      shouldShowSecondsCallback:
          shouldShowSecondsCallback ?? this.shouldShowSecondsCallback,
      spacing: spacing ?? this.spacing,
      timerTextStyle: timerTextStyle ?? this.timerTextStyle,
      daysTitleText: daysTitleText ?? this.daysTitleText,
      hoursTitleText: hoursTitleText ?? this.hoursTitleText,
      minutesTitleText: minutesTitleText ?? this.minutesTitleText,
      secondsTitleText: secondsTitleText ?? this.secondsTitleText,
      titlePadding: titlePadding ?? this.titlePadding,
      titleTextStyle: titleTextStyle ?? this.titleTextStyle,
    );
  }
}
