import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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
    final ValueNotifier<bool> isUpdating = ValueNotifier(false);
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    // Funciones de escalado responsivo
    double scaleW(double value) => value * (width / 390);
    double scaleH(double value) => value * (height / 844);

    return BlocProvider(
      create: (_) => sl<OrdersBloc>()..add(LoadOrderDetailEvent(orderId)),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColors.blue600, // Fondo azul sólido
        body: SafeArea(
          child: Stack(
            children: [
              BlocListener<OrdersBloc, OrdersState>(
                listener: (context, state) {
                  // Control del loader
                  if (state is OrdersActionLoading) {
                    isUpdating.value = true;
                  } else if (state is OrderDetailLoaded ||
                      state is OrdersError ||
                      state is TrackingEmailSent) {
                    isUpdating.value = false;
                  }

                  // Mensaje al enviar correo
                  if (state is TrackingEmailSent) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: AppColors.green600,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    });
                    if (context.mounted) {
                      context.read<OrdersBloc>().add(
                        LoadOrderDetailEvent(orderId),
                      );
                    }
                  }
                },
                child: BlocBuilder<OrdersBloc, OrdersState>(
                  builder: (context, state) {
                    if (state is OrdersLoading || isUpdating.value) {
                      return Container(
                        color: AppColors.white, // Fondo azul para el loader
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                color: AppColors.blue600,
                                strokeWidth: scaleW(3),
                              ),
                              SizedBox(height: scaleH(16)),
                              Text(
                                "Cargando pedido...",
                                style: TextStyle(
                                  color: AppColors.blue600,
                                  fontSize: scaleW(16),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else if (state is OrdersError) {
                      return Container(
                        color: AppColors.blue600,
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(scaleW(20)),
                            child: Text(
                              state.message,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: scaleW(16),
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    } else if (state is OrderDetailLoaded) {
                      return Container(
                        color: AppColors
                            .blue600, // Color sólido en lugar de gradiente
                        child: SafeArea(
                          child: Column(
                            children: [
                              _buildHeader(context, scaleW, scaleH),
                              Expanded(
                                flex: 6,
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(scaleW(32)),
                                      topRight: Radius.circular(scaleW(32)),
                                    ),
                                  ),
                                  child: SingleChildScrollView(
                                    physics: const ClampingScrollPhysics(),
                                    padding: EdgeInsets.fromLTRB(
                                      scaleW(24),
                                      scaleH(24),
                                      scaleW(24),
                                      scaleH(16),
                                    ),
                                    child: _buildOrderDetail(
                                      context,
                                      state.order,
                                      isUpdating,
                                      scaleW,
                                      scaleH,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return Container(
                      color: AppColors.blue600,
                      child: const SizedBox.shrink(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    double Function(double) scaleW,
    double Function(double) scaleH,
  ) {
    return Expanded(
      flex: 1,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: scaleW(24)),
        child: Row(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () => context.pop(true),
                icon: Icon(
                  Icons.arrow_back,
                  color: AppColors.blue600,
                  size: scaleW(24),
                ),
              ),
            ),
            SizedBox(width: scaleW(12)),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Detalle del Pedido',
                    style: TextStyle(
                      fontSize: scaleW(26),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                  SizedBox(height: scaleH(4)),
                  Text(
                    'Visualiza toda la información del pedido',
                    style: TextStyle(
                      fontSize: scaleW(14),
                      color: Colors.white70,
                      fontWeight: FontWeight.w300,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            SizedBox(width: scaleW(48)), // Espacio para balancear el diseño
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetail(
    BuildContext context,
    OrderDetailEntity order,
    ValueNotifier<bool> isUpdating,
    double Function(double) scaleW,
    double Function(double) scaleH,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSummary(order, scaleW, scaleH),
        SizedBox(height: scaleH(20)),
        _buildAssignment(
          order.employeeName,
          order.isTaken,
          context,
          order.id,
          scaleW,
          scaleH,
        ),
        SizedBox(height: scaleH(20)),
        _buildProgress(order.status, scaleW, scaleH),
        SizedBox(height: scaleH(20)),
        _buildStatusDropdown(context, order, scaleW, scaleH),
        SizedBox(height: scaleH(20)),
        _buildProducts(
          order.items,
          order.totalAmount,
          order.subtotalAmount,
          order.shippingCost,
          scaleW,
          scaleH,
        ),
      ],
    );
  }

  Widget _buildAssignment(
    String? employeeName,
    bool isTaken,
    BuildContext context,
    String orderId,
    double Function(double) scaleW,
    double Function(double) scaleH,
  ) {
    final assigned = (employeeName ?? '').isNotEmpty;

    return Container(
      padding: EdgeInsets.all(scaleW(20)),
      decoration: _cardDecoration(scaleW),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Asignación del Pedido',
              style: TextStyle(
                fontSize: scaleW(18),
                fontWeight: FontWeight.bold,
                color: AppColors.gray800,
              ),
            ),
          ),
          SizedBox(height: scaleH(16)),
          CircleAvatar(
            radius: scaleW(28),
            backgroundColor: AppColors.purple100,
            child: Icon(
              Icons.person,
              color: AppColors.purple600,
              size: scaleW(32),
            ),
          ),
          SizedBox(height: scaleH(12)),
          Text(
            assigned
                ? 'Asignado a: $employeeName'
                : 'Este pedido no está asignado a ningún empleado',
            style: TextStyle(color: AppColors.gray700, fontSize: scaleW(15)),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: scaleH(16)),
          if (!isTaken)
            ElevatedButton.icon(
              onPressed: () {
                _takeOrder(context, orderId, scaleW, scaleH);
              },
              icon: Icon(Icons.assignment_turned_in, size: scaleW(20)),
              label: Text(
                'Tomar pedido',
                style: TextStyle(fontSize: scaleW(15)),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue600,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: scaleW(24),
                  vertical: scaleH(12),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(scaleW(12)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Método separado para tomar pedido
  void _takeOrder(
    BuildContext context,
    String orderId,
    double Function(double) scaleW,
    double Function(double) scaleH,
  ) {
    final authState = context.read<AuthBloc>().state;
    final employeeId = (authState is AuthAuthenticated)
        ? int.tryParse(authState.user.id.toString()) ?? 0
        : 0;

    context.read<OrdersBloc>().add(TakeOrderEvent(orderId, employeeId));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pedido tomado correctamente'),
            backgroundColor: AppColors.green600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  Widget _buildStatusDropdown(
    BuildContext context,
    OrderDetailEntity order,
    double Function(double) scaleW,
    double Function(double) scaleH,
  ) {
    final allStatuses = [
      'PENDING',
      'PROCESSING',
      'PACKED',
      'SHIPPED',
      'DELIVERED',
      'CANCELLED',
    ];

    final labels = {
      'PENDING': 'Pendiente',
      'PROCESSING': 'Procesando',
      'PACKED': 'Empacado',
      'SHIPPED': 'Enviado',
      'DELIVERED': 'Entregado',
      'CANCELLED': 'Cancelado',
    };

    final shippingCompanies = [
      'DHL',
      'FedEx',
      'UPS',
      'Estafeta',
      'Paquetexpress',
      'Redpack',
      'Correos de México',
    ];

    String selectedStatus = order.status;
    final dateFormatter = DateFormat('dd/MM/yyyy', 'es_MX');

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          padding: EdgeInsets.all(scaleW(20)),
          decoration: _cardDecoration(scaleW),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cambiar Estado',
                style: TextStyle(
                  fontSize: scaleW(18),
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray900,
                ),
              ),
              SizedBox(height: scaleH(12)),
              DropdownButtonFormField<String>(
                initialValue: selectedStatus,
                isExpanded: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(scaleW(8)),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: scaleW(16),
                    vertical: scaleH(12),
                  ),
                ),
                dropdownColor: Colors.white,
                style: TextStyle(
                  fontSize: scaleW(15),
                  color: AppColors.gray900,
                ),
                items: allStatuses
                    .map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text(
                          labels[s] ?? s,
                          style: TextStyle(
                            fontSize: scaleW(15),
                            color: AppColors.gray900,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null || value == order.status) return;

                  // Para el estado SHIPPED, mostramos el diálogo primero
                  if (value == 'SHIPPED') {
                    _handleShippedStatus(
                      context,
                      order,
                      value,
                      labels[value] ?? value,
                      shippingCompanies,
                      dateFormatter,
                      setState,
                      scaleW,
                      scaleH,
                    );
                  } else {
                    // Para otros estados, actualizamos inmediatamente
                    setState(() => selectedStatus = value);
                    context.read<OrdersBloc>().add(
                      UpdateStatusEvent(order.id, value),
                    );
                    _showStatusUpdateSnackbar(context, labels[value] ?? value);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Manejar estado SHIPPED sin async gap
  void _handleShippedStatus(
    BuildContext context,
    OrderDetailEntity order,
    String newStatus,
    String statusLabel,
    List<String> shippingCompanies,
    DateFormat dateFormatter,
    StateSetter setState,
    double Function(double) scaleW,
    double Function(double) scaleH,
  ) {
    _showShippingInfoDialog(
      context,
      order,
      newStatus,
      statusLabel,
      shippingCompanies,
      dateFormatter,
      setState,
      scaleW,
      scaleH,
    );
  }

  // Mostrar diálogo de información de envío sin async
  void _showShippingInfoDialog(
    BuildContext context,
    OrderDetailEntity order,
    String newStatus,
    String statusLabel,
    List<String> shippingCompanies,
    DateFormat dateFormatter,
    StateSetter setState,
    double Function(double) scaleW,
    double Function(double) scaleH,
  ) {
    String? trackingNumber;
    String? shippingCompany;

    showDialog(
      context: context,
      builder: (ctx) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            textTheme: Theme.of(ctx).textTheme.apply(
              bodyColor: AppColors.gray900,
              displayColor: AppColors.gray900,
            ),
          ),
          child: AlertDialog(
            title: Text(
              'Información de envío',
              style: TextStyle(fontSize: scaleW(18), color: AppColors.gray900),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Número de rastreo',
                    labelStyle: TextStyle(
                      fontSize: scaleW(14),
                      color: AppColors.gray700,
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.blue600),
                    ),
                  ),
                  style: TextStyle(
                    fontSize: scaleW(14),
                    color: AppColors.gray900,
                  ),
                  onChanged: (v) => trackingNumber = v,
                ),
                SizedBox(height: scaleH(12)),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Empresa de envío',
                    labelStyle: TextStyle(
                      fontSize: scaleW(14),
                      color: AppColors.gray700,
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.blue600),
                    ),
                  ),
                  dropdownColor: Colors.white,
                  style: TextStyle(
                    fontSize: scaleW(14),
                    color: AppColors.gray900,
                  ),
                  items: shippingCompanies
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(
                            e,
                            style: TextStyle(color: AppColors.gray900),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => shippingCompany = v,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx); // Solo cierra el diálogo
                },
                child: Text(
                  'Cancelar',
                  style: TextStyle(
                    fontSize: scaleW(14),
                    color: AppColors.gray600,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if ((trackingNumber ?? '').isEmpty ||
                      (shippingCompany ?? '').isEmpty) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Por favor ingrese número de rastreo y seleccione la empresa.',
                        ),
                        backgroundColor: AppColors.red500,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }

                  // Realizar la actualización del estado
                  final bloc = context.read<OrdersBloc>();
                  bloc.add(UpdateStatusEvent(order.id, newStatus));

                  // Preparar y enviar el correo de tracking
                  String formatCurrency(double v) =>
                      '\$${v.toStringAsFixed(2)} MXN';

                  final productsData = order.items.map((item) {
                    return {
                      'name': item.productName,
                      'color': item.color,
                      'size': item.size,
                      'quantity': item.quantity,
                      'unitPrice': item.unitPrice,
                      'totalPrice': item.total,
                      'unitPriceFormatted': formatCurrency(item.unitPrice),
                      'totalPriceFormatted': formatCurrency(item.total),
                    };
                  }).toList();

                  final emailData = {
                    'orderId': int.parse(order.id),
                    'saleReference': order.saleReference ?? order.id,
                    'customerEmail': order.customerEmail ?? '',
                    'customerName': order.userName,
                    'customerPhone': order.customerPhone ?? 'No proporcionado',
                    'trackingNumber': trackingNumber!,
                    'shippingCompany': shippingCompany!,
                    'subtotalAmount': order.subtotalAmount,
                    'shippingCost': order.shippingCost,
                    'totalAmount': order.totalAmount,
                    'subtotalFormatted': formatCurrency(order.subtotalAmount),
                    'shippingCostFormatted': formatCurrency(order.shippingCost),
                    'totalAmountFormatted': formatCurrency(order.totalAmount),
                    'products': productsData,
                    'totalItems': order.items.fold<int>(
                      0,
                      (sum, item) => sum + item.quantity,
                    ),
                    'totalProducts': order.items.length,
                    'orderDate': order.createdAt != null
                        ? dateFormatter.format(order.createdAt!)
                        : dateFormatter.format(DateTime.now()),
                    'shippedDate': dateFormatter.format(DateTime.now()),
                  };

                  bloc.add(SendTrackingEmailEvent(emailData));

                  Navigator.pop(ctx);

                  // Actualizar estado local y mostrar snackbar
                  setState(() {});
                  _showStatusUpdateSnackbar(context, statusLabel);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue600,
                ),
                child: Text(
                  'Confirmar',
                  style: TextStyle(fontSize: scaleW(14), color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Método separado para mostrar el Snackbar de actualización
  void _showStatusUpdateSnackbar(BuildContext context, String statusLabel) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Estado cambiado a $statusLabel'),
            backgroundColor: AppColors.green600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  Widget _buildProgress(
    String status,
    double Function(double) scaleW,
    double Function(double) scaleH,
  ) {
    final statuses = ['PROCESSING', 'PACKED', 'SHIPPED', 'DELIVERED'];
    final index = statuses.indexOf(status);
    final progress = (index + 1) / statuses.length;

    final labels = {
      'PROCESSING': 'Procesando',
      'PACKED': 'Empacado',
      'SHIPPED': 'Enviado',
      'DELIVERED': 'Entregado',
    };

    return Container(
      padding: EdgeInsets.all(scaleW(20)),
      decoration: _cardDecoration(scaleW),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progreso del Pedido',
            style: TextStyle(
              fontSize: scaleW(18),
              fontWeight: FontWeight.bold,
              color: AppColors.gray900,
            ),
          ),
          SizedBox(height: scaleH(12)),
          LinearProgressIndicator(
            value: progress,
            minHeight: scaleH(8),
            borderRadius: BorderRadius.circular(scaleW(8)),
            backgroundColor: AppColors.gray200,
            color: AppColors.blue600,
          ),
          SizedBox(height: scaleH(12)),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: statuses
                  .map(
                    (s) => Container(
                      margin: EdgeInsets.only(right: scaleW(16)),
                      child: Text(
                        labels[s]!,
                        style: TextStyle(
                          fontSize: scaleW(12),
                          color: s == status
                              ? AppColors.blue600
                              : AppColors.gray500,
                          fontWeight: s == status
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(
    OrderDetailEntity order,
    double Function(double) scaleW,
    double Function(double) scaleH,
  ) {
    final statusLabels = {
      'PENDING': 'Pendiente',
      'PROCESSING': 'Procesando',
      'PACKED': 'Empacado',
      'SHIPPED': 'Enviado',
      'DELIVERED': 'Entregado',
      'CANCELLED': 'Cancelado',
    };

    return Container(
      padding: EdgeInsets.all(scaleW(20)),
      decoration: _cardDecoration(scaleW),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Pedido #${order.id}',
                  style: TextStyle(
                    fontSize: scaleW(18),
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray900,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: scaleW(12),
                  vertical: scaleH(4),
                ),
                decoration: BoxDecoration(
                  color: AppColors.amber50,
                  borderRadius: BorderRadius.circular(scaleW(12)),
                  border: Border.all(color: AppColors.amber100),
                ),
                child: Text(
                  statusLabels[order.status] ?? order.status,
                  style: TextStyle(
                    color: AppColors.amber600,
                    fontWeight: FontWeight.w600,
                    fontSize: scaleW(13),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: scaleH(10)),
          Text(
            'Cliente: ${order.userName}',
            style: TextStyle(
              color: AppColors.gray800,
              fontSize: scaleW(15),
              fontWeight: FontWeight.w600,
            ),
          ),
          if (order.address != null && order.address!.isNotEmpty) ...[
            SizedBox(height: scaleH(6)),
            Text(
              order.address!,
              style: TextStyle(color: AppColors.gray600, fontSize: scaleW(14)),
            ),
          ],
          Divider(height: scaleH(28)),
          _buildAmountRow('Subtotal', order.subtotalAmount, scaleW),
          _buildAmountRow('Envío', order.shippingCost, scaleW),
          Divider(height: scaleH(24)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total:',
                style: TextStyle(
                  fontSize: scaleW(18),
                  fontWeight: FontWeight.bold,
                  color: AppColors.blue600,
                ),
              ),
              Text(
                '\$${order.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: scaleW(20),
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

  Widget _buildProducts(
    List<OrderItem> items,
    double total,
    double subtotal,
    double shipping,
    double Function(double) scaleW,
    double Function(double) scaleH,
  ) {
    return Container(
      padding: EdgeInsets.all(scaleW(20)),
      decoration: _cardDecoration(scaleW),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Productos del Pedido',
            style: TextStyle(
              fontSize: scaleW(18),
              fontWeight: FontWeight.bold,
              color: AppColors.gray800,
            ),
          ),
          SizedBox(height: scaleH(16)),
          for (final item in items) _buildProductItem(item, scaleW, scaleH),
          Divider(height: scaleH(24), color: AppColors.gray200),
          _buildAmountRow('Subtotal', subtotal, scaleW),
          _buildAmountRow('Envío', shipping, scaleW),
          Divider(height: scaleH(20)),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Total: \$${total.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: scaleW(20),
                fontWeight: FontWeight.bold,
                color: AppColors.blue600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow(
    String label,
    double amount,
    double Function(double) scaleW,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: scaleW(4)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: AppColors.gray700, fontSize: scaleW(15)),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: AppColors.gray800,
              fontWeight: FontWeight.w500,
              fontSize: scaleW(15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(
    OrderItem item,
    double Function(double) scaleW,
    double Function(double) scaleH,
  ) {
    final validImage =
        item.image != null &&
        (item.image!.startsWith('http') || item.image!.startsWith('https'));

    return Padding(
      padding: EdgeInsets.only(bottom: scaleH(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(scaleW(8)),
            child: validImage
                ? Image.network(
                    item.image!,
                    width: scaleW(60),
                    height: scaleW(60),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholderImage(scaleW),
                  )
                : _placeholderImage(scaleW),
          ),
          SizedBox(width: scaleW(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray800,
                    fontSize: scaleW(15),
                  ),
                ),
                SizedBox(height: scaleH(4)),
                Text(
                  'Cantidad: ${item.quantity} • Talla: ${item.size} • Color: ${item.color}',
                  style: TextStyle(
                    color: AppColors.gray600,
                    fontSize: scaleW(13),
                  ),
                ),
                SizedBox(height: scaleH(2)),
                Text(
                  '\$${item.unitPrice.toStringAsFixed(2)} c/u',
                  style: TextStyle(
                    color: AppColors.gray500,
                    fontSize: scaleW(13),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: scaleW(6)),
          Text(
            '\$${item.total.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.gray800,
              fontSize: scaleW(15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderImage(double Function(double) scaleW) => Container(
    width: scaleW(60),
    height: scaleW(60),
    color: AppColors.gray100,
    child: Icon(Icons.image, color: AppColors.gray400, size: scaleW(24)),
  );

  BoxDecoration _cardDecoration(double Function(double) scaleW) =>
      BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(scaleW(16)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      );
}
