import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../errors/exceptions.dart';

class HttpClient extends http.BaseClient {
  final http.Client _client;
  final AuthLocalDataSource _authLocalDataSource;

  HttpClient({
    required http.Client client,
    required AuthLocalDataSource authLocalDataSource,
  }) : _client = client,
       _authLocalDataSource = authLocalDataSource;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    try {
      final token = await _authLocalDataSource.getAccessToken();
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Content-Type'] = 'application/json';

      final response = await _client
          .send(request)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw ServerException(
                'Request timeout - Check your internet connection',
              );
            },
          );

      return response;
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('Network error: $e');
    }
  }

  String _extractErrorMessage(String responseBody, int statusCode) {
    try {
      if (responseBody.isEmpty) {
        return 'Error del servidor ($statusCode)';
      }

      final jsonData = json.decode(responseBody) as Map<String, dynamic>;

      return jsonData['message'] ??
          jsonData['error'] ??
          jsonData['detail'] ??
          jsonData['description'] ??
          'Error del servidor ($statusCode)';
    } catch (e) {
      return responseBody.length > 100
          ? 'Error del servidor ($statusCode)'
          : responseBody;
    }
  }

  Future<List<dynamic>> getJsonList(String url) async {
    try {
      final uri = Uri.parse(url);
      final response = await super.get(uri);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) return <dynamic>[];

        try {
          final data = json.decode(response.body);
          if (data is List<dynamic>) {
            return data;
          } else {
            throw ServerException('Expected a JSON list but got a map');
          }
        } catch (e) {
          throw ServerException('Invalid JSON list response: $e');
        }
      } else {
        final errorMessage = _extractErrorMessage(
          response.body,
          response.statusCode,
        );
        throw ServerException(errorMessage);
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Network request failed: $e');
    }
  }

  Future<Map<String, dynamic>> getJson(String url) async {
    try {
      final uri = Uri.parse(url);
      final response = await super.get(uri);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          return <String, dynamic>{};
        }

        try {
          return json.decode(response.body) as Map<String, dynamic>;
        } catch (e) {
          throw ServerException('Invalid JSON response: $e');
        }
      } else {
        final errorMessage = _extractErrorMessage(
          response.body,
          response.statusCode,
        );
        throw ServerException(errorMessage);
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('Network request failed: $e');
    }
  }

  Future<Map<String, dynamic>> postJson(
    String url, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = Uri.parse(url);
      final response = await super.post(
        uri,
        body: body != null ? json.encode(body) : null,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          return <String, dynamic>{};
        }

        try {
          return json.decode(response.body) as Map<String, dynamic>;
        } catch (e) {
          throw ServerException('Invalid JSON response: $e');
        }
      } else {
        final errorMessage = _extractErrorMessage(
          response.body,
          response.statusCode,
        );
        throw ServerException(errorMessage);
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('Network request failed: $e');
    }
  }

  @override
  void close() {
    _client.close();
  }
}
