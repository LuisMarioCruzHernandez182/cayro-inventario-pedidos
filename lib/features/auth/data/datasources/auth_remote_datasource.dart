import '../models/login_response_model.dart';
import '../models/user_model.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/http_client.dart';
import 'dart:developer' as developer;

abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login(String identifier, String password);
  Future<String> refreshToken();
  Future<UserModel> getCurrentUser();
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final HttpClient client;
  final String baseUrl;

  AuthRemoteDataSourceImpl({required this.client, required this.baseUrl});

  @override
  Future<LoginResponseModel> login(String identifier, String password) async {
    try {
      final response = await client.postJson(
        '$baseUrl/auth/login',
        body: {'identifier': identifier, 'password': password},
      );

      return LoginResponseModel.fromJson(response);
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<String> refreshToken() async {
    try {
      final response = await client.postJson('$baseUrl/auth/refresh');
      return response['accessToken'] as String;
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw NetworkException('Error de conexión');
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      developer.log(
        '[AuthRemoteDataSource] Getting current user from: $baseUrl/auth/verifyToken',
      );
      final response = await client.getJson('$baseUrl/auth/verifyToken');
      developer.log('[AuthRemoteDataSource] Current user response: $response');
      return UserModel.fromJson(response);
    } catch (e) {
      developer.log('[AuthRemoteDataSource] Error getting current user: $e');
      if (e is ServerException) {
        rethrow;
      }
      throw NetworkException('Error de conexión');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await client.postJson('$baseUrl/auth/logout');
    } catch (e) {
      throw NetworkException('Error al cerrar sesión');
    }
  }
}
