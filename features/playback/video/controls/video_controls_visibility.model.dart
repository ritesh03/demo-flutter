import 'dart:async';

import 'package:flutter/material.dart'  hide SearchBar;
import 'package:provider/provider.dart';

class VideoControlsVisibilityModel with ChangeNotifier {
  static VideoControlsVisibilityModel of(BuildContext context) {
    return context.read<VideoControlsVisibilityModel>();
  }

  final visibilityDuration = const Duration(seconds: 15);

  VideoControlsVisibilityModel() {
    startTimer();
  }

  bool _areControlsVisible = true;
  Timer? _visibilityTimer;

  bool get areControlsVisible => _areControlsVisible;

  void startTimer() {
    _visibilityTimer = Timer(visibilityDuration, () {
      _setControlsVisible(false);
    });
  }

  void cancelTimer() {
    _visibilityTimer?.cancel();
  }

  void restartTimer() {
    cancelTimer();
    startTimer();
    _setControlsVisible(true);
  }

  void onDisplayTap() {
    _areControlsVisible ? _setControlsVisible(false) : restartTimer();
  }

  void _setControlsVisible(bool visible) {
    if (_areControlsVisible != visible) {
      _areControlsVisible = visible;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    cancelTimer();
    super.dispose();
  }
}
