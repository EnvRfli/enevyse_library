import 'package:flutter/material.dart';

class MainLayoutLogic extends ChangeNotifier {
  int _currentIndex = 0;
  bool _shouldAutoFocusSearch = false;

  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  void triggerSearchFocus() {
    _shouldAutoFocusSearch = true;
    setIndex(1); // Explore tab
  }

  bool consumeSearchFocus() {
    if (_shouldAutoFocusSearch) {
      _shouldAutoFocusSearch = false;
      return true;
    }
    return false;
  }
}
