import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

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

/// Builds the app light theme: Poppins [textTheme], [ColorScheme] from [primaryColor],
/// and component themes so screens use [Theme.of] instead of hardcoded colors.
ThemeData buildAppTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: primaryColor,
    brightness: Brightness.light,
  ).copyWith(
    primary: primaryColor,
    onPrimary: secondaryColor,
    surface: bgColor,
    onSurface: defaultTextColor,
  );

  final textTheme = GoogleFonts.poppinsTextTheme(
    ThemeData(brightness: Brightness.light).textTheme,
  ).apply(
    bodyColor: defaultTextColor,
    displayColor: defaultTextColor,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: bgColor,
    textTheme: textTheme,
    // M3 ElevatedButton can resolve to a very light fill while labels use
    // onPrimary — force brand primary so white text stays readable.
    // Use a finite minimum width so [ElevatedButton] works inside [Row] / unbounded width.
    // Full-width actions should wrap the button in [SizedBox(width: double.infinity, ...)].
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: secondaryColor,
        disabledBackgroundColor: primaryColor.withValues(alpha: 0.45),
        disabledForegroundColor: secondaryColor.withValues(alpha: 0.75),
        minimumSize: const Size(48, 54),
        tapTargetSize: MaterialTapTargetSize.padded,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: textTheme.titleSmall,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest,
      hintStyle: textTheme.bodyLarge?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: colorScheme.error, width: 1.5),
      ),
      errorStyle: textTheme.bodySmall?.copyWith(color: colorScheme.error),
    ),
  );
}

/// Handles application initialization and dependency injection
class AppSetup {
  /// Initialize all services and providers, then return the configured app
  static Future<Widget> initialize() async {
    final secureStorage = SecureStorageService();
    await PreferencesService.init();

    // Persist cookies so HttpOnly refresh tokens survive app restarts.
    final appDir = await getApplicationDocumentsDirectory();
    final cookieJar = PersistCookieJar(
      storage: FileStorage('${appDir.path}/.cookies'),
    );
    final dio = Dio();

    final dioClient = DioClient(
      dio,
      secureStorage,
      cookieJar: cookieJar,
      onAuthError: () {
        loggerNoStack.w('Auth error occurred');
      },
    );

    final authService = AuthService(dioClient);
    final userService = UserService(dioClient);

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
      theme: buildAppTheme(),
      home: const AuthCheckScreen(),
    );
  }
}
