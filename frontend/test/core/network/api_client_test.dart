import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/network/api_exception.dart';

void main() {
  group('ApiException Tests', () {
    test('parses json error message from backend ApiResponse', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/api/auth/login'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/auth/login'),
          statusCode: 401,
          data: {'success': false, 'message': 'Invalid username or password'},
        ),
        type: DioExceptionType.badResponse,
      );

      final apiException = ApiException.fromDioException(dioException);
      expect(apiException.statusCode, 401);
      expect(apiException.isUnauthorized, true);
      expect(apiException.message, 'Invalid username or password');
    });

    test('handles connection timeout gracefully', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/api/tickets'),
        type: DioExceptionType.connectionTimeout,
      );

      final apiException = ApiException.fromDioException(dioException);
      expect(apiException.message.contains('timed out'), true);
    });

    test('handles 403 Forbidden correctly', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/api/admin'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/admin'),
          statusCode: 403,
        ),
        type: DioExceptionType.badResponse,
      );

      final apiException = ApiException.fromDioException(dioException);
      expect(apiException.isForbidden, true);
      expect(apiException.message.contains('forbidden'), true);
    });
  });

  group('ApiClient Tests', () {
    test('initializes with cookie jar and withCredentials header', () {
      final cookieJar = CookieJar();
      final client = ApiClient(
        baseUrl: 'http://localhost:8080',
        cookieJar: cookieJar,
      );

      expect(client.dio.options.baseUrl, 'http://localhost:8080');
      expect(client.dio.options.extra['withCredentials'], true);
      expect(client.cookieJar, cookieJar);
    });

    test('hasSessionCookie returns false when cookieJar is empty', () async {
      final cookieJar = CookieJar();
      final client = ApiClient(cookieJar: cookieJar);

      final hasSession = await client.hasSessionCookie();
      expect(hasSession, false);
    });

    test('hasSessionCookie returns true when JSESSIONID cookie exists', () async {
      final cookieJar = CookieJar();
      final uri = Uri.parse('http://localhost:8080');
      await cookieJar.saveFromResponse(uri, [
        Cookie('JSESSIONID', 'mock-session-12345'),
      ]);

      final client = ApiClient(baseUrl: 'http://localhost:8080', cookieJar: cookieJar);
      final hasSession = await client.hasSessionCookie();
      expect(hasSession, true);
    });

    test('clearCookies deletes all cookies', () async {
      final cookieJar = CookieJar();
      final uri = Uri.parse('http://localhost:8080');
      await cookieJar.saveFromResponse(uri, [
        Cookie('JSESSIONID', 'mock-session-12345'),
      ]);

      final client = ApiClient(baseUrl: 'http://localhost:8080', cookieJar: cookieJar);
      expect(await client.hasSessionCookie(), true);

      await client.clearCookies();
      expect(await client.hasSessionCookie(), false);
    });
  });
}
