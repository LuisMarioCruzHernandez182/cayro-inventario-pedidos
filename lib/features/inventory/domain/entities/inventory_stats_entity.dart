import 'package:equatable/equatable.dart';

class InventoryStatsEntity extends Equatable {
  final int totalProducts;
  final int totalVariants;
  final int totalStock;
  final double totalInventoryValue;
  final int inStockCount;
  final int lowStockCount;
  final int outOfStockCount;

  const InventoryStatsEntity({
    required this.totalProducts,
    required this.totalVariants,
    required this.totalStock,
    required this.totalInventoryValue,
    required this.inStockCount,
    required this.lowStockCount,
    required this.outOfStockCount,
  });

  @override
  List<Object?> get props => [
    totalProducts,
    totalVariants,
    totalStock,
    totalInventoryValue,
    inStockCount,
    lowStockCount,
    outOfStockCount,
  ];
}
