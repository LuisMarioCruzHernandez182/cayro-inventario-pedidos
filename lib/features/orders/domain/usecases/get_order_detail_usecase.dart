import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/order_detail_entity.dart';
import '../repositories/orders_repository.dart';

class GetOrderDetailUseCase {
  final OrdersRepository repository;

  GetOrderDetailUseCase(this.repository);

  Future<Either<Failure, OrderDetailEntity>> call(String id) {
    return repository.getOrderDetail(id);
  }
}
