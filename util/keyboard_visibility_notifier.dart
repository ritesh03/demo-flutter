import 'dart:async';

import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class KeyboardVisibilityNotifier {
  late final StreamSubscription<bool> _subscription;

  void init(BuildContext context) {
    _subscription = KeyboardVisibilityController().onChange.listen((isVisible) {
      if (!isVisible && FocusScope.of(context).hasFocus) {
        FocusScope.of(context).unfocus();
      }
    });
  }

  void dispose() {
    _subscription.cancel();
  }
}
