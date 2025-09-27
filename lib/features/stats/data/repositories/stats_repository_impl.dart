import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/stats_entity.dart';
import '../../domain/repositories/stats_repository.dart';
import '../datasources/stats_remote_datasource.dart';

class StatsRepositoryImpl implements StatsRepository {
  final StatsRemoteDataSource remoteDataSource;

  StatsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, StatsEntity>> getCurrentMonthStats() async {
    try {
      final stats = await remoteDataSource.getCurrentMonthStats();
      return Right(stats);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('Error inesperado al obtener estadísticas: $e'),
      );
    }
  }
}
