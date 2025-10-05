import 'package:equatable/equatable.dart';

class InventoryStatsEntity extends Equatable {
  final int totalProducts;
  final int totalVariants;
  final int lowStockCount;
  final int outOfStockCount;
  final int totalStock;
  final double totalInventoryValue;

  const InventoryStatsEntity({
    required this.totalProducts,
    required this.totalVariants,
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.totalStock,
    required this.totalInventoryValue,
  });

  @override
  List<Object?> get props => [
    totalProducts,
    totalVariants,
    lowStockCount,
    outOfStockCount,
    totalStock,
    totalInventoryValue,
  ];
}
