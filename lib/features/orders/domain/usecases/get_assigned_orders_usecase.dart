import 'package:dartz/dartz.dart';
import 'package:stock_control_app/features/stats/domain/entities/orders_page_entity.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/orders_repository.dart';

class GetAssignedOrdersUseCase {
  final OrdersRepository repository;

  GetAssignedOrdersUseCase(this.repository);

  Future<Either<Failure, OrdersPageEntity>> call(
    int employeeId, [
    String? status,
    String? search,
    int page = 1,
  ]) async {
    return await repository.getAssignedOrders(employeeId, status, search, page);
  }
}
