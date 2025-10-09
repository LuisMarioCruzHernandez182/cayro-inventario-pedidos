part of 'orders_bloc.dart';

abstract class OrdersState extends Equatable {
  const OrdersState();

  @override
  List<Object?> get props => [];
}

class OrdersInitial extends OrdersState {}

class OrdersLoading extends OrdersState {}

class OrdersActionLoading extends OrdersState {}

class OrdersMetricsLoading extends OrdersState {}

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

class OrderDetailLoaded extends OrdersState {
  final OrderDetailEntity order;

  const OrderDetailLoaded(this.order);

  @override
  List<Object?> get props => [order];
}

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

class OrdersError extends OrdersState {
  final String message;

  const OrdersError(this.message);

  @override
  List<Object?> get props => [message];
}
