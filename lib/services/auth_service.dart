// lib/services/auth_service.dart

import 'package:dio/dio.dart';

import '../utils/logger.dart';
import '../models/auth_response.dart';
import '../models/login_request.dart';
import '../models/signin_request.dart';
import 'base_service.dart';
import 'dio_client.dart';

/// Service for Authentication API calls
class AuthService extends BaseService {
  final DioClient _dioClient;

  AuthService(this._dioClient);

  /// Password login: `POST /login` (relative to API base). Refresh may arrive as HttpOnly cookie only.
  Future<AuthResponse> loginWithPassword(LoginRequest request) async {
    try {
      logger.d('[BEGIN] AuthService.loginWithPassword');
      final response = await _dioClient.post(
        'auth/login',
        data: request.toJson(),
      );

      if (response.data == null || response.data is! Map<String, dynamic>) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Invalid or empty response from login API.',
        );
      }

      return AuthResponse.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      final errorMessage = handleDioError(e);
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception(
        'Unknown error occurred in loginWithPassword: ${e.toString()}',
      );
    }
  }

  /// Login using username/password (legacy path `auth/login`).
  Future<AuthResponse> login(SignInRequest request) async {
    try {
      logger.d('[BEGIN] AuthService.login');
      final response = await _dioClient.post(
        'auth/login',
        data: request.toJson(),
      );

      if (response.data == null || response.data is! Map<String, dynamic>) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Invalid or empty response from login API.',
        );
      }

      return AuthResponse.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      final errorMessage = handleDioError(e);
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Unknown error occurred in login: ${e.toString()}');
    }
  }

  /// Login using PIN
  Future<AuthResponse> loginWithPin(String email, String pin) async {
    try {
      logger.d('[BEGIN] AuthService.loginWithPin');
      final response = await _dioClient.get(
        'auth/login/pin',
        queryParameters: {'email': email, 'pin': pin},
      );

      if (response.data == null || response.data is! Map<String, dynamic>) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Invalid or empty response from login/pin API.',
        );
      }

      return AuthResponse.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      final errorMessage = handleDioError(e);
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception(
        'Unknown error occurred in loginWithPin: ${e.toString()}',
      );
    }
  }

  /// Whether the server considers the email valid / registered.
  /// Supports JSON body `{ "exists": true }`, `{ "valid": true }`, or plain `true`.
  Future<bool> validateEmail(String email) async {
    try {
      logger.d('[BEGIN] AuthService.validateEmail with email: $email');

      final response = await _dioClient.get(
        'auth/email/validate',
        queryParameters: {'email': email},
      );

      if (response.statusCode != 200) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Invalid response from email validation API.',
        );
      }

      return _parseEmailValidationResult(response.data);
    } on DioException catch (e) {
      final errorMessage = handleDioError(e);
      throw Exception(errorMessage);
    } catch (e) {
      logger.e('Unknown error in validateEmail: $e');
      throw Exception(
        'Unknown error occurred in validateEmail: ${e.toString()}',
      );
    }
  }

  /// Interprets validation response; defaults to `true` on empty 200 for backward compatibility.
  static bool _parseEmailValidationResult(dynamic data) {
    if (data == null) return true;
    if (data is bool) return data;
    if (data is String) {
      final lower = data.toLowerCase();
      if (lower == 'true') return true;
      if (lower == 'false') return false;
    }
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      if (map.containsKey('exists')) {
        return _coerceToBool(map['exists']) ?? false;
      }
      if (map.containsKey('valid')) {
        return _coerceToBool(map['valid']) ?? false;
      }
    }
    return true;
  }

  static bool? _coerceToBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'true') return true;
      if (lower == 'false') return false;
    }
    if (value is num) return value != 0;
    return null;
  }
}
