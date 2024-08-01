import 'dart:async';

class Debounce {
  Debounce({required this.duration});

  final Duration duration;
  Timer? _timer;

  void run(Function() action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }
}
