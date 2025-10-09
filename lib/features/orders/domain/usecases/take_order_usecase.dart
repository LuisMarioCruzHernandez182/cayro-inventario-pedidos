import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/orders_repository.dart';

class TakeOrderUseCase {
  final OrdersRepository repository;

  TakeOrderUseCase(this.repository);

  Future<Either<Failure, void>> call(String id, int employeeId) {
    return repository.takeOrder(id, employeeId);
  }
}
