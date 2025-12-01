import 'package:flutter/material.dart';

class MenuAppController extends ChangeNotifier {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  GlobalKey<ScaffoldState> get scaffoldKey => _scaffoldKey;

  void controlMenu() {
    // 1. เก็บ currentState ไว้ในตัวแปรชั่วคราว (state)
    final state = _scaffoldKey.currentState;

    // 2. ตรวจสอบว่า state ไม่ใช่ null ก่อนดำเนินการ
    if (state != null) {
      // 3. ใช้ state แทนการเข้าถึง _scaffoldKey.currentState ซ้ำ ๆ
      if (!state.isDrawerOpen) {
        state.openDrawer();
      }
    }
  }
}