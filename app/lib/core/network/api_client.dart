import 'package:dio/dio.dart';
import 'package:recipe_planner/core/constants/api_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

/// API client wrapper using Dio with interceptors.
class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Auth interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final session = Supabase.instance.client.auth.currentSession;
          if (session != null) {
            options.headers['Authorization'] = 'Bearer ${session.accessToken}';
          }
          handler.next(options);
        },
      ),
    );

    // Retry interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          if (_shouldRetry(error) && _getRetryCount(error) < 3) {
            try {
              final retryCount = _getRetryCount(error) + 1;
              final delay = Duration(
                milliseconds: 1000 * (1 << (retryCount - 1)),
              );
              await Future<void>.delayed(delay);

              final options = error.requestOptions;
              options.extra['retryCount'] = retryCount;
              final response = await _dio.fetch(options);
              handler.resolve(response);
              return;
            } catch (e) {
              handler.next(error);
              return;
            }
          }
          handler.next(error);
        },
      ),
    );

    // Logging interceptor (debug only)
    assert(() {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          error: true,
        ),
      );
      return true;
    }());
  }

  Dio get dio => _dio;

  bool _shouldRetry(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        (error.response?.statusCode != null &&
            error.response!.statusCode! >= 500);
  }

  int _getRetryCount(DioException error) {
    return error.requestOptions.extra['retryCount'] as int? ?? 0;
  }

  // Convenience methods
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.get<T>(path, queryParameters: queryParameters);
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
  }) {
    return _dio.post<T>(path, data: data);
  }

  Future<Response<T>> put<T>(
    String path, {
    Object? data,
  }) {
    return _dio.put<T>(path, data: data);
  }

  Future<Response<T>> patch<T>(
    String path, {
    Object? data,
  }) {
    return _dio.patch<T>(path, data: data);
  }

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.delete<T>(path, data: data, queryParameters: queryParameters);
  }
}
