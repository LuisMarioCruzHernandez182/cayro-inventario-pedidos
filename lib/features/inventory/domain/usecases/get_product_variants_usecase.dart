import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/product_variant_entity.dart';
import '../repositories/inventory_repository.dart';

class GetProductVariantsUseCase {
  final InventoryRepository repository;

  GetProductVariantsUseCase(this.repository);

  Future<Either<Failure, List<ProductVariantEntity>>> call(int productId) {
    return repository.getProductVariants(productId);
  }
}
