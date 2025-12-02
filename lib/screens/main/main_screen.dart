import 'package:flutter/material.dart';
import 'package:flutwork/screens/ai_chat_screen.dart';
import 'package:provider/provider.dart';

import '../../controllers/menu_app_controller.dart';
import '../../responsive.dart';
import '../dashboard/dashboard_screen.dart';
import '../settings_screen.dart';
import '../profile_screen.dart';
import 'components/side_menu.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final menuController = context.watch<MenuAppController>();

    return Scaffold(
      key: menuController.scaffoldKey,
      drawer: const SideMenu(),
      body: SafeArea(
        child: Row(
          children: [
            if (Responsive.isDesktop(context))
              const Expanded(child: SideMenu()),
            Expanded(
              flex: 5,
              child: _buildScreen(menuController.selectedIndex),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildScreen(int index) {
  switch (index) {
    case 0:
      return DashboardScreen();
    case 1:
      return AIChatScreen();
    case 2:
      return ProfileScreen();
    case 3:
      return SettingsScreen();
    default:
      return DashboardScreen();
  }
}

