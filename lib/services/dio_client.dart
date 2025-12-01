// lib/network/dio_client.dart

import 'package:dio/dio.dart';
import 'dart:ui';
import '../main.dart'; // logger
import '../constants/api_constants.dart';
import '../services/secure_storage_service.dart';

/// DioClient handles HTTP requests, token management, and automatic token refresh
class DioClient {
  final Dio _dio;
  final SecureStorageService _secureStorage;
  final VoidCallback onAuthError; // Callback for auth failures

  /// Constructor
  DioClient(
      this._dio,
      this._secureStorage, {
        required this.onAuthError,
      }) {
    // Set base URL
    _dio.options.baseUrl = ApiConstants.baseUrl;

    // Add interceptor for requests and responses
    _dio.interceptors.add(InterceptorsWrapper(
      // Intercept requests to attach access token
      onRequest: (options, handler) async {
        final token = await _secureStorage.getAccessToken();
        final isAuthPath = options.path.contains('auth');

        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
          logger.d('Dio: Adding Authorization header.');
        } else if (!isAuthPath) {
          logger.d('Dio: No access token, triggering onAuthError.');
          onAuthError();
          return handler.reject(DioException(
            requestOptions: options,
            response: Response(statusCode: 401, requestOptions: options),
            type: DioExceptionType.cancel,
            error: 'No access token found.',
          ));
        }

        handler.next(options);
      },

      // Intercept errors to handle 401 and refresh token
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401 &&
            !e.requestOptions.path.contains('/refresh-token')) {
          logger.w('Dio: 401 Unauthorized, attempting token refresh.');

          final refreshed = await _refreshToken();
          if (refreshed) {
            logger.i('Dio: Token refreshed, retrying request.');

            final newToken = await _secureStorage.getAccessToken();
            final options = Options(
              method: e.requestOptions.method,
              headers: {
                ...e.requestOptions.headers,
                'Authorization': 'Bearer $newToken',
              },
            );

            final response = await _dio.fetch(
              e.requestOptions.copyWith(headers: options.headers),
            );
            return handler.resolve(response);
          } else {
            logger.e('Dio: Token refresh failed, logging out.');
            await _secureStorage.deleteTokens();
            onAuthError();
            return handler.next(e);
          }
        }

        handler.next(e);
      },
    ));

    logger.i('DioClient initialized.');
  }

  /// Perform GET request
  Future<Response> get(String path,
      {Options? options, Map<String, dynamic>? queryParameters}) =>
      _dio.get(path, options: options, queryParameters: queryParameters);

  /// Perform POST request
  Future<Response> post(String path, {dynamic data, Options? options}) =>
      _dio.post(path, data: data, options: options);

  /// Refresh access token using refresh token
  Future<bool> _refreshToken() async {
    final refreshToken = await _secureStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      logger.d('DioClient: No refresh token found.');
      return false;
    }

    try {
      // Use new Dio instance to prevent interceptor loop
      final Dio refreshDio = Dio();
      final response = await refreshDio.post(
        '${ApiConstants.baseUrl}/auth/refresh-token',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final newAccessToken = response.data['accessToken'] as String?;
        final newRefreshToken =
            response.data['refreshToken'] as String? ?? refreshToken;

        if (newAccessToken != null) {
          await _secureStorage.saveTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
          );
          logger.i('DioClient: Refresh token successful.');
          return true;
        }
      }
    } catch (e) {
      logger.e('DioClient: Refresh token failed: $e');
      await _secureStorage.deleteTokens();
      onAuthError();
    }

    return false;
  }
}
