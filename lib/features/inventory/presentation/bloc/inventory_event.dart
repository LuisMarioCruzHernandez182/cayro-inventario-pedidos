import 'package:equatable/equatable.dart';

abstract class InventoryEvent extends Equatable {
  const InventoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadInventory extends InventoryEvent {
  final int page;
  final int limit;
  final String? search;

  const LoadInventory({this.page = 1, this.limit = 10, this.search});

  @override
  List<Object?> get props => [page, limit, search];
}

class LoadInventoryStats extends InventoryEvent {}

class LoadInventoryWithStats extends InventoryEvent {
  final int page;
  final int limit;
  final String? search;

  const LoadInventoryWithStats({this.page = 1, this.limit = 10, this.search});

  @override
  List<Object?> get props => [page, limit, search];
}

class LoadProductById extends InventoryEvent {
  final int productId;

  const LoadProductById({required this.productId});

  @override
  List<Object> get props => [productId];
}

class LoadProductVariants extends InventoryEvent {
  final int productId;

  const LoadProductVariants({required this.productId});

  @override
  List<Object> get props => [productId];
}

class UpdateVariantStock extends InventoryEvent {
  final int variantId;
  final String adjustmentType;
  final int quantity;
  final String? reason;

  const UpdateVariantStock({
    required this.variantId,
    required this.adjustmentType,
    required this.quantity,
    this.reason,
  });

  @override
  List<Object?> get props => [variantId, adjustmentType, quantity, reason];
}

class LoadLowStockProducts extends InventoryEvent {
  final int threshold;

  const LoadLowStockProducts({this.threshold = 5});

  @override
  List<Object> get props => [threshold];
}

class RefreshInventory extends InventoryEvent {}

class SearchInventory extends InventoryEvent {
  final String query;

  const SearchInventory({required this.query});

  @override
  List<Object> get props => [query];
}

class LoadMoreInventory extends InventoryEvent {
  const LoadMoreInventory();

  @override
  List<Object?> get props => [];
}

class SearchInventoryWithButton extends InventoryEvent {
  final String query;

  const SearchInventoryWithButton({required this.query});

  @override
  List<Object> get props => [query];
}

class NavigateToPage extends InventoryEvent {
  final int page;
  final String? search;

  const NavigateToPage({required this.page, this.search});

  @override
  List<Object?> get props => [page, search];
}

class ClearSearch extends InventoryEvent {
  const ClearSearch();

  @override
  List<Object?> get props => [];
}
