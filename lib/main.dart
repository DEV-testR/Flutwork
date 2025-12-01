import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutwork/providers/auth_provider.dart';
import 'package:flutwork/services/auth_service.dart';
import 'package:flutwork/services/dio_client.dart';
import 'package:flutwork/services/preferences_service.dart';
import 'package:flutwork/services/secure_storage_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'constants/color_constants.dart';
import 'controllers/menu_app_controller.dart';
import 'screens/auth_check_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

final logger = Logger(printer: PrettyPrinter());
final loggerNoStack = Logger(printer: PrettyPrinter(methodCount: 0));

void main() async {
  // Ensure Flutter bindings are initialized before async calls
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize date formatting (localization)
  await initializeDateFormatting('en');

  // Initialize token storage service
  final secureStorage = SecureStorageService();

  await PreferencesService.init();

  // Setup Dio client for API calls with auth token handling
  final dioClient = DioClient(
    Dio(),
    secureStorage,
    onAuthError: () {
      // Logout callback
      loggerNoStack.w("Auth error occurred");
    },
  );

  // Initialize authentication service
  final authService = AuthService(dioClient);

  // Run the app with Provider for state management
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(authService, secureStorage),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove debug banner
      title: 'Flutter Work',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      )..copyWith(
        scaffoldBackgroundColor: bgColor,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
            .apply(bodyColor: Colors.white),
      ),
      // Set the initial screen to check authentication
      // home: const AuthCheckScreen(),
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => MenuAppController(),
          ),
        ],
        child: AuthCheckScreen(),
      ),
    );
  }
}
