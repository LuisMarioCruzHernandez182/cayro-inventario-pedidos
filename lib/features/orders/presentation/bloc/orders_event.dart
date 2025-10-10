part of 'orders_bloc.dart';

abstract class OrdersEvent extends Equatable {
  const OrdersEvent();

  @override
  List<Object?> get props => [];
}

class LoadOrdersEvent extends OrdersEvent {
  final String? search;
  final int page;
  final String? status;

  const LoadOrdersEvent({this.search, this.page = 1, this.status});

  @override
  List<Object?> get props => [search, page, status];
}

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

class SendTrackingEmailEvent extends OrdersEvent {
  final Map<String, dynamic> emailData;

  const SendTrackingEmailEvent(this.emailData);

  @override
  List<Object?> get props => [emailData];
}

class LoadOrderDetailEvent extends OrdersEvent {
  final String id;

  const LoadOrderDetailEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class TakeOrderEvent extends OrdersEvent {
  final String id;
  final int employeeId;

  const TakeOrderEvent(this.id, this.employeeId);

  @override
  List<Object?> get props => [id, employeeId];
}

class UpdateStatusEvent extends OrdersEvent {
  final String id;
  final String status;

  const UpdateStatusEvent(this.id, this.status);

  @override
  List<Object?> get props => [id, status];
}

class LoadMetricsEvent extends OrdersEvent {
  const LoadMetricsEvent();
}
