import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:stock_control_app/features/orders/presentation/pages/widgets/pagination_controls.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../app/di/injection_container.dart';
import '../bloc/orders_bloc.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  int _currentPage = 1;
  String? _currentSearch;
  bool _hasFilters = false;

  late OrdersBloc _ordersBloc;

  @override
  void initState() {
    super.initState();
    _ordersBloc = sl<OrdersBloc>()
      ..add(LoadOrdersEvent(search: null, page: 1, status: 'PENDING'))
      ..add(const LoadMetricsEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _ordersBloc.close();
    super.dispose();
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onSearch() {
    setState(() {
      _currentSearch = _searchController.text.trim();
      _currentPage = 1;
      _hasFilters = _currentSearch != null && _currentSearch!.isNotEmpty;
    });
    _ordersBloc.add(
      LoadOrdersEvent(
        search: _currentSearch,
        page: _currentPage,
        status: 'PENDING',
      ),
    );
    _scrollToTop();
  }

  void _onClearFilters() {
    _searchController.clear();
    setState(() {
      _currentSearch = null;
      _currentPage = 1;
      _hasFilters = false;
    });
    _ordersBloc.add(LoadOrdersEvent(search: null, page: 1, status: 'PENDING'));
    _scrollToTop();
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    _ordersBloc.add(
      LoadOrdersEvent(search: _currentSearch, page: page, status: 'PENDING'),
    );
    _scrollToTop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _ordersBloc,
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
                    child: RefreshIndicator(
                      onRefresh: () async {
                        _ordersBloc.add(const LoadMetricsEvent());
                        _ordersBloc.add(
                          LoadOrdersEvent(
                            search: _currentSearch,
                            page: 1,
                            status: 'PENDING',
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
                                16,
                              ),
                              child: _buildSearchBar(),
                            ),
                          ),

                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: BlocBuilder<OrdersBloc, OrdersState>(
                                buildWhen: (p, c) => c is OrdersMetricsLoaded,
                                builder: (context, state) {
                                  if (state is OrdersMetricsLoaded) {
                                    return _buildMetricsSection(state);
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                          ),

                          // 📦 Lista de pedidos
                          BlocBuilder<OrdersBloc, OrdersState>(
                            buildWhen: (p, c) =>
                                c is OrdersLoaded ||
                                c is OrdersLoading ||
                                c is OrdersError,
                            builder: (context, state) {
                              if (state is OrdersLoading) {
                                return const SliverFillRemaining(
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              } else if (state is OrdersError) {
                                return SliverFillRemaining(
                                  child: Center(
                                    child: Text(
                                      state.message,
                                      style: TextStyle(
                                        color: AppColors.red500,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                );
                              } else if (state is OrdersLoaded) {
                                if (state.orders.isEmpty) {
                                  return SliverFillRemaining(
                                    child: _buildEmptyState(),
                                  );
                                }
                                return SliverList(
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
                                        employee:
                                            o.employeeName ?? 'Sin asignar',
                                        color: color.$1,
                                        backgroundColor: color.$2,
                                      ),
                                    );
                                  }, childCount: state.orders.length),
                                );
                              }
                              return const SliverFillRemaining(
                                child: SizedBox.shrink(),
                              );
                            },
                          ),

                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                24,
                                20,
                                40,
                              ),
                              child: BlocBuilder<OrdersBloc, OrdersState>(
                                buildWhen: (p, c) => c is OrdersLoaded,
                                builder: (context, s) {
                                  if (s is OrdersLoaded) {
                                    return OrdersPaginationControls(
                                      currentPage: _currentPage,
                                      totalPages: s.totalPages,
                                      isLoading: s is OrdersLoading,
                                      onPageChanged: _onPageChanged,
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          const Text(
            'Pedidos Pendientes',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Gestiona los pedidos nuevos que aún no han sido tomados',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 16,
              fontWeight: FontWeight.w300,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsSection(OrdersMetricsLoaded state) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Pedidos Pendientes',
            value: '${state.statusCount['PENDING'] ?? 0}',
            subtitle: 'Esperando asignación',
            color: AppColors.amber600,
            backgroundColor: AppColors.amber50,
            icon: Icons.access_time,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Pedidos en Proceso',
            value: '${state.statusCount['PROCESSING'] ?? 0}',
            subtitle: 'Tomados por empleados',
            color: AppColors.blue500,
            backgroundColor: AppColors.blue50,
            icon: Icons.work_outline,
          ),
        ),
      ],
    );
  }

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
                hintText: 'Buscar pedidos o clientes...',
                hintStyle: TextStyle(color: AppColors.gray500, fontSize: 14),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.gray500,
                  size: 20,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: _onClearFilters,
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

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                color: AppColors.blue50,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blue400.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 70,
                color: AppColors.blue600,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _hasFilters
                  ? 'No se encontraron pedidos con los filtros aplicados.'
                  : 'No se encontraron pedidos pendientes.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.gray800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _hasFilters
                  ? 'Puedes limpiar los filtros para volver a ver todos los pedidos pendientes.'
                  : 'Agrega pedidos o verifica la conexión al servidor.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.gray600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            if (_hasFilters)
              ElevatedButton.icon(
                onPressed: _onClearFilters,
                icon: const Icon(
                  Icons.filter_alt_off_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                label: const Text(
                  'Limpiar filtros',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue600,
                  elevation: 8,
                  shadowColor: AppColors.blue400.withValues(alpha: 0.4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required Color backgroundColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: color.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
    required String employee,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$date • $productsCount productos',
                    style: const TextStyle(
                      color: AppColors.gray500,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Asignado a: $employee',
                    style: const TextStyle(
                      color: AppColors.gray600,
                      fontSize: 12,
                    ),
                  ),
                ],
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
              onPressed: () => context.push('/order-detail/$id'),
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

  (Color, Color) _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return (AppColors.amber500, AppColors.amber50);
      default:
        return (AppColors.gray700, AppColors.gray100);
    }
  }
}
