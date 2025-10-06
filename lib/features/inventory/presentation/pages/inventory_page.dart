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
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthUnauthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.pushReplacement('/login');
          });
          return const SizedBox.shrink();
        }

        if (state is AuthLoading) return _buildLoadingState();

        return BlocProvider.value(
          value: _inventoryBloc,
          child: _buildInventoryContent(context),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.blue600, AppColors.blue500, AppColors.blue400],
        ),
      ),
      child: const SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Cargando inventario...',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInventoryContent(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
              // 🔹 Encabezado superior
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 20,
                ),
                child: Column(
                  children: [
                    const Text(
                      'Inventario',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Gestión de productos y stock',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w300,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // 🔹 Contenido principal
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
                  child: Column(
                    children: [
                      // 🔹 Barra de búsqueda
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                        child: BlocBuilder<InventoryBloc, InventoryState>(
                          builder: (context, state) {
                            final isLoading =
                                state is InventoryLoading ||
                                (state is InventoryWithStatsLoaded &&
                                    state.isLoadingMore);

                            return SearchBarWithButton(
                              controller: _searchController,
                              onSearch: _onSearch,
                              onClear: _onClearSearch,
                              isLoading: isLoading,
                            );
                          },
                        ),
                      ),

                      // 🔹 Lista principal
                      Expanded(
                        child: BlocBuilder<InventoryBloc, InventoryState>(
                          builder: (context, state) {
                            if (state is InventoryLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (state is InventoryWithStatsLoaded) {
                              if (state.products.isEmpty) {
                                return _buildEmptyOrFilteredState(state);
                              }

                              return RefreshIndicator(
                                onRefresh: () async {
                                  _inventoryBloc.add(RefreshInventory());
                                },
                                child: CustomScrollView(
                                  controller: _scrollController,
                                  slivers: [
                                    // 🔹 Estadísticas
                                    if (state.stats != null)
                                      SliverToBoxAdapter(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 8,
                                          ),
                                          child: CompactInventoryStats(
                                            key: ValueKey(
                                              state.stats!.hashCode,
                                            ),
                                            stats: state.stats!,
                                          ),
                                        ),
                                      ),

                                    // 🔹 Info de paginación
                                    SliverToBoxAdapter(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        child: PaginationInfo(
                                          currentPage: state.currentPage,
                                          totalPages: state.totalPages,
                                          totalProducts: state.totalProducts,
                                          currentProductsCount:
                                              state.products.length,
                                          hasReachedMax: state.hasReachedMax,
                                          isLoadingMore: state.isLoadingMore,
                                        ),
                                      ),
                                    ),

                                    const SliverToBoxAdapter(
                                      child: SizedBox(height: 16),
                                    ),

                                    // 🔹 Lista de productos
                                    SliverList(
                                      delegate: SliverChildBuilderDelegate((
                                        context,
                                        index,
                                      ) {
                                        final product = state.products[index];
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          child: InventoryCard(
                                            product: product,
                                            onTap: () {
                                              context.push(
                                                '/main/update-stock/${product.id}',
                                              );
                                            },
                                          ),
                                        );
                                      }, childCount: state.products.length),
                                    ),

                                    // 🔹 Controles de paginación
                                    SliverToBoxAdapter(
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          24,
                                          24,
                                          24,
                                          32,
                                        ),
                                        child: Column(
                                          children: [
                                            PaginationControls(
                                              currentPage: state.currentPage,
                                              totalPages: state.totalPages,
                                              isLoading: state.isLoadingMore,
                                              onPageChanged: _onPageChanged,
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'Página ${state.currentPage} de ${state.totalPages}',
                                              style: TextStyle(
                                                fontSize: 14,
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
                              return _buildErrorState(state);
                            }

                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 Estado vacío o sin resultados (mantiene diseño + botón “Limpiar filtros”)
  Widget _buildEmptyOrFilteredState(InventoryWithStatsLoaded state) {
    final hasFilters =
        state.currentSearch != null || state.currentStockStatus != null;

    return RefreshIndicator(
      onRefresh: () async {
        _inventoryBloc.add(RefreshInventory());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🔹 Icono circular
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
                  Icons.inventory_2_outlined,
                  size: 70,
                  color: AppColors.blue600,
                ),
              ),
              const SizedBox(height: 24),

              // 🔹 Texto principal
              Text(
                hasFilters
                    ? 'No se encontraron productos con los filtros aplicados.'
                    : 'No se encontraron productos en el inventario.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray800,
                ),
              ),
              const SizedBox(height: 12),

              // 🔹 Subtexto
              Text(
                hasFilters
                    ? 'Puedes limpiar los filtros para volver a ver todos los productos.'
                    : 'Agrega productos o verifica la conexión al servidor.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.gray600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),

              // 🔹 Botón “Limpiar filtros”
              if (hasFilters)
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
      ),
    );
  }

  /// 🔹 Estado de error
  Widget _buildErrorState(InventoryError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.red500),
            const SizedBox(height: 16),
            Text(
              'Error cargando inventario',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.red600,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              style: TextStyle(fontSize: 14, color: AppColors.gray600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _inventoryBloc.add(RefreshInventory());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
