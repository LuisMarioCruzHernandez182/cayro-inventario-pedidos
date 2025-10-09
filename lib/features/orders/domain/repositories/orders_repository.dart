import 'package:dartz/dartz.dart';
import 'package:stock_control_app/features/stats/domain/entities/orders_page_entity.dart';
import '../../../../core/errors/failures.dart';
import '../entities/order_detail_entity.dart';

abstract class OrdersRepository {
  Future<Either<Failure, OrdersPageEntity>> getOrders(
    String? search,
    int page, [
    String? status,
  ]);

  Future<Either<Failure, OrdersPageEntity>> getAssignedOrders(
    int employeeId, [
    String? status,
    String? search,
    int page,
  ]);

  Future<Either<Failure, OrderDetailEntity>> getOrderDetail(String id);

  Future<Either<Failure, void>> takeOrder(String id, int employeeId);

  Future<Either<Failure, void>> updateStatus(String id, String status);

  Future<Either<Failure, Map<String, dynamic>>> getMetrics();
}
