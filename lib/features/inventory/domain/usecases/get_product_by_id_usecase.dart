import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/product_entity.dart';
import '../repositories/inventory_repository.dart';

class GetProductByIdUseCase {
  final InventoryRepository repository;

  GetProductByIdUseCase(this.repository);

  Future<Either<Failure, ProductEntity>> call(int id) {
    return repository.getProductById(id);
  }
}
