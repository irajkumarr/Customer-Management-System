import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic rawData;

  const ApiException({
    required this.message,
    this.statusCode,
    this.rawData,
  });

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;

  factory ApiException.fromDioException(DioException dioException) {
    int? code = dioException.response?.statusCode;
    dynamic data = dioException.response?.data;
    String message = 'An unexpected error occurred. Please try again.';

    if (data is Map<String, dynamic>) {
      if (data['message'] != null && data['message'].toString().trim().isNotEmpty) {
        message = data['message'].toString();
      } else if (data['error'] != null) {
        message = data['error'].toString();
      }
    } else if (data is String && data.trim().isNotEmpty) {
      message = data;
    } else {
      switch (dioException.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          message = 'Network connection timed out. Please check your internet connection.';
          break;
        case DioExceptionType.badResponse:
          if (code == 401) {
            message = 'Your session has expired or you are unauthorized. Please log in.';
          } else if (code == 403) {
            message = 'Access forbidden. You do not have permission for this action.';
          } else if (code == 404) {
            message = 'Requested resource not found.';
          } else if (code != null && code >= 500) {
            message = 'Internal server error occurred. Please try again later.';
          }
          break;
        case DioExceptionType.connectionError:
          message = 'Unable to connect to server. Please ensure the backend is running.';
          break;
        case DioExceptionType.cancel:
          message = 'Request was cancelled.';
          break;
        default:
          message = dioException.message ?? 'An unexpected network error occurred.';
      }
    }

    return ApiException(
      message: message,
      statusCode: code,
      rawData: data,
    );
  }

  @override
  String toString() => 'ApiException(statusCode: $statusCode, message: $message)';
}
