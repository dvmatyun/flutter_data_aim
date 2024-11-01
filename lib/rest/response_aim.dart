import 'package:custom_data/custom_data.dart';
import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';

class ReponseData<T> {
  const ReponseData({
    this.data,
    this.error,
    this.rawResponse,
  });

  final T? data;
  final ErrorAim? error;
  final Object? rawResponse;
}

@JsonSerializable(includeIfNull: false)
class ResponseAim {
  const ResponseAim({
    this.data,
    this.error,
  });

  final Object? data;
  final ErrorAim? error;

  factory ResponseAim.fromJson(Map<String, dynamic> json) {
    return ResponseAim(
      data: json['data'] as Object?,
      error: json['error'] == null ? null : ErrorAim.fromJson(json['error'] as Map<String, dynamic>),
    );
  }
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'data': data,
      'error': error?.toJson(),
    };
  }
}

@JsonSerializable(includeIfNull: false)
class ErrorAim extends IExceptionAim {
  const ErrorAim({
    required this.title,
    required this.message,
    required this.code,
  });

  @override
  final String title;
  @override
  final String message;
  @override
  final String code;

  factory ErrorAim.fromJson(Map<String, dynamic> json) {
    return ErrorAim(
      title: json['title'] as String? ?? 'Unknown',
      message: json['message'] as String? ?? 'Unknown',
      code: json['code'] as String? ?? 'unknown',
    );
  }
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'message': message,
      'code': code,
    };
  }
}

typedef RequestAction<T> = Future<T> Function();
typedef ResponseMapper<T> = T Function(Map<String, dynamic> data);
typedef ResponseObjectMapper<T> = T Function(Object? data);

Future<T> parseSimpleResponseApi<T>({
  required RequestAction<Object?> requestAction,
  required ResponseMapper<T> mapper,
  bool throwOnEmptyData = false,
}) async {
  final response = await requestAction();
  final map = _getMapResponse(response);
  late final ResponseAim responseAim;
  if (map.containsKey('data') || map.containsKey('error')) {
    responseAim = ResponseAim.fromJson(map);
  } else {
    responseAim = ResponseAim(data: map);
  }
  if (responseAim.error != null) {
    throw ServerQyreApiException(title: 'Server error', message: responseAim.error?.message ?? 'Unknown error');
  }
  final data = responseAim.data;
  if (data == null && throwOnEmptyData) {
    throw ServerQyreApiException(title: 'Not found', message: 'Response contained no data');
  }

  return data is Map<String, dynamic> ? mapper(data) : mapper({});
}

Future<T> parseObjectResponseApi<T>({
  required RequestAction<Object?> requestAction,
  required ResponseObjectMapper<T> mapper,
  bool throwOnEmptyData = false,
}) async {
  final response = await requestAction();
  final map = _getMapResponse(response);
  late final ResponseAim responseAim;
  if (map.containsKey('data') || map.containsKey('error')) {
    responseAim = ResponseAim.fromJson(map);
  } else {
    responseAim = ResponseAim(data: map);
  }
  if (responseAim.error != null) {
    throw ServerQyreApiException(title: 'Server error', message: responseAim.error?.message ?? 'Unknown error');
  }
  final data = responseAim.data;
  if (data == null && throwOnEmptyData) {
    throw ServerQyreApiException(title: 'Not found', message: 'Response contained no data');
  }

  return mapper(data);
}

Map<String, dynamic> _getMapResponse(Object? response) {
  Map<String, dynamic>? data;

  if (response is Response) {
    final responseData = response.data;
    if (responseData is Map<String, dynamic>) {
      data = response.data;
    }
  } else if (response is Map<String, dynamic>) {
    data = response;
  } else if (response is Exception) {
    data = {};
    data['error'] = response.toString();
  }

  return data ?? <String, dynamic>{};
}
