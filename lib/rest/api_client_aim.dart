import 'package:awesome_dio_interceptor/awesome_dio_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

abstract class IApiClientAim {
  /// Get response with headers
  Future<Object?> get(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    String apiVersion = 'v1',
    Map<String, dynamic>? headers,
    bool useUnauthenticated = false,
  });

  /// Data may be a [Map], [List], bytes [List<int>] or a [FormData].
  Future<Object?> post(
    String path,
    Object? data, {
    String apiVersion = 'v1',
    Map<String, dynamic>? headers,
    bool useUnauthenticated = false,
  });

  Future<Object?> delete(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    String apiVersion = 'v1',
    Map<String, dynamic>? headers,
    bool useUnauthenticated = false,
  });

  Future<Object?> put(
    String path,
    Object? data, {
    String apiVersion = 'v1',
    Map<String, dynamic>? headers,
    bool useUnauthenticated = false,
  });

  Future<Object?> patch(
    String path,
    Object? data, {
    String apiVersion = 'v1',
    Map<String, dynamic>? headers,
    bool useUnauthenticated = false,
  });
}

class ApiClientAim implements IApiClientAim {
  const ApiClientAim(this._dio);

  factory ApiClientAim.construct({required String baseUrl, BaseOptions? baseOptions}) {
    final apiClientNewBaseDioOptions = baseOptions ?? BaseOptions(
      baseUrl: baseUrl,
      sendTimeout: kIsWeb ? null : const Duration(milliseconds: 10000),
      connectTimeout:  kIsWeb ? null :const Duration(milliseconds: 10000),
      receiveTimeout:  kIsWeb ? null :const Duration(milliseconds: 12000),
      listFormat: ListFormat.multiCompatible,
      headers: {
        'accept': 'application/json, text/plain, */*, application/vnd.qyre-v1+json',
      },
    );

    final dio = Dio(apiClientNewBaseDioOptions);
    dio.interceptors.add(
      AwesomeDioInterceptor(),
    );
    return ApiClientAim(dio);
  }

  final Dio _dio;

  @override
  Future<Object?> get(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    String apiVersion = 'v1',
    Map<String, dynamic>? headers,
    bool useUnauthenticated = false,
  }) =>
      _dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
        ),
      );

  @override
  Future<Object?> delete(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    String apiVersion = 'v1',
    Map<String, dynamic>? headers,
    bool useUnauthenticated = false,
  }) {
    return _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: Options(
        headers: headers,
      ),
    );
  }

  @override
  Future<Object?> patch(
    String path,
    Object? data, {
    String apiVersion = 'v1',
    Map<String, dynamic>? headers,
    bool useUnauthenticated = false,
  }) {
    return _dio.patch(
      path,
      data: data,
      options: Options(
        headers: headers,
      ),
    );
  }

  @override
  Future<Object?> post(
    String path,
    Object? data, {
    String apiVersion = 'v1',
    Map<String, dynamic>? headers,
    bool useUnauthenticated = false,
  }) {
    return _dio.post(
      path,
      data: data,
      options: Options(
        headers: headers,
      ),
    );
  }

  @override
  Future<Object?> put(
    String path,
    Object? data, {
    String apiVersion = 'v1',
    Map<String, dynamic>? headers,
    bool useUnauthenticated = false,
  }) {
    return _dio.put(
      path,
      data: data,
      options: Options(
        headers: headers,
      ),
    );
  }
}
