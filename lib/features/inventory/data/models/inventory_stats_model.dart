import '../../domain/entities/inventory_stats_entity.dart';

class InventoryStatsModel extends InventoryStatsEntity {
  const InventoryStatsModel({
    required super.totalProducts,
    required super.totalVariants,
    required super.totalStock,
    required super.totalInventoryValue,
    required super.inStockCount,
    required super.lowStockCount,
    required super.outOfStockCount,
  });

  factory InventoryStatsModel.fromJson(Map<String, dynamic> json) {
    return InventoryStatsModel(
      totalProducts: json['totalProducts'] ?? 0,
      totalVariants: json['totalVariants'] ?? 0,
      totalStock: json['totalStock'] ?? 0,
      totalInventoryValue: (json['totalInventoryValue'] ?? 0).toDouble(),
      inStockCount: json['inStockCount'] ?? 0,
      lowStockCount: json['lowStockCount'] ?? 0,
      outOfStockCount: json['outOfStockCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalProducts': totalProducts,
      'totalVariants': totalVariants,
      'totalStock': totalStock,
      'totalInventoryValue': totalInventoryValue,
      'inStockCount': inStockCount,
      'lowStockCount': lowStockCount,
      'outOfStockCount': outOfStockCount,
    };
  }
}
