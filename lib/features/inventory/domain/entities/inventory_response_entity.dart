import 'package:stock_control_app/features/inventory/domain/entities/product_entity.dart';

class InventoryResponseEntity {
  final List<ProductEntity> products;
  final PaginationInfo pagination;

  InventoryResponseEntity({required this.products, required this.pagination});
}

class PaginationInfo {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  PaginationInfo({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });
}
