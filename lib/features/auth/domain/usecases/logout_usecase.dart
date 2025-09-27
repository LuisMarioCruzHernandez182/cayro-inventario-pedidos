import 'package:dartz/dartz.dart';
import 'package:stock_control_app/features/auth/domain/repositories/auth_repository.dart';
import '../../../../core/errors/failures.dart';

class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.logout();
  }
}
