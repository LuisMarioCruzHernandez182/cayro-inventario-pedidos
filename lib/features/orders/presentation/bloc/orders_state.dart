part of 'orders_bloc.dart';

/// 🔹 Clase base para todos los estados del Bloc de Pedidos
abstract class OrdersState extends Equatable {
  const OrdersState();

  @override
  List<Object?> get props => [];
}

/// 🔹 Estado inicial
class OrdersInitial extends OrdersState {}

/// 🔹 Estado de carga general (listado o detalle)
class OrdersLoading extends OrdersState {}

/// 🔹 Estado de carga para acciones (tomar pedido, actualizar estado, etc.)
class OrdersActionLoading extends OrdersState {}

/// 🔹 Estado de carga para métricas (dashboard)
class OrdersMetricsLoading extends OrdersState {}

/// 🔹 Estado con lista de pedidos cargados (pendientes o asignados)
class OrdersLoaded extends OrdersState {
  final List<OrderEntity> orders;
  final int totalPages;
  final int currentPage;

  const OrdersLoaded({
    required this.orders,
    required this.totalPages,
    required this.currentPage,
  });

  @override
  List<Object?> get props => [orders, totalPages, currentPage];
}

/// 🔹 Estado con detalle completo de un pedido cargado
class OrderDetailLoaded extends OrdersState {
  final OrderDetailEntity order;

  const OrderDetailLoaded(this.order);

  @override
  List<Object?> get props => [order];
}

/// 🔹 Estado con métricas del dashboard cargadas
class OrdersMetricsLoaded extends OrdersState {
  final int totalOrders;
  final double totalSalesMonth;
  final Map<String, int> statusCount;

  const OrdersMetricsLoaded({
    required this.totalOrders,
    required this.totalSalesMonth,
    required this.statusCount,
  });

  @override
  List<Object?> get props => [totalOrders, totalSalesMonth, statusCount];
}

/// 🔹 Estado de error
class OrdersError extends OrdersState {
  final String message;

  const OrdersError(this.message);

  @override
  List<Object?> get props => [message];
}
