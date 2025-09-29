import '../../domain/entities/product_entity.dart';
import 'product_variant_model.dart';
import 'brand_model.dart';
import 'category_model.dart';
import 'gender_model.dart';
import 'sleeve_model.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.active,
    required super.createdAt,
    required super.updatedAt,
    required super.brand,
    required super.category,
    required super.gender,
    required super.sleeve,
    required super.variants,
    required super.totalStock,
    required super.totalReserved,
    required super.totalAvailable,
    required super.totalValue,
    required super.variantCount,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      active: json['active'] ?? true,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      brand: BrandModel.fromJson(json['brand'] ?? {}),
      category: CategoryModel.fromJson(json['category'] ?? {}),
      gender: GenderModel.fromJson(json['gender'] ?? {}),
      sleeve: SleeveModel.fromJson(json['sleeve'] ?? {}),
      variants:
          (json['variants'] as List<dynamic>?)
              ?.map((variant) => ProductVariantModel.fromJson(variant))
              .toList() ??
          [],
      totalStock: json['totalStock'] ?? 0,
      totalReserved: json['totalReserved'] ?? 0,
      totalAvailable: json['totalAvailable'] ?? 0,
      totalValue: (json['totalValue'] ?? 0).toDouble(),
      variantCount: json['variantCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'active': active,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'brand': (brand as BrandModel).toJson(),
      'category': (category as CategoryModel).toJson(),
      'gender': (gender as GenderModel).toJson(),
      'sleeve': (sleeve as SleeveModel).toJson(),
      'variants': variants
          .map((variant) => (variant as ProductVariantModel).toJson())
          .toList(),
      'totalStock': totalStock,
      'totalReserved': totalReserved,
      'totalAvailable': totalAvailable,
      'totalValue': totalValue,
      'variantCount': variantCount,
    };
  }
}
