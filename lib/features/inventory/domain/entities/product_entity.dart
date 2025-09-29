import 'package:equatable/equatable.dart';
import 'product_variant_entity.dart';
import 'brand_entity.dart';
import 'category_entity.dart';
import 'gender_entity.dart';
import 'sleeve_entity.dart';

class ProductEntity extends Equatable {
  final int id;
  final String name;
  final String description;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;
  final BrandEntity brand;
  final CategoryEntity category;
  final GenderEntity gender;
  final SleeveEntity sleeve;
  final List<ProductVariantEntity> variants;
  final int totalStock;
  final int totalReserved;
  final int totalAvailable;
  final double totalValue;
  final int variantCount;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
    required this.brand,
    required this.category,
    required this.gender,
    required this.sleeve,
    required this.variants,
    required this.totalStock,
    required this.totalReserved,
    required this.totalAvailable,
    required this.totalValue,
    required this.variantCount,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    active,
    createdAt,
    updatedAt,
    brand,
    category,
    gender,
    sleeve,
    variants,
    totalStock,
    totalReserved,
    totalAvailable,
    totalValue,
    variantCount,
  ];
}
