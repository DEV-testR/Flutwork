/// API configuration. Override at build time, e.g.:
/// `flutter run --dart-define=API_BASE_URL=https://api.example.com/api/`
class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.50.43:48080/api/',
  );
}
