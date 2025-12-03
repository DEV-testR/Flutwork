import 'package:flutter/material.dart';
import 'package:flutwork/screens/ai_chat_screen.dart';
import 'package:provider/provider.dart';

import '../../controllers/menu_app_controller.dart';
import '../../models/auth_response.dart';
import '../../models/user.dart';
import '../../providers/user_provider.dart';
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

  // 1. ประกาศตัวแปรสำหรับเก็บข้อมูลผู้ใช้ (null ได้)
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // 2. เรียกใช้ Provider และฟังก์ชัน Async ใน initState
    _fetchUserData();
  }

  // สร้างเมธอด async เพื่อดึงข้อมูล
  Future<void> _fetchUserData() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final fetchedUser = await userProvider.fetchCurrentUser();
      setState(() {
        _currentUser = fetchedUser;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _currentUser = null;
        _isLoading = false;
      });
      debugPrint('Error fetching user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuController = context.watch<MenuAppController>();

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentUser == null) {
      return const Scaffold(
        body: Center(child: Text("Error loading user")),
      );
    }

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
              child: _buildScreen(menuController.selectedIndex, _scaffoldKey, _currentUser!),
            ),
          ],
        ),
      ),
    );
  }
}


Widget _buildScreen(int index, GlobalKey<ScaffoldState> scaffoldKey, User currentUser) {
  switch (index) {
    case 0:
      return DashboardScreen(scaffoldKey : scaffoldKey, user: currentUser);
    case 1:
      return AIChatScreen(scaffoldKey : scaffoldKey, user: currentUser);
    case 2:
      return ProfileScreen(scaffoldKey : scaffoldKey);
    case 3:
      return SettingsScreen(scaffoldKey : scaffoldKey);
    default:
      return DashboardScreen(scaffoldKey : scaffoldKey, user: currentUser);
  }
}

