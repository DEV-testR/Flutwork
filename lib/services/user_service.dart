// lib/services/user_service.dart

import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../utils/logger.dart';
import '../models/user.dart';
import 'base_service.dart';
import 'dio_client.dart';

/// Service for User API calls
class UserService extends BaseService {
  final DioClient _dioClient;

  UserService(this._dioClient);

  Future<User> fetchCurrentUser() async {
    try {
      logger.d('[BEGIN] UserService.fetchCurrentUser');
      final response = await _dioClient.get(
        '${ApiConstants.baseUrl}/v1/users/me',
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
      final errorMessage = handleDioError(e);
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Unknown error occurred in fetchCurrentUser: ${e.toString()}');
    }
  }
}
