// lib/services/dio_client.dart

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';

import '../utils/logger.dart';
import '../constants/api_constants.dart';
import 'secure_storage_service.dart';

/// True for routes that must work without an access token (login, refresh, etc.).
bool _isPublicAuthPath(String path) {
  final p = path.toLowerCase();
  if (p.contains('refresh-token')) return true;
  if (p.contains('validate')) return true;
  if (p.contains('login')) return true;
  return false;
}

/// DioClient handles HTTP requests, token management, cookies, and token refresh.
///
/// Use [dio_cookie_manager] with a [CookieJar] so HttpOnly [refreshToken] cookies
/// from the server are stored and sent on later requests (e.g. refresh).
class DioClient {
  final Dio _dio;
  final SecureStorageService _secureStorage;
  final VoidCallback onAuthError;

  DioClient(
    this._dio,
    this._secureStorage, {
    required this.onAuthError,
    required CookieJar cookieJar,
  }) {
    _dio.options.baseUrl = ApiConstants.baseUrl;

    // Persist/send Set-Cookie (including HttpOnly refresh tokens).
    _dio.interceptors.add(CookieManager(cookieJar));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final skipBearer = options.extra['skipBearer'] == true;
        if (skipBearer) {
          handler.next(options);
          return;
        }

        final token = await _secureStorage.getAccessToken();
        final public = _isPublicAuthPath(options.path);

        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
          logger.d('Dio: Adding Authorization header.');
        } else if (!public) {
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
      onError: (DioException e, handler) async {
        // Do not treat 401 on public routes (e.g. wrong password on /login) as session expiry.
        if (e.response?.statusCode == 401 &&
            !e.requestOptions.path.contains('refresh-token') &&
            !_isPublicAuthPath(e.requestOptions.path)) {
          logger.w('Dio: 401 Unauthorized, attempting token refresh.');

          final refreshed = await _refreshToken();
          if (refreshed) {
            logger.i('Dio: Token refreshed, retrying request.');

            final newToken = await _secureStorage.getAccessToken();
            final response = await _dio.fetch(
              e.requestOptions.copyWith(
                headers: {
                  ...e.requestOptions.headers,
                  'Authorization': 'Bearer $newToken',
                },
              ),
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

  Future<Response> get(
    String path, {
    Options? options,
    Map<String, dynamic>? queryParameters,
  }) =>
      _dio.get(path, options: options, queryParameters: queryParameters);

  Future<Response> post(String path, {dynamic data, Options? options}) =>
      _dio.post(path, data: data, options: options);

  /// Uses the same [Dio] instance so [CookieManager] sends refresh cookies.
  Future<bool> _refreshToken() async {
    final storedRt = await _secureStorage.getRefreshToken();

    try {
      final response = await _dio.post(
        'auth/refresh-token',
        data: (storedRt != null && storedRt.isNotEmpty)
            ? {'refreshToken': storedRt}
            : null,
        options: Options(
          extra: {'skipBearer': true},
          validateStatus: (status) => status != null && status < 600,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data is! Map) {
          logger.e('DioClient: Refresh response is not a JSON object.');
          return false;
        }
        final map = Map<String, dynamic>.from(response.data as Map);
        final newAccessToken = map['accessToken'] ?? map['access_token'];
        final newRefreshToken =
            map['refreshToken'] ?? map['refresh_token'] ?? storedRt;

        if (newAccessToken is String && newAccessToken.isNotEmpty) {
          final refreshStr = newRefreshToken is String
              ? newRefreshToken
              : (storedRt ?? '');
          await _secureStorage.saveTokens(
            accessToken: newAccessToken,
            refreshToken: refreshStr,
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
