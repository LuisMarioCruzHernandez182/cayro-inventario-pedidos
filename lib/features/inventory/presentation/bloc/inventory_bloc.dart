import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_inventory_usecase.dart';
import '../../domain/usecases/get_inventory_stats_usecase.dart';
import '../../domain/usecases/get_product_by_id_usecase.dart';
import '../../domain/usecases/get_product_variants_usecase.dart';
import '../../domain/usecases/update_variant_stock_usecase.dart';
import 'inventory_event.dart';
import 'inventory_state.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final GetInventoryUseCase getInventoryUseCase;
  final GetInventoryStatsUseCase getInventoryStatsUseCase;
  final GetProductByIdUseCase getProductByIdUseCase;
  final GetProductVariantsUseCase getProductVariantsUseCase;
  final UpdateVariantStockUseCase updateVariantStockUseCase;

  bool _isLoadingInventory = false;
  bool _isLoadingStats = false;

  InventoryBloc({
    required this.getInventoryUseCase,
    required this.getInventoryStatsUseCase,
    required this.getProductByIdUseCase,
    required this.getProductVariantsUseCase,
    required this.updateVariantStockUseCase,
  }) : super(InventoryInitial()) {
    on<LoadInventory>(_onLoadInventory);
    on<LoadInventoryStats>(_onLoadInventoryStats);
    on<LoadInventoryWithStats>(_onLoadInventoryWithStats);
    on<LoadProductById>(_onLoadProductById);
    on<LoadProductVariants>(_onLoadProductVariants);
    on<UpdateVariantStock>(_onUpdateVariantStock);
    on<RefreshInventory>(_onRefreshInventory);
    on<SearchInventory>(_onSearchInventory);
    on<LoadMoreInventory>(_onLoadMoreInventory);
    on<SearchInventoryWithButton>(_onSearchInventoryWithButton);
    on<NavigateToPage>(_onNavigateToPage);
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onLoadInventory(
    LoadInventory event,
    Emitter<InventoryState> emit,
  ) async {
    if (_isLoadingInventory) return;

    _isLoadingInventory = true;

    if (event.page == 1 &&
        state is! InventoryWithStatsLoaded &&
        state is! InventoryStatsLoaded) {
      emit(InventoryLoading());
    }

    try {
      final result = await getInventoryUseCase(
        page: event.page,
        limit: event.limit,
        search: event.search,
      );

      result.fold(
        (failure) {
          emit(InventoryError(message: failure.message));
        },
        (inventoryResponse) {
          if (state is InventoryLoaded && event.page > 1) {
            final currentState = state as InventoryLoaded;
            final updatedProducts = List.of(currentState.products)
              ..addAll(inventoryResponse.products);
            emit(
              InventoryLoaded(
                products: updatedProducts,
                hasReachedMax: inventoryResponse.products.isEmpty,
                currentPage: event.page,
                currentSearch: event.search,
              ),
            );
          } else {
            emit(
              InventoryLoaded(
                products: inventoryResponse.products,
                hasReachedMax: inventoryResponse.products.isEmpty,
                currentPage: event.page,
                currentSearch: event.search,
              ),
            );
          }
        },
      );
    } catch (e) {
      emit(InventoryError(message: 'Error inesperado cargando inventario: $e'));
    } finally {
      _isLoadingInventory = false;
    }
  }

  Future<void> _onLoadInventoryStats(
    LoadInventoryStats event,
    Emitter<InventoryState> emit,
  ) async {
    if (_isLoadingStats) return;

    _isLoadingStats = true;

    if (state is! InventoryLoaded &&
        state is! InventoryWithStatsLoaded &&
        state is! InventoryLoading) {
      emit(InventoryLoading());
    }

    try {
      final result = await getInventoryStatsUseCase();

      result.fold(
        (failure) {
          emit(InventoryError(message: failure.message));
        },
        (stats) {
          emit(InventoryStatsLoaded(stats: stats));
        },
      );
    } catch (e) {
      emit(
        InventoryError(message: 'Error inesperado cargando estadísticas: $e'),
      );
    } finally {
      _isLoadingStats = false;
    }
  }

  Future<void> _onLoadInventoryWithStats(
    LoadInventoryWithStats event,
    Emitter<InventoryState> emit,
  ) async {
    if (_isLoadingInventory) return;

    _isLoadingInventory = true;

    if (event.page == 1) {
      emit(InventoryLoading());
    }

    try {
      final inventoryResult = await getInventoryUseCase(
        page: event.page,
        limit: event.limit,
        search: event.search,
      );

      await inventoryResult.fold(
        (failure) async {
          emit(InventoryError(message: failure.message));
        },
        (inventoryResponse) async {
          if (state is InventoryWithStatsLoaded && event.page > 1) {
            final currentState = state as InventoryWithStatsLoaded;
            final updatedProducts = List.of(currentState.products)
              ..addAll(inventoryResponse.products);
            emit(
              currentState.copyWith(
                products: updatedProducts,
                hasReachedMax: inventoryResponse.products.isEmpty,
                currentPage: event.page,
                currentSearch: event.search,
                totalPages: inventoryResponse.pagination.totalPages,
                totalProducts: inventoryResponse.pagination.total,
              ),
            );
          } else {
            emit(
              InventoryWithStatsLoaded(
                products: inventoryResponse.products,
                hasReachedMax: inventoryResponse.products.isEmpty,
                currentPage: event.page,
                currentSearch: event.search,
                isLoadingStats: true,
                totalPages: inventoryResponse.pagination.totalPages,
                totalProducts: inventoryResponse.pagination.total,
              ),
            );

            // Load stats after products are shown (solo en página 1)
            if (event.page == 1) {
              _isLoadingStats = true;
              try {
                final statsResult = await getInventoryStatsUseCase();

                statsResult.fold(
                  (failure) {
                    // IMPORTANTE: Emitir estado actualizado sin stats pero sin error
                    if (state is InventoryWithStatsLoaded) {
                      final currentState = state as InventoryWithStatsLoaded;
                      emit(
                        currentState.copyWith(
                          isLoadingStats: false,
                          // stats permanece null
                        ),
                      );
                    }
                  },
                  (stats) {
                    if (state is InventoryWithStatsLoaded) {
                      final currentState = state as InventoryWithStatsLoaded;
                      emit(
                        currentState.copyWith(
                          stats: stats,
                          isLoadingStats: false,
                        ),
                      );
                    }
                  },
                );
              } catch (e) {
                if (state is InventoryWithStatsLoaded) {
                  final currentState = state as InventoryWithStatsLoaded;
                  emit(
                    currentState.copyWith(
                      isLoadingStats: false,
                      // stats permanece null
                    ),
                  );
                }
              } finally {
                _isLoadingStats = false;
              }
            }
          }
        },
      );
    } catch (e) {
      emit(InventoryError(message: 'Error inesperado cargando inventario: $e'));
    } finally {
      _isLoadingInventory = false;
    }
  }

  Future<void> _onLoadProductById(
    LoadProductById event,
    Emitter<InventoryState> emit,
  ) async {
    emit(InventoryLoading());

    try {
      final result = await getProductByIdUseCase(event.productId);

      result.fold(
        (failure) {
          emit(InventoryError(message: failure.message));
        },
        (product) {
          emit(ProductDetailLoaded(product: product));
        },
      );
    } catch (e) {
      emit(InventoryError(message: 'Error inesperado cargando producto'));
    }
  }

  Future<void> _onLoadProductVariants(
    LoadProductVariants event,
    Emitter<InventoryState> emit,
  ) async {
    emit(InventoryLoading());

    try {
      final result = await getProductVariantsUseCase(event.productId);

      result.fold(
        (failure) {
          emit(InventoryError(message: failure.message));
        },
        (variants) {
          emit(ProductVariantsLoaded(variants: variants));
        },
      );
    } catch (e) {
      emit(InventoryError(message: 'Error inesperado cargando variantes'));
    }
  }

  Future<void> _onUpdateVariantStock(
    UpdateVariantStock event,
    Emitter<InventoryState> emit,
  ) async {
    try {
      final result = await updateVariantStockUseCase(
        variantId: event.variantId,
        adjustmentType: event.adjustmentType,
        quantity: event.quantity,
        reason: event.reason,
      );

      result.fold(
        (failure) {
          emit(InventoryError(message: failure.message));
        },
        (variant) {
          final message = event.adjustmentType == 'ADD'
              ? 'Stock aumentado en ${event.quantity} unidades'
              : 'Stock reducido en ${event.quantity} unidades';

          emit(VariantStockUpdated(variant: variant, message: message));
        },
      );
    } catch (e) {
      emit(InventoryError(message: 'Error inesperado actualizando stock'));
    }
  }

  Future<void> _onRefreshInventory(
    RefreshInventory event,
    Emitter<InventoryState> emit,
  ) async {
    _isLoadingInventory = false;
    _isLoadingStats = false;

    if (state is InventoryWithStatsLoaded) {
      final currentState = state as InventoryWithStatsLoaded;
      add(LoadInventoryWithStats(page: 1, search: currentState.currentSearch));
    } else if (state is InventoryLoaded) {
      final currentState = state as InventoryLoaded;
      add(LoadInventoryWithStats(page: 1, search: currentState.currentSearch));
    } else {
      add(const LoadInventoryWithStats(page: 1));
    }
  }

  Future<void> _onSearchInventory(
    SearchInventory event,
    Emitter<InventoryState> emit,
  ) async {
    _isLoadingInventory = false;
    _isLoadingStats = false;

    add(
      LoadInventoryWithStats(
        page: 1,
        search: event.query.isEmpty ? null : event.query,
      ),
    );
  }

  Future<void> _onLoadMoreInventory(
    LoadMoreInventory event,
    Emitter<InventoryState> emit,
  ) async {
    if (state is! InventoryWithStatsLoaded) return;

    final currentState = state as InventoryWithStatsLoaded;

    if (currentState.hasReachedMax || currentState.isLoadingMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    final nextPage = currentState.currentPage + 1;

    add(
      LoadInventoryWithStats(
        page: nextPage,
        search: currentState.currentSearch,
      ),
    );
  }

  Future<void> _onSearchInventoryWithButton(
    SearchInventoryWithButton event,
    Emitter<InventoryState> emit,
  ) async {
    _isLoadingInventory = false;
    _isLoadingStats = false;

    add(
      LoadInventoryWithStats(
        page: 1,
        search: event.query.isEmpty ? null : event.query,
      ),
    );
  }

  Future<void> _onNavigateToPage(
    NavigateToPage event,
    Emitter<InventoryState> emit,
  ) async {
    if (state is! InventoryWithStatsLoaded) return;

    final currentState = state as InventoryWithStatsLoaded;

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final result = await getInventoryUseCase(
        page: event.page,
        limit: 10,
        search: event.search,
      );

      result.fold(
        (failure) {
          emit(InventoryError(message: failure.message));
        },
        (inventoryResponse) {
          emit(
            currentState.copyWith(
              products: inventoryResponse.products,
              currentPage: event.page,
              currentSearch: event.search,
              hasReachedMax: inventoryResponse.products.isEmpty,
              isLoadingMore: false,
              totalPages: inventoryResponse.pagination.totalPages,
              totalProducts: inventoryResponse.pagination.total,
            ),
          );
        },
      );
    } catch (e) {
      emit(InventoryError(message: 'Error cargando página: $e'));
    }
  }

  Future<void> _onClearSearch(
    ClearSearch event,
    Emitter<InventoryState> emit,
  ) async {
    _isLoadingInventory = false;
    _isLoadingStats = false;

    add(const LoadInventoryWithStats(page: 1, search: null));
  }
}
