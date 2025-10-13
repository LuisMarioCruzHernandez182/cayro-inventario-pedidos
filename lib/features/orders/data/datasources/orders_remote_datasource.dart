import '../../../../core/network/http_client.dart';
import '../../../../core/errors/exceptions.dart';

class OrdersRemoteDataSource {
  final HttpClient client;
  final String baseUrl;

  OrdersRemoteDataSource({required this.client, required this.baseUrl});

  Future<Map<String, dynamic>> getOrders({
    String? search,
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, String>{
        if (search != null && search.isNotEmpty) 'search': search,
        if (status != null && status.isNotEmpty) 'status': status,
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final query = Uri(queryParameters: queryParams).query;
      return await client.getJson('$baseUrl/orders?$query');
    } catch (e) {
      throw ServerException('Error obteniendo pedidos: $e');
    }
  }

  Future<Map<String, dynamic>> getAvailableOrders({
    String? search,
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, String>{
        if (search != null && search.isNotEmpty) 'search': search,
        if (status != null && status.isNotEmpty) 'status': status,
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final query = Uri(queryParameters: queryParams).query;
      return await client.getJson('$baseUrl/orders/available?$query');
    } catch (e) {
      throw ServerException('Error obteniendo pedidos disponibles: $e');
    }
  }

  Future<Map<String, dynamic>> getAssignedOrders(
    int employeeId, {
    String? status,
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      // ✅ Construcción correcta de query params
      final queryParams = <String, String>{
        if (status != null && status.isNotEmpty) 'status': status,
        if (search != null && search.isNotEmpty) 'search': search,
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final query = Uri(queryParameters: queryParams).query;

      // ✅ Endpoint correcto con ID en la ruta (NestJS espera esto)
      final url = '$baseUrl/orders/assigned/$employeeId?$query';

      final response = await client.getJson(url);

      if (!response.containsKey('data')) {
        throw ServerException('Respuesta inesperada del servidor');
      }

      return response;
    } catch (e) {
      throw ServerException('Error obteniendo pedidos asignados: $e');
    }
  }

  Future<Map<String, dynamic>> getOrderDetail(String id) async {
    try {
      return await client.getJson('$baseUrl/orders/$id');
    } catch (e) {
      throw ServerException('Error obteniendo detalle del pedido: $e');
    }
  }

  Future<void> takeOrder(String id, int employeeId) async {
    try {
      await client.postJson(
        '$baseUrl/orders/$id/take',
        body: {'employeeId': employeeId},
      );
    } catch (e) {
      throw ServerException('Error al tomar pedido: $e');
    }
  }

  Future<void> updateStatus(String id, String status) async {
    try {
      await client.postJson(
        '$baseUrl/orders/$id/status',
        body: {'status': status},
      );
    } catch (e) {
      throw ServerException('Error al actualizar estado: $e');
    }
  }

  Future<Map<String, dynamic>> getMetrics() async {
    try {
      return await client.getJson('$baseUrl/orders/dashboard/metrics');
    } catch (e) {
      throw ServerException('Error obteniendo métricas: $e');
    }
  }

  Future<void> sendTrackingEmail({
    required Map<String, dynamic> emailData,
  }) async {
    try {
      await client.postJson('$baseUrl/sales/notify', body: emailData);
    } catch (e) {
      throw ServerException('Error enviando correo de rastreo: $e');
    }
  }
}
