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
    final token = await _authLocalDataSource.getAccessToken();
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.headers['Content-Type'] = 'application/json';

    return _client.send(request);
  }

  Future<Map<String, dynamic>> getJson(String url) async {
    final uri = Uri.parse(url);
    final response = await super.get(uri);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw ServerException('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> postJson(String url, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse(url);
    final response = await super.post(
      uri,
      body: body != null ? json.encode(body) : null,
    );
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return <String, dynamic>{};
      }
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw ServerException('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  @override
  void close() {
    _client.close();
  }
}
