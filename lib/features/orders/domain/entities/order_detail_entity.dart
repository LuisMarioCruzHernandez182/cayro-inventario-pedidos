import 'package:equatable/equatable.dart';

class OrderDetailEntity extends Equatable {
  final String id;
  final String status;
  final String userName; // nombre completo del cliente
  final String? employeeName; // nombre completo del empleado (o null)
  final String? address; // dirección formateada
  final double subtotalAmount; // subtotal
  final double shippingCost; // costo de envío
  final double totalAmount; // total
  final List<OrderItem> items; // productos del pedido
  final bool isTaken; // 🔹 indica si el pedido ya fue tomado o no

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
    required this.isTaken, // 👈 nuevo campo obligatorio
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
    isTaken, // 👈 incluido en las props
  ];
}

class OrderItem extends Equatable {
  final String productName;
  final String color;
  final String size;
  final int quantity;
  final double unitPrice;
  final double total;
  final String? image; // url de la imagen (frontal si existe)

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
