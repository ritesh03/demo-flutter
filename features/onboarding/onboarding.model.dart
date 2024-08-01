import 'package:flutter/material.dart'  hide SearchBar;

class OnboardingModel with ChangeNotifier {
  int currentPageIndex = 0;

  void updatePageIndex(int index) {
    currentPageIndex = index;
    notifyListeners();
  }
}
