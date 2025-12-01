// lib/providers/auth_provider.dart

import 'package:flutter/material.dart';
import '../main.dart';
import '../models/auth_response.dart';
import '../models/signin_request.dart';
import '../services/auth_service.dart';
import '../services/secure_storage_service.dart';

/// Provider for managing authentication state and tokens
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final SecureStorageService _secureStorage;

  AuthResponse? _authResponse;
  bool _isLoading = false;
  String? _errorMessage;
  String? _email;

  AuthResponse? get loggedInUser => _authResponse;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get email => _email;
  bool get isAuthenticated => _authResponse != null;

  AuthProvider(this._authService, this._secureStorage);

  /// Attempt auto-login using stored access token
  Future<void> autoLogin() async {
    logger.d('[BEGIN] AuthProvider.autoLogin');
    _isLoading = true;
    notifyListeners();

    try {
      final accessToken = await _secureStorage.getAccessToken();
      final refreshToken = await _secureStorage.getRefreshToken();

      if (accessToken != null && accessToken.isNotEmpty) {
        _authResponse = AuthResponse(
          accessToken: accessToken,
          refreshToken: refreshToken ?? '',
        );
        logger.d('Auto-login successful');
      } else {
        _authResponse = null;
        logger.d('Auto-login failed: token not found');
      }
    } catch (e) {
      _authResponse = null;
      _errorMessage = 'Auto-login failed. Please log in again.';
      logger.e('Auto-login exception: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Login using email and password
  Future<bool> login(String email, String password) async {
    logger.d('[BEGIN] AuthProvider.login');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = SignInRequest(email: email, password: password);
      final response = await _authService.login(request);
      _authResponse = response;

      await _secureStorage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );

      return true;
    } catch (e) {
      _authResponse = null;
      _errorMessage = 'Login failed: ${e.toString()}';
      logger.e('Login error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Login using PIN
  Future<bool> loginWithPin(String email, String pin) async {
    logger.d('[BEGIN] AuthProvider.loginWithPin');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.loginWithPin(email, pin);
      _authResponse = response;

      await _secureStorage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );

      logger.d('loginWithPin successful, isAuthenticated: $isAuthenticated');
      return true;
    } catch (e) {
      _authResponse = null;
      _errorMessage = 'Login failed: ${e.toString()}';
      logger.e('loginWithPin failed, isAuthenticated: $isAuthenticated');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Validate email using API
  Future<bool> validateEmail(String email) async {
    logger.d('[BEGIN] AuthProvider.validateEmail');
    try {
      return await _authService.validateEmail(email);
    } catch (e) {
      logger.e('validateEmail error: $e');
      return false;
    }
  }

  /// Logout user and clear stored tokens
  Future<void> logout() async {
    logger.d('[BEGIN] AuthProvider.logout');
    _isLoading = true;
    notifyListeners();

    try {
      _authResponse = null;
      await _secureStorage.deleteTokens();
      logger.d('User logged out, tokens cleared');
    } catch (e) {
      _errorMessage = 'Failed to log out.';
      logger.e('Logout error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
