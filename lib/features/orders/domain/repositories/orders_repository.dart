import 'package:dartz/dartz.dart';
import 'package:stock_control_app/features/stats/domain/entities/orders_page_entity.dart';
import '../../../../core/errors/failures.dart';
import '../entities/order_detail_entity.dart';

abstract class OrdersRepository {
  // 🔹 Obtener pedidos paginados (vista general)
  Future<Either<Failure, OrdersPageEntity>> getOrders(
    String? search,
    int page, [
    String? status,
  ]);

  // 🔹 Obtener pedidos asignados a un empleado
  Future<Either<Failure, OrdersPageEntity>> getAssignedOrders(
    int employeeId, [
    String? status,
    String? search,
    int page,
  ]);

  // 🔹 Detalle de un pedido
  Future<Either<Failure, OrderDetailEntity>> getOrderDetail(String id);

  // 🔹 Tomar pedido
  Future<Either<Failure, void>> takeOrder(String id, int employeeId);

  // 🔹 Actualizar estado
  Future<Either<Failure, void>> updateStatus(String id, String status);

  // 🔹 Métricas del dashboard
  Future<Either<Failure, Map<String, dynamic>>> getMetrics();
}
