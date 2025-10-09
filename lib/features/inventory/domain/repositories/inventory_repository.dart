import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/inventory_response_entity.dart';
import '../entities/product_entity.dart';
import '../entities/product_variant_entity.dart';
import '../entities/inventory_stats_entity.dart';

abstract class InventoryRepository {
  Future<Either<Failure, InventoryResponseEntity>> getInventory({
    int page = 1,
    int limit = 10,
    String? search,
    String? stockStatus,
  });

  Future<Either<Failure, InventoryStatsEntity>> getInventoryStats();

  Future<Either<Failure, ProductEntity>> getProductById(int id);

  Future<Either<Failure, List<ProductVariantEntity>>> getProductVariants(
    int productId,
  );

  Future<Either<Failure, ProductVariantEntity>> updateVariantStock({
    required int variantId,
    required String adjustmentType,
    required int quantity,
    String? reason,
  });

  Future<Either<Failure, List<ProductVariantEntity>>> getLowStockProducts(
    int threshold,
  );
}
