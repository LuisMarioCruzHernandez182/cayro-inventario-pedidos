import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/product_variant_entity.dart';
import '../../domain/entities/inventory_stats_entity.dart';
import '../../domain/entities/inventory_response_entity.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../datasources/inventory_remote_datasource.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryRemoteDataSource remoteDataSource;

  InventoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, InventoryResponseEntity>> getInventory({
    int page = 1,
    int limit = 10,
    String? search,
    String? stockStatus,
  }) async {
    try {
      final response = await remoteDataSource.getInventory(
        page: page,
        limit: limit,
        search: search,
        stockStatus: stockStatus,
      );
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado obteniendo inventario: $e'));
    }
  }

  @override
  Future<Either<Failure, InventoryStatsEntity>> getInventoryStats() async {
    try {
      final stats = await remoteDataSource.getInventoryStats();
      return Right(stats);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('Error inesperado obteniendo estadísticas: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductById(int id) async {
    try {
      final product = await remoteDataSource.getProductById(id);
      return Right(product);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado obteniendo producto: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ProductVariantEntity>>> getProductVariants(
    int productId,
  ) async {
    try {
      final variants = await remoteDataSource.getProductVariants(productId);
      return Right(variants);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado obteniendo variantes: $e'));
    }
  }

  @override
  Future<Either<Failure, ProductVariantEntity>> updateVariantStock({
    required int variantId,
    required String adjustmentType,
    required int quantity,
    String? reason,
  }) async {
    try {
      final variant = await remoteDataSource.updateVariantStock(
        variantId: variantId,
        adjustmentType: adjustmentType,
        quantity: quantity,
        reason: reason,
      );
      return Right(variant);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado actualizando stock: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ProductVariantEntity>>> getLowStockProducts(
    int threshold,
  ) async {
    try {
      final variants = await remoteDataSource.getLowStockProducts(threshold);
      return Right(variants);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure(
          'Error inesperado obteniendo productos con poco stock: $e',
        ),
      );
    }
  }
}
