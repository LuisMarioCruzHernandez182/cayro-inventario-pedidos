import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/product_variant_entity.dart';
import '../repositories/inventory_repository.dart';

class UpdateVariantStockUseCase {
  final InventoryRepository repository;

  UpdateVariantStockUseCase(this.repository);

  Future<Either<Failure, ProductVariantEntity>> call({
    required int variantId,
    required String adjustmentType,
    required int quantity,
    String? reason,
  }) {
    return repository.updateVariantStock(
      variantId: variantId,
      adjustmentType: adjustmentType,
      quantity: quantity,
      reason: reason,
    );
  }
}
