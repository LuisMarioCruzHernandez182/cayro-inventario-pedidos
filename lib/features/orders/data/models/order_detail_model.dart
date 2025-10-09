import '../../domain/entities/order_detail_entity.dart';

class OrderDetailModel {
  final Map<String, dynamic> map;
  OrderDetailModel(this.map);

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) =>
      OrderDetailModel(json);

  OrderDetailEntity toEntity() {
    double toDouble(dynamic v) {
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    String fullName(Map<String, dynamic>? u) {
      if (u == null) return '';
      final n = (u['name'] ?? '').toString().trim();
      final s = (u['surname'] ?? '').toString().trim();
      return [n, s].where((e) => e.isNotEmpty).join(' ');
    }

    String? address(Map<String, dynamic>? a) {
      if (a == null) return null;
      final street = (a['street'] ?? '').toString();
      final colony = (a['colony'] ?? '').toString();
      final city = (a['city'] ?? '').toString();
      final state = (a['state'] ?? '').toString();
      final postal = (a['postalCode'] ?? '').toString();
      final country = (a['country'] ?? '').toString();
      final parts = [
        street,
        colony,
        city,
        state,
        postal,
        country,
      ].where((e) => e.isNotEmpty).toList();
      return parts.isEmpty ? null : parts.join(', ');
    }

    String? variantImage(Map<String, dynamic>? variant) {
      if (variant == null) return null;
      final images = (variant['images'] as List<dynamic>?) ?? const [];
      if (images.isEmpty) return null;
      final front = images.firstWhere(
        (img) => (img['angle'] ?? '') == 'front',
        orElse: () => images.first,
      );
      return front['url']?.toString();
    }

    final items = <OrderItem>[];
    final saleDetails = (map['saleDetails'] as List<dynamic>?) ?? const [];
    for (final d in saleDetails) {
      final variant = (d['productVariant'] as Map<String, dynamic>?) ?? {};
      final product = (variant['product'] as Map<String, dynamic>?) ?? {};
      final color = (variant['color'] as Map<String, dynamic>?) ?? {};
      final size = (variant['size'] as Map<String, dynamic>?) ?? {};

      items.add(
        OrderItem(
          productName: (product['name'] ?? '').toString(),
          color: (color['name'] ?? '').toString(),
          size: (size['name'] ?? '').toString(),
          quantity: (d['quantity'] is int)
              ? d['quantity'] as int
              : int.tryParse(d['quantity'].toString()) ?? 0,
          unitPrice: toDouble(d['unitPrice']),
          total: toDouble(d['totalPrice']),
          image: variantImage(variant),
        ),
      );
    }

    return OrderDetailEntity(
      id: (map['id'] ?? '').toString(),
      status: (map['status'] ?? '').toString(),
      userName: fullName(map['user'] as Map<String, dynamic>?),
      employeeName: (() {
        final emp = map['employee'] as Map<String, dynamic>?;
        final name = fullName(emp);
        return name.isEmpty ? null : name;
      })(),
      address: address(map['address'] as Map<String, dynamic>?),
      subtotalAmount: toDouble(map['subtotalAmount']),
      shippingCost: toDouble(map['shippingCost']),
      totalAmount: toDouble(map['totalAmount']),
      items: items,
      isTaken:
          map['isTaken'] == true ||
          map['employee'] !=
              null, 
    );
  }
}
