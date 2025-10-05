import 'package:equatable/equatable.dart';
import 'product_model.dart';

class InventoryResponseModel extends Equatable {
  final List<ProductModel> products;
  final PaginationModel pagination;

  const InventoryResponseModel({
    required this.products,
    required this.pagination,
  });

  factory InventoryResponseModel.fromJson(Map<String, dynamic> json) {
    return InventoryResponseModel(
      products: (json['products'] as List<dynamic>)
          .map((product) => ProductModel.fromJson(product))
          .toList(),
      pagination: PaginationModel.fromJson(json['pagination'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [products, pagination];
}

class PaginationModel extends Equatable {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const PaginationModel({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      total: json['total'] ?? 0,
      totalPages: json['totalPages'] ?? 1,
    );
  }

  @override
  List<Object?> get props => [page, limit, total, totalPages];
}
