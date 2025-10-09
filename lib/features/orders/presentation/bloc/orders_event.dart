part of 'orders_bloc.dart';

/// 🔹 Clase base para todos los eventos del Bloc de Pedidos
abstract class OrdersEvent extends Equatable {
  const OrdersEvent();

  @override
  List<Object?> get props => [];
}

/// 🔹 Cargar pedidos generales (por estado, búsqueda o paginación)
class LoadOrdersEvent extends OrdersEvent {
  final String? search;
  final int page;
  final String? status;

  const LoadOrdersEvent({this.search, this.page = 1, this.status});

  @override
  List<Object?> get props => [search, page, status];
}

/// 🔹 Cargar pedidos asignados a un empleado específico
class LoadAssignedOrdersEvent extends OrdersEvent {
  final int employeeId;
  final String? status;
  final String? search;
  final int page;

  const LoadAssignedOrdersEvent({
    required this.employeeId,
    this.status,
    this.search,
    this.page = 1,
  });

  @override
  List<Object?> get props => [employeeId, status, search, page];
}

/// 🔹 Cargar detalle de un pedido
class LoadOrderDetailEvent extends OrdersEvent {
  final String id;

  const LoadOrderDetailEvent(this.id);

  @override
  List<Object?> get props => [id];
}

/// 🔹 Tomar pedido (empleado lo asigna)
class TakeOrderEvent extends OrdersEvent {
  final String id;
  final int employeeId;

  const TakeOrderEvent(this.id, this.employeeId);

  @override
  List<Object?> get props => [id, employeeId];
}

/// 🔹 Actualizar estado del pedido (ej. PROCESSING, PACKED, SHIPPED)
class UpdateStatusEvent extends OrdersEvent {
  final String id;
  final String status;

  const UpdateStatusEvent(this.id, this.status);

  @override
  List<Object?> get props => [id, status];
}

/// 🔹 Cargar métricas del dashboard (pedidos totales, ventas, estados)
class LoadMetricsEvent extends OrdersEvent {
  const LoadMetricsEvent();
}
