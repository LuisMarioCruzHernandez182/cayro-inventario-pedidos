import 'package:dartz/dartz.dart';
import 'package:stock_control_app/features/stats/domain/entities/orders_page_entity.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/orders_repository.dart';

class GetOrdersUseCase {
  final OrdersRepository repository;

  GetOrdersUseCase(this.repository);

  Future<Either<Failure, OrdersPageEntity>> call(
    String? search,
    int page, [
    String? status,
  ]) async {
    return await repository.getOrders(search, page, status);
  }
}
