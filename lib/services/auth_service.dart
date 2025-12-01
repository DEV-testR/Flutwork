// lib/services/auth_service.dart

import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../main.dart';
import '../models/auth_response.dart';
import '../models/signin_request.dart';
import 'dio_client.dart';

/// Service for Authentication API calls
class AuthService {
  final DioClient _dioClient;

  AuthService(this._dioClient);

  /// Login using username/password
  Future<AuthResponse> login(SignInRequest request) async {
    try {
      logger.d('[BEGIN] AuthService.login');
      final response = await _dioClient.post(
        '${ApiConstants.baseUrl}/auth/login',
        data: request.toJson(),
      );

      // Validate response data
      if (response.data == null || response.data is! Map<String, dynamic>) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Invalid or empty response from login API.',
        );
      }

      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      final errorMessage = _handleDioError(e);
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
        '${ApiConstants.baseUrl}/auth/login/pin',
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

      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      final errorMessage = _handleDioError(e);
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Unknown error occurred in loginWithPin: ${e.toString()}');
    }
  }

  /// Validate email existence
  Future<bool> validateEmail(String email) async {
    try {
      logger.d('[BEGIN] AuthService.validateEmail with email: $email');

      final response = await _dioClient.get(
        '${ApiConstants.baseUrl}/auth/email/validate',
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

      return true; // 200 OK → valid email
    } on DioException catch (e) {
      final errorMessage = _handleDioError(e);
      throw Exception(errorMessage);
    } catch (e) {
      logger.e('Unknown error in validateEmail: $e');
      throw Exception('Unknown error occurred in validateEmail: ${e.toString()}');
    }
  }

  /// Private helper to handle DioException consistently
  String _handleDioError(DioException e) {
    String errorMessage = 'Failed to connect to the server.';
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final responseData = e.response!.data;

      switch (statusCode) {
        case 400:
          if (responseData != null &&
              responseData is Map<String, dynamic> &&
              responseData.containsKey('message')) {
            errorMessage = responseData['message'].toString();
          } else {
            errorMessage = 'Bad request: $statusCode';
          }
          break;
        case 401:
          errorMessage = 'Unauthorized: Invalid credentials';
          break;
        case 404:
          errorMessage = 'API endpoint not found: $statusCode';
          break;
        case 500:
          errorMessage = 'Internal server error: $statusCode';
          break;
        default:
          errorMessage = 'Server error: $statusCode';
      }
    } else {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Connection timeout. Please try again.';
          break;
        case DioExceptionType.unknown:
          errorMessage = 'Cannot connect to server. Check your internet.';
          break;
        default:
          errorMessage = 'Network error: ${e.message}';
      }
    }
    logger.e('DioException: $errorMessage');
    return errorMessage;
  }
}
