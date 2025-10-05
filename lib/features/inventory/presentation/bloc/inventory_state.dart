import 'package:equatable/equatable.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/product_variant_entity.dart';
import '../../domain/entities/inventory_stats_entity.dart';

abstract class InventoryState extends Equatable {
  const InventoryState();

  @override
  List<Object?> get props => [];
}

class InventoryInitial extends InventoryState {}

class InventoryLoading extends InventoryState {}

class InventoryLoaded extends InventoryState {
  final List<ProductEntity> products;
  final bool hasReachedMax;
  final int currentPage;
  final String? currentSearch;

  const InventoryLoaded({
    required this.products,
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.currentSearch,
  });

  InventoryLoaded copyWith({
    List<ProductEntity>? products,
    bool? hasReachedMax,
    int? currentPage,
    String? currentSearch,
  }) {
    return InventoryLoaded(
      products: products ?? this.products,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      currentSearch: currentSearch ?? this.currentSearch,
    );
  }

  @override
  List<Object?> get props => [
    products,
    hasReachedMax,
    currentPage,
    currentSearch,
  ];
}

class InventoryStatsLoaded extends InventoryState {
  final InventoryStatsEntity stats;

  const InventoryStatsLoaded({required this.stats});

  @override
  List<Object> get props => [stats];
}

class ProductDetailLoaded extends InventoryState {
  final ProductEntity product;

  const ProductDetailLoaded({required this.product});

  @override
  List<Object> get props => [product];
}

class ProductVariantsLoaded extends InventoryState {
  final List<ProductVariantEntity> variants;

  const ProductVariantsLoaded({required this.variants});

  @override
  List<Object> get props => [variants];
}

class VariantStockUpdated extends InventoryState {
  final ProductVariantEntity variant;
  final String message;

  const VariantStockUpdated({required this.variant, required this.message});

  @override
  List<Object> get props => [variant, message];
}

class ProductDetailWithVariantsLoaded extends InventoryState {
  final ProductEntity product;
  final List<ProductVariantEntity> variants;

  const ProductDetailWithVariantsLoaded({
    required this.product,
    required this.variants,
  });

  @override
  List<Object> get props => [product, variants];
}

class LowStockProductsLoaded extends InventoryState {
  final List<ProductVariantEntity> lowStockVariants;

  const LowStockProductsLoaded({required this.lowStockVariants});

  @override
  List<Object> get props => [lowStockVariants];
}

class InventoryError extends InventoryState {
  final String message;

  const InventoryError({required this.message});

  @override
  List<Object> get props => [message];
}

class InventoryWithStatsLoaded extends InventoryState {
  final List<ProductEntity> products;
  final InventoryStatsEntity? stats;
  final bool hasReachedMax;
  final int currentPage;
  final String? currentSearch;
  final bool isLoadingStats;
  final bool isLoadingMore;
  final int totalPages;
  final int totalProducts;

  const InventoryWithStatsLoaded({
    required this.products,
    this.stats,
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.currentSearch,
    this.isLoadingStats = false,
    this.isLoadingMore = false,
    this.totalPages = 1,
    this.totalProducts = 0,
  });

  InventoryWithStatsLoaded copyWith({
    List<ProductEntity>? products,
    InventoryStatsEntity? stats,
    bool? hasReachedMax,
    int? currentPage,
    String? currentSearch,
    bool? isLoadingStats,
    bool? isLoadingMore,
    int? totalPages,
    int? totalProducts,
  }) {
    return InventoryWithStatsLoaded(
      products: products ?? this.products,
      stats: stats ?? this.stats,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      currentSearch: currentSearch ?? this.currentSearch,
      isLoadingStats: isLoadingStats ?? this.isLoadingStats,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      totalPages: totalPages ?? this.totalPages,
      totalProducts: totalProducts ?? this.totalProducts,
    );
  }

  @override
  List<Object?> get props => [
    products,
    stats,
    hasReachedMax,
    currentPage,
    currentSearch,
    isLoadingStats,
    isLoadingMore,
    totalPages,
    totalProducts,
  ];
}
