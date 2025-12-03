import 'package:flutter/material.dart';

import '../main.dart';
import '../models/user.dart';
import '../services/user_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserProvider(this._userService);

  Future<User?> fetchCurrentUser() async {
    logger.d('[BEGIN] UserProvider.fetchCurrentUser');
    _isLoading = true;
    notifyListeners();

    try {
      return await _userService.fetchCurrentUser();
    } catch (e) {
      _errorMessage = 'Login failed: ${e.toString()}';
      logger.e('Login error: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

}
