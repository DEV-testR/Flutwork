import 'package:flutter/material.dart';

/// Provider for managing menu navigation state
class MenuAppProvider extends ChangeNotifier {
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  void selectMenu(int index) {
    _selectedIndex = index;
    notifyListeners();
  }
}
