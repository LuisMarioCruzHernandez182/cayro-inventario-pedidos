import '../models/stats_model.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/http_client.dart';
import 'dart:developer' as developer;

abstract class StatsRemoteDataSource {
  Future<StatsModel> getCurrentMonthStats();
}

class StatsRemoteDataSourceImpl implements StatsRemoteDataSource {
  final HttpClient client;
  final String baseUrl;

  StatsRemoteDataSourceImpl({required this.client, required this.baseUrl});

  @override
  Future<StatsModel> getCurrentMonthStats() async {
    try {
      developer.log(
        '[StatsRemoteDataSource] Getting current month stats from: $baseUrl/product/current-month',
      );
      final response = await client.getJson('$baseUrl/product/current-month');
      developer.log('[StatsRemoteDataSource] Stats response: $response');
      return StatsModel.fromJson(response);
    } catch (e) {
      developer.log('[StatsRemoteDataSource] Error getting stats: $e');
      if (e is ServerException) {
        rethrow;
      }
      throw NetworkException('Error de conexión al obtener estadísticas');
    }
  }
}
