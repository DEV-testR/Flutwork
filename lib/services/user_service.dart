// lib/services/user_service.dart

import 'package:dio/dio.dart';

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
      final response = await _dioClient.get('v1/users/me');

      if (response.data == null || response.data is! Map<String, dynamic>) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Invalid or empty response from user profile API.',
        );
      }

      return User.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      final errorMessage = handleDioError(e);
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception(
        'Unknown error occurred in fetchCurrentUser: ${e.toString()}',
      );
    }
  }
}
