// lib/services/auth_service.dart

import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../main.dart';
import '../models/signin_request.dart';
import '../models/user.dart';
import 'dio_client.dart';

/// Service for Authentication API calls
class UserService {
  final DioClient _dioClient;

  UserService(this._dioClient);

  Future<User> fetchCurrentUser(SignInRequest request) async {
    try {
      logger.d('[BEGIN] AuthService.login');
      final response = await _dioClient.get(
        '${ApiConstants.baseUrl}/api/v1/users/me',
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

      return User.fromJson(response.data);
    } on DioException catch (e) {
      final errorMessage = _handleDioError(e);
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Unknown error occurred in login: ${e.toString()}');
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
