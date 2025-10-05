import '../../domain/entities/product_variant_entity.dart';
import 'color_model.dart';
import 'size_model.dart';
import 'image_model.dart';

class ProductVariantModel extends ProductVariantEntity {
  const ProductVariantModel({
    required super.id,
    required super.productId,
    required super.color,
    required super.size,
    required super.price,
    required super.stock,
    required super.barcode,
    required super.reserved,
    required super.available,
    required super.images,
  });

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    return ProductVariantModel(
      id: json['id'] ?? 0,
      productId: json['productId'] ?? 0,
      color: ColorModel.fromJson(json['color'] ?? {}),
      size: SizeModel.fromJson(json['size'] ?? {}),
      price: (json['price'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
      barcode: json['barcode'] ?? '',
      reserved: json['reserved'] ?? 0,
      available: json['available'] ?? 0,
      images:
          (json['images'] as List<dynamic>?)
              ?.map((image) => ImageModel.fromJson(image))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'color': (color as ColorModel).toJson(),
      'size': (size as SizeModel).toJson(),
      'price': price,
      'stock': stock,
      'barcode': barcode,
      'reserved': reserved,
      'available': available,
      'images': images.map((image) => (image as ImageModel).toJson()).toList(),
    };
  }
}
