import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../providers/menu_app_provider.dart';
import '../services/auth_service.dart';
import '../services/dio_client.dart';
import '../services/preferences_service.dart';
import '../services/secure_storage_service.dart';
import '../services/user_service.dart';
import '../utils/logger.dart';
import '../screens/auth_check_screen.dart';
import '../constants/style_constants.dart';
import 'package:google_fonts/google_fonts.dart';

/// Handles application initialization and dependency injection
class AppSetup {
  /// Initialize all services and providers, then return the configured app
  static Future<Widget> initialize() async {
    // Initialize services
    final secureStorage = SecureStorageService();
    await PreferencesService.init();

    final dioClient = DioClient(
      Dio(),
      secureStorage,
      onAuthError: () {
        loggerNoStack.w("Auth error occurred");
      },
    );

    final authService = AuthService(dioClient);
    final userService = UserService(dioClient);

    // Return app with providers
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(authService, secureStorage),
        ),
        ChangeNotifierProvider<UserProvider>(
          create: (_) => UserProvider(userService),
        ),
        ChangeNotifierProvider<MenuAppProvider>(
          create: (_) => MenuAppProvider(),
        ),
      ],
      child: const MyApp(),
    );
  }
}

/// Main application widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Work',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      )..copyWith(
        scaffoldBackgroundColor: bgColor,
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ).apply(bodyColor: Colors.white),
      ),
      home: const AuthCheckScreen(),
    );
  }
}

