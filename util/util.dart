import 'package:flutter/material.dart'  hide SearchBar;
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

Route? obtainRoute(BuildContext context) {
  return ModalRoute.of(context);
}

T obtainRouteArgs<T>(BuildContext context) {
  return obtainRoute(context)!.settings.arguments as T;
}

void hideKeyboard(BuildContext context) {
  final hasFocus = FocusScope.of(context).hasFocus;
  if (hasFocus) {
    FocusScope.of(context).unfocus();
  }
}

extension DoubleExtension on double {
  double get roundToEven {
    int rounded = round();
    return (rounded.isOdd ? rounded++ : rounded).toDouble();
  }
}

extension PrettyCountExtension on int {
  String get prettyCount {
    return NumberFormat.compact().format(this);
  }
}

extension DateTimeExtension on DateTime {
  String toDefaultDateFormat() {
    return DateFormat("dd MMM, yyyy").format(this);
  }

  String toDefaultTimeFormat() {
    return DateFormat("hh:mm a").format(this);
  }

  String toHourMinuteFormat() {
    return DateFormat("HH:mm").format(this);
  }

  String toTimeAgoString() {
    return timeago.format(this);
  }

  String toCompactTimeAgoString() {
    return timeago.format(this, locale: "en_short");
  }
}

extension DurationExtension on Duration {
  String? toHoursMinutesSeconds() {
    final hours = inHours;

    String twoDigits(int n) => n.toString().padLeft(2, "0");

    String twoDigitMinutes = twoDigits(inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(inSeconds.remainder(60));

    if (hours == 0) {
      return "$twoDigitMinutes:$twoDigitSeconds";
    } else {
      return "${twoDigits(hours)}:$twoDigitMinutes:$twoDigitSeconds";
    }
  }

  String toCompactEpisodeDuration() {
    final hours = inHours;
    if (hours != 0) {
      return "${hours}h ${inMinutes.remainder(60)}m";
    }

    final minutes = inMinutes;
    if (minutes != 0) {
      return "${minutes}m";
    }

    final seconds = inSeconds;
    if (seconds != 0) {
      return "${seconds}s";
    }

    return "-";
  }
}

String withExtraNextLineCharacters(String text, int count) {
  String nextLineCharacters = "";
  for (int index = 0; index < (count - 1); index++) {
    nextLineCharacters += "\n";
  }
  return text + nextLineCharacters;
}

@Deprecated("Use the one from kwotcommon module")
class UriUtil {
  static bool canLaunch(String url) {
    final uri = Uri.tryParse(url);

    if (uri == null) return false;
    if (!uri.hasScheme) return false;
    if (uri.scheme.isEmpty) return false;
    if (uri.scheme != "http" && uri.scheme != "https") return false;
    if (!uri.hasAuthority) return false;
    if (uri.authority.isEmpty) return false;
    if (uri.host.isEmpty) return false;
    if (!uri.hasAbsolutePath) return false;

    return true;
  }
}

extension ScrollControllerExt on ScrollController {
  Future<void> animateToTop({
    Duration? duration,
    Curve? curve,
  }) {
    return animateTo(0,
        duration: duration ?? const Duration(seconds: 1),
        curve: curve ?? Curves.easeOut);
  }

  void jumpToTop() {
    jumpTo(0);
  }
}
