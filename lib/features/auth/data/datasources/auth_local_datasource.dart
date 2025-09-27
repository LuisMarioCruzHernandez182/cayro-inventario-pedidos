import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';

abstract class AuthLocalDataSource {
  Future<String?> getAccessToken();
  Future<void> saveAccessToken(String token);
  Future<void> removeAccessToken();
  Future<bool> isLoggedIn();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _accessTokenKey = 'ACCESS_TOKEN';

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<String?> getAccessToken() async {
    try {
      return sharedPreferences.getString(_accessTokenKey);
    } catch (e) {
      throw CacheException('Error al obtener token');
    }
  }

  @override
  Future<void> saveAccessToken(String token) async {
    try {
      await sharedPreferences.setString(_accessTokenKey, token);
    } catch (e) {
      throw CacheException('Error al guardar token');
    }
  }

  @override
  Future<void> removeAccessToken() async {
    try {
      await sharedPreferences.remove(_accessTokenKey);
    } catch (e) {
      throw CacheException('Error al eliminar token');
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final token = await getAccessToken();
      final isLoggedIn = token != null && token.isNotEmpty;
      return isLoggedIn;
    } catch (e) {
      return false;
    }
  }
}
