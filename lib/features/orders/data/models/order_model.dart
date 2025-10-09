import '../../domain/entities/order_entity.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.saleReference,
    required super.status,
    required super.totalAmount,
    required super.userName,
    required super.employeeName,
    required super.createdAt,
    required super.productsCount,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return 0.0;
    }

    return OrderModel(
      id: json['id'].toString(),
      saleReference: json['saleReference'] ?? '',
      status: json['status'] ?? '',
      totalAmount: parseDouble(json['totalAmount']),
      userName: json['user']?['name'] ?? 'Cliente desconocido',
      employeeName: json['employee']?['name'],
      createdAt: json['createdAt'] ?? '',
      productsCount: (json['saleDetails'] as List?)?.length ?? 0,
    );
  }
}
