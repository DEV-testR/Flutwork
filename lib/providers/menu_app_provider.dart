import 'package:flutter/material.dart';

/// Provider for managing menu navigation state
class MenuAppProvider extends ChangeNotifier {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  GlobalKey<ScaffoldState> get scaffoldKey => _scaffoldKey;

  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  void selectMenu(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void controlMenu() {
    final state = _scaffoldKey.currentState;
    if (state != null && !state.isDrawerOpen) {
      state.openDrawer();
    }
  }
}

