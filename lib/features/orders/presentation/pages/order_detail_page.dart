import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:stock_control_app/app/di/injection_container.dart';
import 'package:stock_control_app/features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/orders_bloc.dart';
import '../../domain/entities/order_detail_entity.dart';

class OrderDetailPage extends StatelessWidget {
  final String orderId;
  const OrderDetailPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OrdersBloc>()..add(LoadOrderDetailEvent(orderId)),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.blue600, AppColors.blue500, AppColors.blue400],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  flex: 6,
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: BlocBuilder<OrdersBloc, OrdersState>(
                      builder: (context, state) {
                        if (state is OrdersLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (state is OrdersError) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                state.message,
                                style: const TextStyle(
                                  color: AppColors.red500,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        } else if (state is OrderDetailLoaded) {
                          return _buildOrderDetail(context, state.order);
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔹 Encabezado superior
  Widget _buildHeader(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Row(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back, color: AppColors.blue600),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Detalle del Pedido',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Visualiza toda la información del pedido',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontWeight: FontWeight.w300,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }

  // 🔹 Contenido principal
  Widget _buildOrderDetail(BuildContext context, OrderDetailEntity order) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummary(order),
          const SizedBox(height: 20),
          _buildAssignment(
            order.employeeName,
            order.isTaken,
            context,
            order.id,
          ),
          const SizedBox(height: 20),
          _buildProgress(order.status),
          const SizedBox(height: 20),
          _buildStatusDropdown(context, order),
          const SizedBox(height: 20),
          _buildProducts(
            order.items,
            order.totalAmount,
            order.subtotalAmount,
            order.shippingCost,
          ),
        ],
      ),
    );
  }

  // 🔹 Asignación del pedido + botón “Tomar pedido”
  Widget _buildAssignment(
    String? employeeName,
    bool isTaken,
    BuildContext context,
    String orderId,
  ) {
    final assigned = (employeeName ?? '').isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Asignación del Pedido',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.gray800,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.purple100,
            child: Icon(Icons.person, color: AppColors.purple600, size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            assigned
                ? 'Asignado a: $employeeName'
                : 'Este pedido no está asignado a ningún empleado',
            style: const TextStyle(color: AppColors.gray700, fontSize: 15),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // 🔹 Mostrar el botón solo si el pedido no está tomado
          if (!isTaken)
            ElevatedButton.icon(
              onPressed: () {
                final authState = context.read<AuthBloc>().state;
                final employeeId = (authState is AuthAuthenticated)
                    ? int.tryParse(authState.user.id.toString()) ?? 0
                    : 0;

                context.read<OrdersBloc>().add(
                  TakeOrderEvent(orderId, employeeId),
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pedido tomado correctamente'),
                    backgroundColor: AppColors.green600,
                  ),
                );

                // 🔄 Recargar el detalle actualizado
                context.read<OrdersBloc>().add(LoadOrderDetailEvent(orderId));
              },
              icon: const Icon(Icons.assignment_turned_in),
              label: const Text('Tomar pedido'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 🔹 Progreso del pedido
  Widget _buildProgress(String status) {
    final statuses = ['PROCESSING', 'PACKED', 'SHIPPED', 'DELIVERED'];
    final index = statuses.indexOf(status);
    final progress = (index + 1) / statuses.length;

    final Map<String, String> labels = {
      'PROCESSING': 'Procesando',
      'PACKED': 'Empacado',
      'SHIPPED': 'Enviado',
      'DELIVERED': 'Entregado',
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Progreso del Pedido',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            borderRadius: BorderRadius.circular(8),
            backgroundColor: AppColors.gray200,
            color: AppColors.blue600,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var s in statuses)
                Expanded(
                  child: Text(
                    labels[s]!,
                    style: TextStyle(
                      fontSize: 12,
                      color: s == status
                          ? AppColors.blue600
                          : AppColors.gray500,
                      fontWeight: s == status
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // 🔹 Dropdown de estado (sin “value” deprecado)
  Widget _buildStatusDropdown(BuildContext context, OrderDetailEntity order) {
    final allStatuses = [
      'PENDING',
      'PROCESSING',
      'PACKED',
      'SHIPPED',
      'DELIVERED',
      'CANCELLED',
    ];

    final Map<String, String> labels = {
      'PROCESSING': 'Procesando',
      'PACKED': 'Empacado',
      'SHIPPED': 'Enviado',
      'DELIVERED': 'Entregado',
      'CANCELLED': 'Cancelado',
    };

    String selectedStatus = order.status;

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cambiar Estado',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray900,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedStatus,
                isExpanded: true,
                items: [
                  for (var s in allStatuses)
                    DropdownMenuItem(
                      value: s,
                      child: Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 10,
                            color: s == order.status
                                ? Colors.amber
                                : AppColors.blue600,
                          ),
                          const SizedBox(width: 8),
                          Text(labels[s] ?? s),
                        ],
                      ),
                    ),
                ],
                onChanged: (value) {
                  if (value != null && value != order.status) {
                    setState(() => selectedStatus = value);
                    context.read<OrdersBloc>().add(
                      UpdateStatusEvent(order.id, value),
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Estado cambiado a ${labels[value] ?? value}',
                        ),
                        backgroundColor: AppColors.green600,
                      ),
                    );
                  }
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.gray50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 🔹 Resumen del pedido
  Widget _buildSummary(OrderDetailEntity order) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pedido #${order.id}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray900,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.amber50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.amber100),
                ),
                child: Text(
                  order.status,
                  style: const TextStyle(
                    color: AppColors.amber600,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Cliente: ${order.userName}',
            style: const TextStyle(
              color: AppColors.gray800,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (order.address != null && order.address!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              order.address!,
              style: const TextStyle(color: AppColors.gray600, fontSize: 14),
            ),
          ],
          const Divider(height: 28),
          _buildAmountRow('Subtotal', order.subtotalAmount),
          _buildAmountRow('Envío', order.shippingCost),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blue600,
                ),
              ),
              Text(
                '\$${order.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blue600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🔹 Productos del pedido
  Widget _buildProducts(
    List<OrderItem> items,
    double total,
    double subtotal,
    double shipping,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Productos del Pedido',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.gray800,
            ),
          ),
          const SizedBox(height: 16),
          for (final item in items) _buildProductItem(item),
          const Divider(height: 24, color: AppColors.gray200),
          _buildAmountRow('Subtotal', subtotal),
          _buildAmountRow('Envío', shipping),
          const Divider(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Total: \$${total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.blue600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.gray700)),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: const TextStyle(
            color: AppColors.gray800,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildProductItem(OrderItem item) {
    final validImage =
        item.image != null &&
        (item.image!.startsWith('http') || item.image!.startsWith('https'));

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: validImage
                ? Image.network(
                    item.image!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholderImage(),
                  )
                : _placeholderImage(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray800,
                    fontSize: 15,
                  ),
                ),
                Text(
                  'Cantidad: ${item.quantity} • Talla: ${item.size} • Color: ${item.color}',
                  style: const TextStyle(
                    color: AppColors.gray600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  '\$${item.unitPrice.toStringAsFixed(2)} c/u',
                  style: const TextStyle(
                    color: AppColors.gray500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '\$${item.total.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.gray800,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderImage() => Container(
    width: 60,
    height: 60,
    color: AppColors.gray100,
    child: const Icon(Icons.image, color: AppColors.gray400),
  );

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: const [
      BoxShadow(
        color: AppColors.shadowColor,
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  );
}
