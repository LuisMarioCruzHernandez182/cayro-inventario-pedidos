import 'package:equatable/equatable.dart';
import 'color_entity.dart';
import 'size_entity.dart';
import 'image_entity.dart';

class ProductVariantEntity extends Equatable {
  final int id;
  final int productId;
  final ColorEntity color;
  final SizeEntity size;
  final double price;
  final int stock;
  final String barcode;
  final int reserved;
  final int available;
  final List<ImageEntity> images;

  const ProductVariantEntity({
    required this.id,
    required this.productId,
    required this.color,
    required this.size,
    required this.price,
    required this.stock,
    required this.barcode,
    required this.reserved,
    required this.available,
    required this.images,
  });

  @override
  List<Object?> get props => [
    id,
    productId,
    color,
    size,
    price,
    stock,
    barcode,
    reserved,
    available,
    images,
  ];
}
