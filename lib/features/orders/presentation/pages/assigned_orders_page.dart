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

  // 🔹 Buscar
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

  // 🔹 Limpiar búsqueda
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

  // 🔹 Filtrar por estado
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

  // 🔹 Limpiar todos los filtros
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

  // 🔹 Cambiar página
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
    if (!mounted || _employeeId == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return BlocProvider.value(
      value: _ordersBloc,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.blue600, AppColors.blue500, AppColors.blue400],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: _employeeId == null
                        ? _buildNoSessionState()
                        : BlocBuilder<OrdersBloc, OrdersState>(
                            builder: (context, state) {
                              if (state is OrdersLoading) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else if (state is OrdersError) {
                                return _buildErrorState(state.message);
                              } else if (state is OrdersLoaded) {
                                if (state.orders.isEmpty) {
                                  final hasFilters =
                                      _currentSearch != null ||
                                      _filterStatus != null;
                                  return _buildEmptyState(hasFilters);
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
                                          padding: const EdgeInsets.fromLTRB(
                                            20,
                                            20,
                                            20,
                                            12,
                                          ),
                                          child: _buildSearchBar(),
                                        ),
                                      ),
                                      SliverToBoxAdapter(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                          ),
                                          child: _buildStatusFilters(),
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
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 6,
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
                                            ),
                                          );
                                        }, childCount: state.orders.length),
                                      ),
                                      SliverToBoxAdapter(
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                            20,
                                            24,
                                            20,
                                            40,
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
      ),
    );
  }

  // 🔹 Header
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          const Text(
            'Mis Pedidos',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pedidos asignados a ti',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 16,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Sin sesión
  Widget _buildNoSessionState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Icon(Icons.lock_outline, size: 64, color: AppColors.gray500),
      ),
    );
  }

  // 🔹 SearchBar
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(12),
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
                hintStyle: const TextStyle(
                  color: AppColors.gray500,
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.gray500,
                  size: 20,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: _onClearSearch,
                        icon: const Icon(
                          Icons.clear,
                          color: AppColors.gray500,
                          size: 20,
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 4),
            child: Material(
              color: AppColors.blue500,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: _onSearch,
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Icon(Icons.search, color: Colors.white, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Filtros por estado
  Widget _buildStatusFilters() {
    final statuses = {
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
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isActive ? color : bg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      entry.value,
                      color: isActive ? Colors.white : color,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isActive ? Colors.white : color,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          // 🔹 Botón "Limpiar filtros"
          if (_filterStatus != null || _currentSearch != null)
            GestureDetector(
              onTap: _onClearFilters,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.gray300),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.filter_alt_off,
                      color: AppColors.gray600,
                      size: 18,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Limpiar filtros',
                      style: TextStyle(
                        color: AppColors.gray700,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
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

  // 🔹 Estado vacío con botón "Limpiar filtros"
  Widget _buildEmptyState(bool hasFilters) {
    return RefreshIndicator(
      onRefresh: () async => _onClearFilters(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.receipt_long_outlined,
                size: 70,
                color: AppColors.blue600,
              ),
              const SizedBox(height: 20),
              Text(
                hasFilters
                    ? 'No se encontraron pedidos con los filtros aplicados.'
                    : 'No tienes pedidos activos asignados.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray800,
                ),
              ),
              const SizedBox(height: 12),
              if (hasFilters)
                ElevatedButton.icon(
                  onPressed: _onClearFilters,
                  icon: const Icon(Icons.filter_alt_off, size: 18),
                  label: const Text('Limpiar filtros'),
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
        ),
      ),
    );
  }

  // 🔹 Tarjeta de pedido
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
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                saleReference,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.gray900,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            customer,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.gray700,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$date • $productsCount productos',
                style: const TextStyle(color: AppColors.gray500, fontSize: 12),
              ),
              Text(
                total,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.blue600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => context.push('/main/order-detail/$id'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.blue600,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              child: const Text('Ver detalles'),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Colores de estado
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

  // 🔹 Estado de error con botón limpiar filtros
  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.red500),
            const SizedBox(height: 16),
            const Text(
              'Error cargando pedidos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.red600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.gray600),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _onClearFilters,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Limpiar filtros y reintentar'),
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
      ),
    );
  }
}
