import 'package:flutter/material.dart'  hide SearchBar;

extension BuildContextMountExt on BuildContext {
  bool get mounted {
    try {
      widget;
      return true;
    } catch (e) {
      return false;
    }
  }
}
