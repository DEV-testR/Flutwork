// lib/services/auth_service.dart

import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../utils/logger.dart';
import '../models/auth_response.dart';
import '../models/signin_request.dart';
import 'base_service.dart';
import 'dio_client.dart';

/// Service for Authentication API calls
class AuthService extends BaseService {
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
      final errorMessage = handleDioError(e);
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
      final errorMessage = handleDioError(e);
      throw Exception(errorMessage);
    } catch (e) {
      logger.e('Unknown error in validateEmail: $e');
      throw Exception('Unknown error occurred in validateEmail: ${e.toString()}');
    }
  }
}
