import '../../domain/entities/inventory_stats_entity.dart';

class InventoryStatsModel extends InventoryStatsEntity {
  const InventoryStatsModel({
    required super.totalProducts,
    required super.totalVariants,
    required super.lowStockCount,
    required super.outOfStockCount,
    required super.totalStock,
    required super.totalInventoryValue,
  });

  factory InventoryStatsModel.fromJson(Map<String, dynamic> json) {
    return InventoryStatsModel(
      totalProducts: json['totalProducts'] ?? 0,
      totalVariants: json['totalVariants'] ?? 0,
      lowStockCount: json['lowStockCount'] ?? 0,
      outOfStockCount: json['outOfStockCount'] ?? 0,
      totalStock: json['totalStock'] ?? 0,
      totalInventoryValue: (json['totalInventoryValue'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalProducts': totalProducts,
      'totalVariants': totalVariants,
      'lowStockCount': lowStockCount,
      'outOfStockCount': outOfStockCount,
      'totalStock': totalStock,
      'totalInventoryValue': totalInventoryValue,
    };
  }
}
