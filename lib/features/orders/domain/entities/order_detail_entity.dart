import 'package:equatable/equatable.dart';

class OrderDetailEntity extends Equatable {
  final String id;
  final String status;
  final String userName;
  final String? customerEmail;
  final String? employeeName;
  final String? address;
  final double subtotalAmount;
  final double shippingCost;
  final double totalAmount;
  final List<OrderItem> items;
  final bool isTaken;

  // 🔹 Nuevos campos opcionales para emails completos
  final DateTime? createdAt;
  final String? customerPhone;
  final String? saleReference;
  final String? betweenStreetOne;
  final String? betweenStreetTwo;
  final String? references;
  final String? street;
  final String? colony;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;

  const OrderDetailEntity({
    required this.id,
    required this.status,
    required this.userName,
    this.customerEmail,
    required this.employeeName,
    required this.address,
    required this.subtotalAmount,
    required this.shippingCost,
    required this.totalAmount,
    required this.items,
    required this.isTaken,
    this.createdAt, // 👈 Nuevo
    this.customerPhone,
    this.saleReference,
    this.betweenStreetOne,
    this.betweenStreetTwo,
    this.references,
    this.street,
    this.colony,
    this.city,
    this.state,
    this.country,
    this.postalCode,
  });

  @override
  List<Object?> get props => [
    id,
    status,
    userName,
    customerEmail,
    employeeName,
    address,
    subtotalAmount,
    shippingCost,
    totalAmount,
    items,
    isTaken,
    createdAt,
    customerPhone,
    saleReference,
    betweenStreetOne,
    betweenStreetTwo,
    references,
    street,
    colony,
    city,
    state,
    country,
    postalCode,
  ];
}

class OrderItem extends Equatable {
  final String productName;
  final String color;
  final String size;
  final int quantity;
  final double unitPrice;
  final double total;
  final String? image;

  // Opcionalmente podrías agregar también:
  final String? barcode;
  final int? productId;

  const OrderItem({
    required this.productName,
    required this.color,
    required this.size,
    required this.quantity,
    required this.unitPrice,
    required this.total,
    required this.image,
    this.barcode,
    this.productId,
  });

  @override
  List<Object?> get props => [
    productName,
    color,
    size,
    quantity,
    unitPrice,
    total,
    image,
    barcode,
    productId,
  ];
}
