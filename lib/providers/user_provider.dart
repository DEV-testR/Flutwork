import 'package:flutter/material.dart';

import '../utils/logger.dart';
import '../models/user.dart';
import '../services/user_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService;
  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;

  UserProvider(this._userService);

  /// Clears cached profile (e.g. on logout).
  void clearUser() {
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Loads the current user from the API and stores the result in this provider.
  Future<void> loadCurrentUser() async {
    logger.d('[BEGIN] UserProvider.loadCurrentUser');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _userService.fetchCurrentUser();
    } catch (e) {
      _currentUser = null;
      _errorMessage = _mapUserLoadError(e);
      logger.e('User profile load error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  static String _mapUserLoadError(Object e) {
    final message = e.toString();
    if (message.contains('Failed to connect') ||
        message.contains('timeout') ||
        message.contains('Cannot connect')) {
      return 'Could not reach the server. Check your connection.';
    }
    if (message.contains('Unauthorized')) {
      return 'Session expired. Please sign in again.';
    }
    return 'Could not load your profile. Please try again.';
  }
}
