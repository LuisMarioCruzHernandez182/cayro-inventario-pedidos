import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    double scaleW(double v) => v * (width / 390);
    double scaleH(double v) => v * (height / 844);

    return BlocProvider(
      create: (_) => _ordersBloc,
      child: Scaffold(
        backgroundColor: AppColors.blue600,
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
                            padding: EdgeInsets.fromLTRB(
                              scaleW(20),
                              scaleH(20),
                              scaleW(20),
                              scaleH(16),
                            ),
                            child: _buildSearchBar(scaleW, scaleH),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: scaleW(20),
                            ),
                            child: BlocBuilder<OrdersBloc, OrdersState>(
                              buildWhen: (p, c) => c is OrdersMetricsLoaded,
                              builder: (context, state) {
                                if (state is OrdersMetricsLoaded) {
                                  return _buildMetricsSection(
                                    state,
                                    scaleW,
                                    scaleH,
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                        ),
                        BlocBuilder<OrdersBloc, OrdersState>(
                          buildWhen: (p, c) =>
                              c is OrdersLoaded ||
                              c is OrdersLoading ||
                              c is OrdersError,
                          builder: (context, state) {
                            if (state is OrdersLoading) {
                              return SliverFillRemaining(
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
                                        "Cargando pedidos...",
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
                              return SliverFillRemaining(
                                child: Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(scaleW(20)),
                                    child: Text(
                                      state.message,
                                      style: TextStyle(
                                        color: AppColors.red500,
                                        fontSize: scaleW(16),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              );
                            } else if (state is OrdersLoaded) {
                              if (state.orders.isEmpty) {
                                return SliverFillRemaining(
                                  child: _buildEmptyState(scaleW, scaleH),
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
                                      employee: o.employeeName ?? 'Sin asignar',
                                      color: color.$1,
                                      backgroundColor: color.$2,
                                      scaleW: scaleW,
                                      scaleH: scaleH,
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
                      ],
                    ),
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
            'Pedidos Pendientes',
            style: TextStyle(
              color: Colors.white,
              fontSize: scaleW(26),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: scaleH(8)),
          Text(
            'Gestiona los pedidos nuevos que aún no han sido tomados',
            style: TextStyle(
              color: Colors.white,
              fontSize: scaleW(14),
              fontWeight: FontWeight.w300,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsSection(
    OrdersMetricsLoaded state,
    double Function(double) scaleW,
    double Function(double) scaleH,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Pendientes',
            value: '${state.statusCount['PENDING'] ?? 0}',
            subtitle: 'Esperando asignación',
            color: AppColors.amber600,
            backgroundColor: AppColors.amber50,
            icon: Icons.access_time,
            scaleW: scaleW,
            scaleH: scaleH,
          ),
        ),
        SizedBox(width: scaleW(12)),
        Expanded(
          child: _buildStatCard(
            title: 'En Proceso',
            value: '${state.statusCount['PROCESSING'] ?? 0}',
            subtitle: 'Tomados por empleados',
            color: AppColors.blue600,
            backgroundColor: AppColors.blue50,
            icon: Icons.work_outline,
            scaleW: scaleW,
            scaleH: scaleH,
          ),
        ),
      ],
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
                hintText: 'Buscar pedidos o clientes...',
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
                        onPressed: _onClearFilters,
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

  Widget _buildEmptyState(
    double Function(double) scaleW,
    double Function(double) scaleH,
  ) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: scaleW(24),
          vertical: scaleH(60),
        ),
        child: Center(
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
                  _hasFilters
                      ? 'No se encontraron pedidos con los filtros aplicados.'
                      : 'No hay pedidos pendientes por el momento.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: scaleW(18),
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray800,
                  ),
                ),
                SizedBox(height: scaleH(8)),
                Text(
                  _hasFilters
                      ? 'Ajusta o limpia los filtros para ver más resultados.'
                      : 'Cuando existan pedidos pendientes, aparecerán aquí para su gestión.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: scaleW(14),
                    color: AppColors.gray500,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: scaleH(20)),
                if (_hasFilters)
                  ElevatedButton.icon(
                    onPressed: _onClearFilters,
                    icon: Icon(Icons.filter_alt_off_rounded, size: scaleW(18)),
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
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required Color backgroundColor,
    required IconData icon,
    required double Function(double) scaleW,
    required double Function(double) scaleH,
  }) {
    return Container(
      padding: EdgeInsets.all(scaleW(16)),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(scaleW(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: scaleW(20)),
              SizedBox(width: scaleW(8)),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: scaleW(12),
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: scaleW(8)),
          Text(
            value,
            style: TextStyle(
              fontSize: scaleW(22),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: scaleW(4)),
          Text(
            subtitle,
            style: TextStyle(fontSize: scaleW(11), fontWeight: FontWeight.w500),
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
    required double Function(double) scaleW,
    required double Function(double) scaleH,
  }) {
    final statusLabel =
        {
          'PENDING': 'Pendiente',
          'PROCESSING': 'Procesando',
          'PACKED': 'Empacado',
          'SHIPPED': 'Enviado',
          'DELIVERED': 'Entregado',
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$date • $productsCount productos',
                      style: TextStyle(
                        color: AppColors.gray500,
                        fontSize: scaleW(12),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: scaleH(4)),
                    Text(
                      'Asignado a: $employee',
                      style: TextStyle(
                        color: AppColors.gray600,
                        fontSize: scaleW(12),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
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
                final updated = await context.push('/order-detail/$id');
                if (updated == true && context.mounted) {
                  _ordersBloc.add(
                    LoadOrdersEvent(
                      search: _currentSearch,
                      page: _currentPage,
                      status: 'PENDING',
                    ),
                  );
                  _ordersBloc.add(const LoadMetricsEvent());
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
      case 'PENDING':
        return (AppColors.amber600, AppColors.amber50);
      case 'PROCESSING':
        return (AppColors.blue600, AppColors.blue50);
      case 'PACKED':
        return (AppColors.blue600, AppColors.blue100);
      case 'SHIPPED':
        return (AppColors.purple600, AppColors.purple100);
      case 'DELIVERED':
        return (AppColors.green600, AppColors.green50);
      default:
        return (AppColors.gray700, AppColors.gray100);
    }
  }
}
