import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutwork/providers/auth_provider.dart';
import 'package:flutwork/providers/user_provider.dart';
import 'package:flutwork/services/auth_service.dart';
import 'package:flutwork/services/dio_client.dart';
import 'package:flutwork/services/preferences_service.dart';
import 'package:flutwork/services/secure_storage_service.dart';
import 'package:flutwork/services/user_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'constants/style_constants.dart';
import 'controllers/menu_app_controller.dart';
import 'screens/auth_check_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

final logger = Logger(printer: PrettyPrinter());
final loggerNoStack = Logger(printer: PrettyPrinter(methodCount: 0));

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('en');

  final secureStorage = SecureStorageService();
  await PreferencesService.init();

  final dioClient = DioClient(Dio(), secureStorage,
    onAuthError: () {
      loggerNoStack.w("Auth error occurred");
    },
  );

  final authService = AuthService(dioClient);
  final userService = UserService(dioClient);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider(authService, secureStorage)),
        ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider(userService)),
        ChangeNotifierProvider<MenuAppController>(create: (_) => MenuAppController()),
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