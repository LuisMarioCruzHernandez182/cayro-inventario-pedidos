import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/inventory_stats_entity.dart';
import '../repositories/inventory_repository.dart';

class GetInventoryStatsUseCase {
  final InventoryRepository repository;

  GetInventoryStatsUseCase(this.repository);

  Future<Either<Failure, InventoryStatsEntity>> call() {
    return repository.getInventoryStats();
  }
}
