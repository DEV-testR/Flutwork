import 'package:flutter/material.dart';

class MenuAppController extends ChangeNotifier {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  GlobalKey<ScaffoldState> get scaffoldKey => _scaffoldKey;


  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  void selectMenu(int index) {
    _selectedIndex = index;
    notifyListeners();          // แจ้งให้ UI rebuild
  }

  void controlMenu() {
    final state = _scaffoldKey.currentState;
    if (state != null && !state.isDrawerOpen) {
      state.openDrawer();
    }
  }
}