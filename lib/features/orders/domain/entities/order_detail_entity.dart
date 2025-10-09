import 'package:equatable/equatable.dart';

class OrderDetailEntity extends Equatable {
  final String id;
  final String status;
  final String userName;
  final String? employeeName; 
  final String? address; 
  final double subtotalAmount; 
  final double shippingCost; 
  final double totalAmount; 
  final List<OrderItem> items; 
  final bool isTaken; 

  const OrderDetailEntity({
    required this.id,
    required this.status,
    required this.userName,
    required this.employeeName,
    required this.address,
    required this.subtotalAmount,
    required this.shippingCost,
    required this.totalAmount,
    required this.items,
    required this.isTaken, 
  });

  @override
  List<Object?> get props => [
    id,
    status,
    userName,
    employeeName,
    address,
    subtotalAmount,
    shippingCost,
    totalAmount,
    items,
    isTaken, 
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

  const OrderItem({
    required this.productName,
    required this.color,
    required this.size,
    required this.quantity,
    required this.unitPrice,
    required this.total,
    required this.image,
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
  ];
}
