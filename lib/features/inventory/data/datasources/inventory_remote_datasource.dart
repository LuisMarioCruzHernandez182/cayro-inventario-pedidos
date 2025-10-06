import 'package:stock_control_app/features/inventory/domain/entities/product_entity.dart';

import '../models/product_model.dart';
import '../models/product_variant_model.dart';
import '../models/inventory_stats_model.dart';
import '../../domain/entities/inventory_response_entity.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/http_client.dart';
import 'dart:convert';
import 'dart:developer' as developer;

abstract class InventoryRemoteDataSource {
  Future<InventoryResponseEntity> getInventory({
    int page = 1,
    int limit = 10,
    String? search,
    String? stockStatus,
  });

  Future<InventoryStatsModel> getInventoryStats();

  Future<ProductModel> getProductById(int id);

  Future<List<ProductVariantModel>> getProductVariants(int productId);

  Future<ProductVariantModel> updateVariantStock({
    required int variantId,
    required String adjustmentType,
    required int quantity,
    String? reason,
  });

  Future<List<ProductVariantModel>> getLowStockProducts(int threshold);
}

class InventoryRemoteDataSourceImpl implements InventoryRemoteDataSource {
  final HttpClient client;
  final String baseUrl;

  InventoryRemoteDataSourceImpl({required this.client, required this.baseUrl});

  @override
  Future<InventoryResponseEntity> getInventory({
    int page = 1,
    int limit = 10,
    String? search,
    String? stockStatus,
  }) async {
    try {
      String url = '$baseUrl/inventory?page=$page&limit=$limit';
      if (search != null && search.isNotEmpty) {
        url += '&search=${Uri.encodeComponent(search)}';
      }

      if (stockStatus != null && stockStatus.isNotEmpty) {
        url += '&stockStatus=$stockStatus';
      }
      final response = await client.getJson(url);
      developer.log(
        '[InventoryRemoteDataSource] Inventory response: ${jsonEncode(response)}',
      );

      final products = (response['products'] as List<dynamic>)
          .map((product) => ProductModel.fromJson(product) as ProductEntity)
          .toList();

      final pagination = response['pagination'] as Map<String, dynamic>;
      developer.log('[InventoryRemoteDataSource] Pagination info: $pagination');

      return InventoryResponseEntity(
        products: products,
        pagination: PaginationInfo(
          page: pagination['page'] as int,
          limit: pagination['limit'] as int,
          total: pagination['total'] as int,
          totalPages: pagination['totalPages'] as int,
        ),
      );
    } catch (e) {
      developer.log('[InventoryRemoteDataSource] Error getting inventory: $e');
      if (e is ServerException) {
        rethrow;
      }
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<InventoryStatsModel> getInventoryStats() async {
    try {
      developer.log(
        '[InventoryRemoteDataSource] Getting inventory stats from: $baseUrl/inventory/stats',
      );
      final response = await client.getJson('$baseUrl/inventory/stats');
      developer.log('[InventoryRemoteDataSource] Stats response: $response');

      return InventoryStatsModel.fromJson(response);
    } catch (e) {
      developer.log('[InventoryRemoteDataSource] Error getting stats: $e');
      if (e is ServerException) {
        rethrow;
      }
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<ProductModel> getProductById(int id) async {
    try {
      developer.log(
        '[InventoryRemoteDataSource] Getting product by id from: $baseUrl/inventory/product/$id',
      );
      final response = await client.getJson('$baseUrl/inventory/product/$id');
      developer.log('[InventoryRemoteDataSource] Product response: $response');

      return ProductModel.fromJson(response);
    } catch (e) {
      developer.log('[InventoryRemoteDataSource] Error getting product: $e');
      if (e is ServerException) {
        rethrow;
      }
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<List<ProductVariantModel>> getProductVariants(int productId) async {
    try {
      final url = '$baseUrl/inventory/product/$productId/variants';
      developer.log(
        '[InventoryRemoteDataSource] Getting product variants from: $url',
      );

      final response = await client.getJsonList(url);

      developer.log('[InventoryRemoteDataSource] Variants response: $response');

      final variants = response
          .map((variant) => ProductVariantModel.fromJson(variant))
          .toList();

      return variants;
    } catch (e) {
      developer.log('[InventoryRemoteDataSource] Error getting variants: $e');
      if (e is ServerException) rethrow;
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<ProductVariantModel> updateVariantStock({
    required int variantId,
    required String adjustmentType,
    required int quantity,
    String? reason,
  }) async {
    try {
      final body = {
        'adjustmentType': adjustmentType,
        'quantity': quantity,
        if (reason != null) 'reason': reason,
      };

      developer.log(
        '[InventoryRemoteDataSource] Updating variant stock: $baseUrl/inventory/variant/$variantId/stock',
      );
      developer.log('[InventoryRemoteDataSource] Update body: $body');

      final response = await client.postJson(
        '$baseUrl/inventory/variant/$variantId/stock',
        body: body,
      );

      developer.log('[InventoryRemoteDataSource] Update response: $response');

      return ProductVariantModel.fromJson(response);
    } catch (e) {
      developer.log('[InventoryRemoteDataSource] Error updating stock: $e');
      if (e is ServerException) {
        rethrow;
      }
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<List<ProductVariantModel>> getLowStockProducts(int threshold) async {
    try {
      developer.log(
        '[InventoryRemoteDataSource] Getting low stock products from: $baseUrl/inventory/low-stock?threshold=$threshold',
      );
      final response = await client.getJson(
        '$baseUrl/inventory/low-stock?threshold=$threshold',
      );
      developer.log(
        '[InventoryRemoteDataSource] Low stock response: $response',
      );

      final variants = (response as List<dynamic>)
          .map((variant) => ProductVariantModel.fromJson(variant))
          .toList();

      return variants;
    } catch (e) {
      developer.log('[InventoryRemoteDataSource] Error getting low stock: $e');
      if (e is ServerException) {
        rethrow;
      }
      throw NetworkException('Error de conexión: $e');
    }
  }
}
