import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../app/di/injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/orders_bloc.dart';
import '../pages/widgets/pagination_controls.dart';

class AssignedOrdersPage extends StatefulWidget {
  const AssignedOrdersPage({super.key});

  @override
  State<AssignedOrdersPage> createState() => _AssignedOrdersPageState();
}

class _AssignedOrdersPageState extends State<AssignedOrdersPage> {
  late OrdersBloc _ordersBloc;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  int _currentPage = 1;
  String? _currentSearch;
  String? _filterStatus;
  int? _employeeId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        _employeeId = int.tryParse(authState.user.id.toString());
        debugPrint('✅ Empleado autenticado con ID: $_employeeId');

        _ordersBloc = sl<OrdersBloc>()
          ..add(
            LoadAssignedOrdersEvent(
              employeeId: _employeeId!,
              search: null,
              page: 1,
              status: null,
            ),
          );
      } else {
        debugPrint('⚠️ No hay sesión activa en AuthBloc');
        _ordersBloc = sl<OrdersBloc>();
      }
      setState(() {});
    });
  }

  void _onSearch() {
    if (_employeeId == null) return;
    setState(() {
      _currentSearch = _searchController.text.trim();
      _currentPage = 1;
    });
    _ordersBloc.add(
      LoadAssignedOrdersEvent(
        employeeId: _employeeId!,
        search: _currentSearch,
        page: _currentPage,
        status: _filterStatus,
      ),
    );
  }

  void _onClearSearch() {
    if (_employeeId == null) return;
    _searchController.clear();
    setState(() {
      _currentSearch = null;
      _currentPage = 1;
    });
    _ordersBloc.add(
      LoadAssignedOrdersEvent(
        employeeId: _employeeId!,
        search: null,
        page: _currentPage,
        status: _filterStatus,
      ),
    );
  }

  void _onFilter(String? status) {
    if (_employeeId == null) return;
    setState(() {
      _filterStatus = status;
      _currentPage = 1;
    });
    _ordersBloc.add(
      LoadAssignedOrdersEvent(
        employeeId: _employeeId!,
        search: _currentSearch,
        page: _currentPage,
        status: status,
      ),
    );
  }

  void _onClearFilters() {
    if (_employeeId == null) return;
    _searchController.clear();
    setState(() {
      _currentSearch = null;
      _filterStatus = null;
      _currentPage = 1;
    });
    _ordersBloc.add(
      LoadAssignedOrdersEvent(
        employeeId: _employeeId!,
        search: null,
        page: 1,
        status: null,
      ),
    );
  }

  void _onPageChanged(int page) {
    if (_employeeId == null) return;
    setState(() => _currentPage = page);
    _ordersBloc.add(
      LoadAssignedOrdersEvent(
        employeeId: _employeeId!,
        search: _currentSearch,
        page: page,
        status: _filterStatus,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    // Funciones de escalado responsivo
    double scaleW(double value) => value * (width / 390);
    double scaleH(double value) => value * (height / 844);

    if (!mounted || _employeeId == null) {
      return Scaffold(
        backgroundColor: AppColors.blue600, // Fondo azul sólido
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return BlocProvider.value(
      value: _ordersBloc,
      child: Scaffold(
        backgroundColor: AppColors.blue600, // Fondo azul sólido
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(scaleW, scaleH),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(scaleW(32)),
                      topRight: Radius.circular(scaleW(32)),
                    ),
                  ),
                  child: _employeeId == null
                      ? _buildNoSessionState(scaleW, scaleH)
                      : BlocBuilder<OrdersBloc, OrdersState>(
                          builder: (context, state) {
                            if (state is OrdersLoading) {
                              return Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(
                                      color: AppColors.blue600,
                                      strokeWidth: scaleW(3),
                                    ),
                                    SizedBox(height: scaleH(16)),
                                    Text(
                                      "Cargando pedidos...",
                                      style: TextStyle(
                                        color: AppColors.blue600,
                                        fontSize: scaleW(16),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            } else if (state is OrdersError) {
                              return _buildErrorState(
                                state.message,
                                scaleW,
                                scaleH,
                              );
                            } else if (state is OrdersLoaded) {
                              if (state.orders.isEmpty) {
                                final hasFilters =
                                    _currentSearch != null ||
                                    _filterStatus != null;
                                return _buildEmptyState(
                                  hasFilters,
                                  scaleW,
                                  scaleH,
                                );
                              }

                              return RefreshIndicator(
                                onRefresh: () async {
                                  _ordersBloc.add(
                                    LoadAssignedOrdersEvent(
                                      employeeId: _employeeId!,
                                      search: _currentSearch,
                                      page: _currentPage,
                                      status: _filterStatus,
                                    ),
                                  );
                                },
                                child: CustomScrollView(
                                  controller: _scrollController,
                                  slivers: [
                                    SliverToBoxAdapter(
                                      child: Padding(
                                        padding: EdgeInsets.fromLTRB(
                                          scaleW(20),
                                          scaleH(20),
                                          scaleW(20),
                                          scaleH(12),
                                        ),
                                        child: _buildSearchBar(scaleW, scaleH),
                                      ),
                                    ),
                                    SliverToBoxAdapter(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: scaleW(20),
                                        ),
                                        child: _buildStatusFilters(
                                          scaleW,
                                          scaleH,
                                        ),
                                      ),
                                    ),
                                    SliverList(
                                      delegate: SliverChildBuilderDelegate((
                                        context,
                                        i,
                                      ) {
                                        final o = state.orders[i];
                                        final color = _statusColor(o.status);
                                        return Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: scaleW(20),
                                            vertical: scaleH(6),
                                          ),
                                          child: _buildOrderCard(
                                            context,
                                            id: o.id,
                                            saleReference: o.saleReference,
                                            customer: o.userName,
                                            total:
                                                '\$${o.totalAmount.toStringAsFixed(2)}',
                                            date: o.createdAt,
                                            status: o.status,
                                            productsCount: o.productsCount,
                                            color: color.$1,
                                            backgroundColor: color.$2,
                                            scaleW: scaleW,
                                            scaleH: scaleH,
                                          ),
                                        );
                                      }, childCount: state.orders.length),
                                    ),
                                    SliverToBoxAdapter(
                                      child: Padding(
                                        padding: EdgeInsets.fromLTRB(
                                          scaleW(20),
                                          scaleH(24),
                                          scaleW(20),
                                          scaleH(40),
                                        ),
                                        child: OrdersPaginationControls(
                                          currentPage: _currentPage,
                                          totalPages: state.totalPages,
                                          isLoading: state is OrdersLoading,
                                          onPageChanged: _onPageChanged,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
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
    );
  }

  Widget _buildHeader(
    double Function(double) scaleW,
    double Function(double) scaleH,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: scaleH(20)),
      child: Column(
        children: [
          Text(
            'Mis Pedidos',
            style: TextStyle(
              color: Colors.white,
              fontSize: scaleW(28),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: scaleH(8)),
          Text(
            'Pedidos asignados a ti',
            style: TextStyle(
              color: Colors.white,
              fontSize: scaleW(16),
              fontWeight: FontWeight.w300,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoSessionState(
    double Function(double) scaleW,
    double Function(double) scaleH,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(scaleW(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline,
              size: scaleW(64),
              color: AppColors.gray500,
            ),
            SizedBox(height: scaleH(16)),
            Text(
              'No hay sesión activa',
              style: TextStyle(
                fontSize: scaleW(16),
                color: AppColors.gray700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(
    double Function(double) scaleW,
    double Function(double) scaleH,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(scaleW(12)),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onSubmitted: (_) => _onSearch(),
              decoration: InputDecoration(
                hintText: 'Buscar pedidos, clientes o estados...',
                hintStyle: TextStyle(
                  color: AppColors.gray500,
                  fontSize: scaleW(14),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.gray500,
                  size: scaleW(20),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: _onClearSearch,
                        icon: Icon(
                          Icons.clear,
                          color: AppColors.gray500,
                          size: scaleW(20),
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: scaleW(16),
                  vertical: scaleH(12),
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: scaleW(4)),
            child: Material(
              color: AppColors.blue600,
              borderRadius: BorderRadius.circular(scaleW(8)),
              child: InkWell(
                onTap: _onSearch,
                borderRadius: BorderRadius.circular(scaleW(8)),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: scaleW(16),
                    vertical: scaleH(12),
                  ),
                  child: Icon(
                    Icons.search,
                    color: Colors.white,
                    size: scaleW(20),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilters(
    double Function(double) scaleW,
    double Function(double) scaleH,
  ) {
    final statuses = {
      'PROCESSING': 'Procesando',
      'PACKED': 'Empacado',
      'SHIPPED': 'Enviado',
      'DELIVERED': 'Entregado',
    };

    final icons = {
      'PROCESSING': Icons.timelapse_rounded,
      'PACKED': Icons.inventory_2_rounded,
      'SHIPPED': Icons.local_shipping_rounded,
      'DELIVERED': Icons.check_circle_outline,
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...statuses.entries.map((entry) {
            final (color, bg) = _statusColor(entry.key);
            final isActive = _filterStatus == entry.key;
            return GestureDetector(
              onTap: () => _onFilter(isActive ? null : entry.key),
              child: Container(
                margin: EdgeInsets.only(right: scaleW(8)),
                padding: EdgeInsets.all(scaleW(10)),
                decoration: BoxDecoration(
                  color: isActive ? color : bg,
                  borderRadius: BorderRadius.circular(scaleW(12)),
                ),
                child: Row(
                  children: [
                    Icon(
                      icons[entry.key],
                      color: isActive ? Colors.white : color,
                      size: scaleW(18),
                    ),
                    SizedBox(width: scaleW(6)),
                    Text(
                      entry.value,
                      style: TextStyle(
                        fontSize: scaleW(12),
                        fontWeight: FontWeight.w600,
                        color: isActive ? Colors.white : color,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          if (_filterStatus != null || _currentSearch != null)
            GestureDetector(
              onTap: _onClearFilters,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: scaleW(14),
                  vertical: scaleH(10),
                ),
                margin: EdgeInsets.only(left: scaleW(8)),
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(scaleW(12)),
                  border: Border.all(color: AppColors.gray300),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.filter_alt_off,
                      color: AppColors.gray600,
                      size: scaleW(18),
                    ),
                    SizedBox(width: scaleW(6)),
                    Text(
                      'Limpiar filtros',
                      style: TextStyle(
                        color: AppColors.gray700,
                        fontWeight: FontWeight.w600,
                        fontSize: scaleW(12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    bool hasFilters,
    double Function(double) scaleW,
    double Function(double) scaleH,
  ) {
    return RefreshIndicator(
      onRefresh: () async => _onClearFilters(),
      color: AppColors.blue600,
      backgroundColor: AppColors.white,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: scaleW(24)),
              child: Container(
                padding: EdgeInsets.all(scaleW(28)),
                decoration: BoxDecoration(
                  color: AppColors.blue50,
                  borderRadius: BorderRadius.circular(scaleW(20)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowColor,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(scaleW(16)),
                      decoration: BoxDecoration(
                        color: AppColors.blue100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.receipt_long_outlined,
                        size: scaleW(60),
                        color: AppColors.blue600,
                      ),
                    ),
                    SizedBox(height: scaleH(20)),
                    Text(
                      hasFilters
                          ? 'No se encontraron pedidos con los filtros aplicados.'
                          : 'No tienes pedidos activos asignados.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: scaleW(18),
                        fontWeight: FontWeight.w700,
                        color: AppColors.gray800,
                      ),
                    ),
                    SizedBox(height: scaleH(8)),
                    Text(
                      hasFilters
                          ? 'Intenta modificar los filtros o desliza hacia abajo para actualizar.'
                          : 'Cuando tengas pedidos activos, aparecerán aquí para su gestión.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: scaleW(14),
                        color: AppColors.gray500,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: scaleH(20)),
                    if (hasFilters)
                      ElevatedButton.icon(
                        onPressed: _onClearFilters,
                        icon: Icon(
                          Icons.filter_alt_off_rounded,
                          size: scaleW(18),
                        ),
                        label: Text(
                          'Limpiar filtros',
                          style: TextStyle(
                            fontSize: scaleW(15),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue600,
                          foregroundColor: Colors.white,
                          elevation: 3,
                          padding: EdgeInsets.symmetric(
                            horizontal: scaleW(28),
                            vertical: scaleH(14),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(scaleW(16)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context, {
    required String id,
    required String saleReference,
    required String customer,
    required String total,
    required String date,
    required String status,
    required int productsCount,
    required Color color,
    required Color backgroundColor,
    required double Function(double) scaleW,
    required double Function(double) scaleH,
  }) {
    // Traducción del estado
    final statusLabel =
        {
          'PROCESSING': 'Procesando',
          'PACKED': 'Empacado',
          'SHIPPED': 'Enviado',
          'DELIVERED': 'Entregado',
          'PENDING': 'Pendiente',
        }[status] ??
        status;

    return Container(
      padding: EdgeInsets.all(scaleW(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(scaleW(16)),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  saleReference,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: scaleW(16),
                    color: AppColors.gray900,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: scaleW(10),
                  vertical: scaleH(4),
                ),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(scaleW(8)),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: scaleW(12),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: scaleH(8)),
          Text(
            customer,
            style: TextStyle(
              fontSize: scaleW(15),
              color: AppColors.gray700,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: scaleH(8)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  '$date • $productsCount productos',
                  style: TextStyle(
                    color: AppColors.gray500,
                    fontSize: scaleW(12),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                total,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.blue600,
                  fontSize: scaleW(16),
                ),
              ),
            ],
          ),
          SizedBox(height: scaleH(12)),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () async {
                final updated = await context.push('/main/order-detail/$id');
                if (updated == true && context.mounted && _employeeId != null) {
                  _ordersBloc.add(
                    LoadAssignedOrdersEvent(
                      employeeId: _employeeId!,
                      search: _currentSearch,
                      page: _currentPage,
                      status: _filterStatus,
                    ),
                  );

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pedidos actualizados correctamente'),
                        backgroundColor: AppColors.green600,
                      ),
                    );
                  }
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.blue600,
                textStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: scaleW(14),
                ),
              ),
              child: const Text('Ver detalles'),
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color) _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PROCESSING':
        return (AppColors.amber500, AppColors.amber50);
      case 'PACKED':
        return (AppColors.blue500, AppColors.blue50);
      case 'SHIPPED':
        return (AppColors.purple500, AppColors.purple100);
      case 'DELIVERED':
        return (AppColors.green600, AppColors.green50);
      default:
        return (AppColors.gray700, AppColors.gray100);
    }
  }

  Widget _buildErrorState(
    String message,
    double Function(double) scaleW,
    double Function(double) scaleH,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(scaleW(24)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: scaleW(64),
              color: AppColors.red500,
            ),
            SizedBox(height: scaleH(16)),
            Text(
              'Error cargando pedidos',
              style: TextStyle(
                fontSize: scaleW(16),
                fontWeight: FontWeight.w600,
                color: AppColors.red600,
              ),
            ),
            SizedBox(height: scaleH(8)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: scaleW(14), color: AppColors.gray600),
            ),
            SizedBox(height: scaleH(16)),
            ElevatedButton.icon(
              onPressed: _onClearFilters,
              icon: Icon(Icons.refresh, size: scaleW(18)),
              label: Text(
                'Limpiar filtros y reintentar',
                style: TextStyle(fontSize: scaleW(14)),
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
      ),
    );
  }
}
