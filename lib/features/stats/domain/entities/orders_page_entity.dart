import 'package:stock_control_app/features/orders/domain/entities/order_entity.dart';


class OrdersPageEntity {
  final List<OrderEntity> orders;
  final int totalPages;
  final int currentPage;

  OrdersPageEntity({
    required this.orders,
    required this.totalPages,
    required this.currentPage,
  });
}
