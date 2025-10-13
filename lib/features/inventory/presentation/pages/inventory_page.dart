import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:stock_control_app/features/inventory/presentation/bloc/inventory_event.dart';
import 'package:stock_control_app/features/inventory/presentation/bloc/inventory_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../app/di/injection_container.dart';
import '../bloc/inventory_bloc.dart';
import '../widgets/inventory_card.dart';
import '../widgets/compact_inventory_stats.dart';
import '../widgets/search_bar_with_button.dart';
import '../widgets/pagination_info.dart';
import '../widgets/pagination_controls.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final TextEditingController _searchController = TextEditingController();
  late InventoryBloc _inventoryBloc;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _inventoryBloc = sl<InventoryBloc>()
      ..add(const LoadInventoryWithStats(page: 1));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _inventoryBloc.close();
    super.dispose();
  }

  void _onSearch() {
    final query = _searchController.text.trim();
    _inventoryBloc.add(SearchInventoryWithButton(query: query));
  }

  void _onPageChanged(int page) {
    final currentState = _inventoryBloc.state;
    String? currentSearch;
    String? currentStockStatus;

    if (currentState is InventoryWithStatsLoaded) {
      currentSearch = currentState.currentSearch;
      currentStockStatus = currentState.currentStockStatus;
    }

    _scrollToTop();

    _inventoryBloc.add(
      NavigateToPage(
        page: page,
        search: currentSearch,
        stockStatus: currentStockStatus,
      ),
    );
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

  void _onClearSearch() {
    _searchController.clear();
    _inventoryBloc.add(const ClearSearch());
  }

  void _onClearFilters() {
    _searchController.clear();
    _inventoryBloc.add(const LoadInventoryWithStats(page: 1, search: null));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    double scaleW(double v) => v * (width / 390);
    double scaleH(double v) => v * (height / 844);

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthUnauthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.pushReplacement('/login');
          });
          return const SizedBox.shrink();
        }

        if (state is AuthLoading) {
          return _buildLoadingState(scaleW, scaleH);
        }

        return BlocProvider.value(
          value: _inventoryBloc,
          child: _buildInventoryContent(context, scaleW, scaleH),
        );
      },
    );
  }

  Widget _buildLoadingState(
    double Function(double) scaleW,
    double Function(double) scaleH,
  ) {
    return Scaffold(
      backgroundColor: AppColors.blue600,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: scaleW(3),
              ),
              SizedBox(height: scaleH(16)),
              Text(
                'Cargando inventario...',
                style: TextStyle(color: Colors.white, fontSize: scaleW(16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInventoryContent(
    BuildContext context,
    double Function(double) scaleW,
    double Function(double) scaleH,
  ) {
    return Scaffold(
      backgroundColor: AppColors.blue600,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: scaleW(24),
                vertical: scaleH(20),
              ),
              child: Column(
                children: [
                  Text(
                    'Inventario',
                    style: TextStyle(
                      fontSize: scaleW(28),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: scaleH(8)),
                  Text(
                    'Gestión de productos y stock',
                    style: TextStyle(
                      fontSize: scaleW(16),
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(scaleW(32)),
                    topRight: Radius.circular(scaleW(32)),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowColor,
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: BlocBuilder<InventoryBloc, InventoryState>(
                  builder: (context, state) {
                    if (state is InventoryLoading) {
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
                              "Cargando productos...",
                              style: TextStyle(
                                color: AppColors.blue600,
                                fontSize: scaleW(16),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state is InventoryWithStatsLoaded) {
                      if (state.products.isEmpty) {
                        return _buildEmptyOrFilteredState(
                          state,
                          scaleW,
                          scaleH,
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          _inventoryBloc.add(RefreshInventory());
                        },
                        child: CustomScrollView(
                          controller: _scrollController,
                          slivers: [
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(
                                  scaleW(24),
                                  scaleH(20),
                                  scaleW(24),
                                  scaleH(16),
                                ),
                                child: SearchBarWithButton(
                                  controller: _searchController,
                                  onSearch: _onSearch,
                                  onClear: _onClearSearch,
                                ),
                              ),
                            ),

                            if (state.stats != null)
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: scaleW(24),
                                    vertical: scaleH(8),
                                  ),
                                  child: CompactInventoryStats(
                                    stats: state.stats!,
                                  ),
                                ),
                              ),

                            SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: scaleW(10),
                                  vertical: scaleH(4),
                                ),
                                child: PaginationInfo(
                                  currentPage: state.currentPage,
                                  totalPages: state.totalPages,
                                  totalProducts: state.totalProducts,
                                  currentProductsCount: state.products.length,
                                  hasReachedMax: state.hasReachedMax,
                                  isLoadingMore: state.isLoadingMore,
                                ),
                              ),
                            ),

                            const SliverToBoxAdapter(
                              child: SizedBox(height: 12),
                            ),

                            SliverList(
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                final product = state.products[index];
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: scaleW(10),
                                    vertical: scaleH(4),
                                  ),
                                  child: InventoryCard(
                                    product: product,
                                    onTap: () async {
                                      final updated = await context.push(
                                        '/main/update-stock/${product.id}',
                                      );
                                      if (updated == true && context.mounted) {
                                        _inventoryBloc.add(RefreshInventory());
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Inventario actualizado correctamente',
                                            ),
                                            backgroundColor: AppColors.green600,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                );
                              }, childCount: state.products.length),
                            ),

                            SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(
                                  scaleW(24),
                                  scaleH(24),
                                  scaleW(24),
                                  scaleH(32),
                                ),
                                child: Column(
                                  children: [
                                    PaginationControls(
                                      currentPage: state.currentPage,
                                      totalPages: state.totalPages,
                                      isLoading: state.isLoadingMore,
                                      onPageChanged: _onPageChanged,
                                    ),
                                    SizedBox(height: scaleH(16)),
                                    Text(
                                      'Página ${state.currentPage} de ${state.totalPages}',
                                      style: TextStyle(
                                        fontSize: scaleW(14),
                                        color: AppColors.gray600,
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

                    if (state is InventoryError) {
                      return _buildErrorState(state, scaleW, scaleH);
                    }

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
                            "Cargando productos...",
                            style: TextStyle(
                              color: AppColors.blue600,
                              fontSize: scaleW(16),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyOrFilteredState(
    InventoryWithStatsLoaded state,
    double Function(double) scaleW,
    double Function(double) scaleH,
  ) {
    final hasFilters =
        state.currentSearch != null || state.currentStockStatus != null;

    return Center(
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
                  Icons.inventory_2_outlined,
                  size: scaleW(60),
                  color: AppColors.blue600,
                ),
              ),
              SizedBox(height: scaleH(20)),
              Text(
                hasFilters
                    ? 'No se encontraron productos con los filtros aplicados.'
                    : 'Tu inventario está vacío.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: scaleW(18),
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray800,
        child: SizedBox(
          height: screenSize.height * 0.6,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: screenSize.width * 0.15,
                  color: AppColors.gray400,
                ),
                SizedBox(height: screenSize.height * 0.02),
                Text(
                  'No se encontraron productos',
                  style: TextStyle(
                    fontSize: screenSize.width * 0.04,
                    color: AppColors.gray600,
                  ),
                ),
              ),
              SizedBox(height: scaleH(8)),
              Text(
                hasFilters
                    ? 'Intenta ajustar los filtros o restablecer la búsqueda.'
                    : 'Agrega nuevos productos para comenzar a administrar tu inventario.',
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
    );
  }

  Widget _buildErrorState(
    InventoryError state,
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
              'Error cargando inventario',
              style: TextStyle(
                fontSize: scaleW(16),
                fontWeight: FontWeight.w600,
                color: AppColors.red600,
              ),
            ),
            SizedBox(height: scaleH(8)),
            Text(
              state.message,
              style: TextStyle(fontSize: scaleW(14), color: AppColors.gray600),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: scaleH(16)),
            ElevatedButton(
              onPressed: () {
                _inventoryBloc.add(RefreshInventory());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue600,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: scaleW(28),
                  vertical: scaleH(14),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(scaleW(12)),
                ),
              ),
              child: Text('Reintentar', style: TextStyle(fontSize: scaleW(14))),
            ),
          ],
        ),
      ),
    );
  }
}
