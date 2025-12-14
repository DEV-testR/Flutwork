import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'constants/style_constants.dart';
import 'screens/auth_check_screen.dart';
import 'core/app_setup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('en');
  
  final appSetup = await AppSetup.initialize();
  
  runApp(appSetup);
}
