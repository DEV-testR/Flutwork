import 'package:dio/dio.dart';
import '../utils/logger.dart';

/// Base service class that provides common error handling functionality
abstract class BaseService {
  /// Handle DioException consistently across all services
  String handleDioError(DioException e) {
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

