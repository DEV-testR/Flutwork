import 'package:flutter/material.dart';
import 'package:flutwork/screens/ai_chat_screen.dart';
import 'package:flutwork/screens/document/quotation.dart';
import 'package:provider/provider.dart';

import '../../constants/style_constants.dart';
import '../../models/user.dart';
import '../../providers/menu_app_provider.dart';
import '../../providers/user_provider.dart';
import '../../responsive.dart';
import '../dashboard/dashboard_screen.dart';
import '../profile_screen.dart';
import '../settings_screen.dart';
import 'components/side_menu.dart';

/// Shell state derived from [UserProvider] for selective rebuilds.
typedef _UserShellState = ({
  bool loading,
  User? user,
  String? error,
});

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<UserProvider>().loadCurrentUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Selector<UserProvider, _UserShellState>(
      selector: (_, p) => (
        loading: p.isLoading,
        user: p.currentUser,
        error: p.errorMessage,
      ),
      builder: (context, state, _) {
        if (state.loading && state.user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.user == null) {
          final message = (state.error != null && state.error!.isNotEmpty)
              ? state.error!
              : 'Error loading user';
          return Scaffold(
            body: Center(child: Text(message)),
          );
        }

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: bgColor,
          drawer: !Responsive.isDesktop(context)
              ? const SideMenu()
              : null,
          body: SafeArea(
            child: Row(
              children: [
                if (Responsive.isDesktop(context))
                  const Expanded(child: SideMenu()),
                Expanded(
                  flex: 5,
                  child: _MainContentRouter(
                    scaffoldKey: _scaffoldKey,
                    user: state.user!,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Listens only to [MenuAppProvider.selectedIndex] so the scaffold shell
/// does not rebuild when the menu selection changes.
class _MainContentRouter extends StatelessWidget {
  const _MainContentRouter({
    required this.scaffoldKey,
    required this.user,
  });

  final GlobalKey<ScaffoldState> scaffoldKey;
  final User user;

  @override
  Widget build(BuildContext context) {
    return Selector<MenuAppProvider, int>(
      selector: (_, p) => p.selectedIndex,
      builder: (context, selectedIndex, _) {
        return _buildScreen(selectedIndex, scaffoldKey, user);
      },
    );
  }
}

Widget _buildScreen(
  int index,
  GlobalKey<ScaffoldState> scaffoldKey,
  User currentUser,
) {
  switch (index) {
    case 0:
      return DashboardScreen(scaffoldKey: scaffoldKey, user: currentUser);
    case 1:
      return AIChatScreen(
        scaffoldKey: scaffoldKey,
        user: currentUser,
      );
    case 2:
      return QuotationScreen(scaffoldKey: scaffoldKey);
    case 9:
      return ProfileScreen(scaffoldKey: scaffoldKey);
    case 10:
      return SettingsScreen(scaffoldKey: scaffoldKey);
    default:
      return DashboardScreen(scaffoldKey: scaffoldKey, user: currentUser);
  }
}
