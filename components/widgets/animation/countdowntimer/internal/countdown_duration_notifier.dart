import 'package:flutter/foundation.dart';

class CountdownDurationNotifier extends ValueNotifier<Duration> {
  CountdownDurationNotifier(Duration value) : super(value);

  update(Duration duration) {
    value = duration;
    notifyListeners();
  }
}
