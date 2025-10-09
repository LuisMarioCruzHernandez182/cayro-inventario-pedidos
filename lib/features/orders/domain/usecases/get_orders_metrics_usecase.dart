import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/orders_repository.dart';

class GetOrdersMetricsUseCase {
  final OrdersRepository repository;

  GetOrdersMetricsUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call() {
    return repository.getMetrics();
  }
}
