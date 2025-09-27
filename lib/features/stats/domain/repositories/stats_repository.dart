import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/stats_entity.dart';

abstract class StatsRepository {
  Future<Either<Failure, StatsEntity>> getCurrentMonthStats();
}
