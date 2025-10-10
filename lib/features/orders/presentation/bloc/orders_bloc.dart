import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_detail_entity.dart';
import '../../domain/usecases/get_orders_usecase.dart';
import '../../domain/usecases/get_order_detail_usecase.dart';
import '../../domain/usecases/take_order_usecase.dart';
import '../../domain/usecases/update_order_status_usecase.dart';
import '../../domain/usecases/get_orders_metrics_usecase.dart';
import '../../domain/usecases/get_assigned_orders_usecase.dart';
import '../../domain/usecases/send_tracking_email_usecase.dart';

part 'orders_event.dart';
part 'orders_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final GetOrdersUseCase getOrders;
  final GetOrderDetailUseCase getOrderDetail;
  final TakeOrderUseCase takeOrder;
  final UpdateOrderStatusUseCase updateStatus;
  final GetOrdersMetricsUseCase getMetrics;
  final GetAssignedOrdersUseCase getAssignedOrders;
  final SendTrackingEmailUseCase sendTrackingEmail;

  OrdersBloc({
    required this.getOrders,
    required this.getOrderDetail,
    required this.takeOrder,
    required this.updateStatus,
    required this.getMetrics,
    required this.getAssignedOrders,
    required this.sendTrackingEmail,
  }) : super(OrdersInitial()) {
    on<LoadOrdersEvent>(_onLoadOrders);
    on<LoadOrderDetailEvent>(_onLoadOrderDetail);
    on<TakeOrderEvent>(_onTakeOrder);
    on<UpdateStatusEvent>(_onUpdateStatus);
    on<LoadMetricsEvent>(_onLoadMetrics);
    on<LoadAssignedOrdersEvent>(_onLoadAssignedOrders);
    on<SendTrackingEmailEvent>(_onSendTrackingEmail);
  }

  Future<void> _onLoadOrders(
    LoadOrdersEvent e,
    Emitter<OrdersState> emit,
  ) async {
    emit(OrdersLoading());

    final status = e.status ?? 'PENDING';
    final result = await getOrders(e.search, e.page, status);

    result.fold(
      (failure) => emit(OrdersError(failure.message)),
      (pageData) => emit(
        OrdersLoaded(
          orders: pageData.orders,
          totalPages: pageData.totalPages,
          currentPage: pageData.currentPage,
        ),
      ),
    );
  }

  Future<void> _onLoadOrderDetail(
    LoadOrderDetailEvent e,
    Emitter<OrdersState> emit,
  ) async {
    emit(OrdersLoading());
    final result = await getOrderDetail(e.id);

    result.fold(
      (failure) => emit(OrdersError(failure.message)),
      (order) => emit(OrderDetailLoaded(order)),
    );
  }

  // 🔹 Enviar correo de rastreo con todos los datos
  Future<void> _onSendTrackingEmail(
    SendTrackingEmailEvent e,
    Emitter<OrdersState> emit,
  ) async {
    emit(OrdersActionLoading());

    final result = await sendTrackingEmail(emailData: e.emailData);

    result.fold(
      (failure) => emit(OrdersError(failure.message)),
      (_) => emit(TrackingEmailSent('Correo de rastreo enviado correctamente')),
    );
  }

  Future<void> _onLoadAssignedOrders(
    LoadAssignedOrdersEvent e,
    Emitter<OrdersState> emit,
  ) async {
    emit(OrdersLoading());

    final result = await getAssignedOrders(
      e.employeeId,
      e.status,
      e.search,
      e.page,
    );

    result.fold(
      (failure) => emit(OrdersError(failure.message)),
      (pageData) => emit(
        OrdersLoaded(
          orders: pageData.orders,
          totalPages: pageData.totalPages,
          currentPage: pageData.currentPage,
        ),
      ),
    );
  }

  Future<void> _onTakeOrder(TakeOrderEvent e, Emitter<OrdersState> emit) async {
    emit(OrdersActionLoading());

    final result = await takeOrder(e.id, e.employeeId);

    result.fold((failure) => emit(OrdersError(failure.message)), (_) async {
      final detailResult = await getOrderDetail(e.id);
      detailResult.fold(
        (failure) => emit(OrdersError(failure.message)),
        (order) => emit(OrderDetailLoaded(order)),
      );
    });
  }

  Future<void> _onUpdateStatus(
    UpdateStatusEvent e,
    Emitter<OrdersState> emit,
  ) async {
    emit(OrdersActionLoading());

    final result = await updateStatus(e.id, e.status);

    await result.fold(
      (failure) async {
        emit(OrdersError(failure.message));
      },
      (_) async {
        final detailResult = await getOrderDetail(e.id);
        await detailResult.fold(
          (failure) async => emit(OrdersError(failure.message)),
          (order) async => emit(OrderDetailLoaded(order)),
        );
      },
    );
  }

  Future<void> _onLoadMetrics(
    LoadMetricsEvent e,
    Emitter<OrdersState> emit,
  ) async {
    emit(OrdersMetricsLoading());

    final result = await getMetrics();

    result.fold((failure) => emit(OrdersError(failure.message)), (data) {
      final totalOrders = data['totalOrders'] ?? 0;
      final totalSalesMonth = (data['totalSalesMonth'] ?? 0).toDouble();

      final Map<String, int> statusCount = {};
      for (var s in data['byStatus']) {
        final status = s['status'] ?? 'UNKNOWN';
        final count = s['_count']?['status'] ?? 0;
        statusCount[status] = count;
      }

      emit(
        OrdersMetricsLoaded(
          totalOrders: totalOrders,
          totalSalesMonth: totalSalesMonth,
          statusCount: statusCount,
        ),
      );
    });
  }
}
