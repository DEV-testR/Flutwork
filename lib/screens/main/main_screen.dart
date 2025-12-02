import 'package:flutter/material.dart';
import 'package:flutwork/screens/ai_chat_screen.dart';
import 'package:provider/provider.dart';

import '../../controllers/menu_app_controller.dart';
import '../../responsive.dart';
import '../dashboard/dashboard_screen.dart';
import '../settings_screen.dart';
import '../profile_screen.dart';
import 'components/side_menu.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final menuController = context.watch<MenuAppController>();

    return Scaffold(
      key: _scaffoldKey, // ใช้ key ของตัวเอง
      drawer: !Responsive.isDesktop(context) ? SideMenu() : null, // Drawer เฉพาะมือถือ
      body: SafeArea(
        child: Row(
          children: [
            if (Responsive.isDesktop(context))
              const Expanded(child: SideMenu()),
            Expanded(
              flex: 5,
              child: _buildScreen(menuController.selectedIndex, _scaffoldKey),
            ),
          ],
        ),
      ),
    );
  }
}


Widget _buildScreen(int index, GlobalKey<ScaffoldState> scaffoldKey) {
  switch (index) {
    case 0:
      return DashboardScreen(scaffoldKey : scaffoldKey);
    case 1:
      return AIChatScreen(scaffoldKey : scaffoldKey);
    case 2:
      return ProfileScreen(scaffoldKey : scaffoldKey);
    case 3:
      return SettingsScreen(scaffoldKey : scaffoldKey);
    default:
      return DashboardScreen(scaffoldKey : scaffoldKey);
  }
}

