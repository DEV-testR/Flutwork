// lib/screens/auth_check_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'main/main_screen.dart';
import 'sign_in_screen.dart';

/// Screen to check authentication status and navigate accordingly.
/// Calls [AuthProvider.autoLogin] on first build.
class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  bool _hasInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_hasInitialized) {
      // Run autoLogin after the first frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<AuthProvider>(context, listen: false).autoLogin();
      });
      _hasInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          // Show loading indicator while checking auth state
          if (authProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Navigate to Dashboard if authenticated
          if (authProvider.isAuthenticated) {
            return MainScreen();
            // return DashboardScreen();
          }

          // Otherwise, show SignIn screen
          return const SignInScreen();
        },
      ),
    );
  }
}
