import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/stats_entity.dart';
import '../repositories/stats_repository.dart';

class GetCurrentMonthStatsUseCase {
  final StatsRepository repository;

  GetCurrentMonthStatsUseCase(this.repository);

  Future<Either<Failure, StatsEntity>> call() {
    return repository.getCurrentMonthStats();
  }
}
