import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static SharedPreferences? _prefs;

  /// ต้องเรียก init() ใน main ก่อนใช้งาน
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ---------------------------
  // EMAIL / USER PREFERENCES
  // ---------------------------

  static const String _keyRememberEmail = 'remember_email';
  static const String _keyThemeMode = 'theme_mode';

  /// Save last used email (ถ้า user เลือก "Remember Email")
  static Future<void> saveRememberEmail(String email) async {
    await _prefs?.setString(_keyRememberEmail, email);
  }

  /// Read last saved email
  static String? getRememberEmail() {
    return _prefs?.getString(_keyRememberEmail);
  }

  static Future<void> removeRememberEmail() async {
    await _prefs?.remove(_keyRememberEmail);
  }

  // ---------------------------
  // THEME MODE EXAMPLE
  // ---------------------------

  static Future<void> setThemeMode(String mode) async {
    await _prefs?.setString(_keyThemeMode, mode);
  }

  static String getThemeMode() {
    return _prefs?.getString(_keyThemeMode) ?? "light";
  }
}
