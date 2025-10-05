import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/inventory_response_entity.dart';
import '../repositories/inventory_repository.dart';

class GetInventoryUseCase {
  final InventoryRepository repository;

  GetInventoryUseCase(this.repository);

  Future<Either<Failure, InventoryResponseEntity>> call({
    int page = 1,
    int limit = 10,
    String? search,
  }) {
    return repository.getInventory(page: page, limit: limit, search: search);
  }
}
