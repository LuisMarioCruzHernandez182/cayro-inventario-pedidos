import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, UserEntity>> login(
    String identifier,
    String password,
  ) async {
    try {
      final loginResponse = await remoteDataSource.login(identifier, password);

      await localDataSource.saveAccessToken(loginResponse.accessToken);
      return Right(loginResponse.user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado durante el login: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      await localDataSource.removeAccessToken();
      return const Right(null);
    } on NetworkException catch (e) {
      await localDataSource.removeAccessToken();
      return Left(NetworkFailure(e.message));
    } catch (e) {
      await localDataSource.removeAccessToken();
      return Left(ServerFailure('Error durante el logout'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final hasToken = await localDataSource.isLoggedIn();
      if (!hasToken) {
        return Left(ServerFailure('No hay sesión activa'));
      }

      final user = await remoteDataSource.getCurrentUser();

      return Right(user);
    } on ServerException catch (e) {
      if (e.message.contains('token') ||
          e.message.contains('unauthorized') ||
          e.message.contains('Error al obtener usuario')) {
        await localDataSource.removeAccessToken();
      }
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error al obtener usuario actual'));
    }
  }
}
