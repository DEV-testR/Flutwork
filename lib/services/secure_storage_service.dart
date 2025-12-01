// lib/services/secure_storage_service.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Singleton service to manage access and refresh tokens securely
class SecureStorageService {
  /// Private constructor
  SecureStorageService._internal();

  /// Single instance of secureStorageService
  static final SecureStorageService _instance = SecureStorageService._internal();

  /// Factory constructor to return the same instance
  factory SecureStorageService() => _instance;

  /// FlutterSecureStorage instance for secure token storage
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Keys used to store tokens
  static const String _accessTokenKey = 'accessToken';
  static const String _refreshTokenKey = 'refreshToken';

  // ------------------------------------------------------------------
  // Save access and refresh tokens
  // ------------------------------------------------------------------
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  // ------------------------------------------------------------------
  // Retrieve access token
  // ------------------------------------------------------------------
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  // ------------------------------------------------------------------
  // Retrieve refresh token
  // ------------------------------------------------------------------
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  // ------------------------------------------------------------------
  // Delete tokens (e.g., on logout)
  // ------------------------------------------------------------------
  Future<void> deleteTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  // ------------------------------------------------------------------
  // Optional: Clear all storage
  // ------------------------------------------------------------------
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
