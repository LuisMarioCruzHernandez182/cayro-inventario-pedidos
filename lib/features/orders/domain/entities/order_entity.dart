class OrderEntity {
  final String id;
  final String saleReference;
  final String status;
  final double totalAmount;
  final String userName;
  final String? employeeName;
  final String createdAt;
  final int productsCount;

  const OrderEntity({
    required this.id,
    required this.saleReference,
    required this.status,
    required this.totalAmount,
    required this.userName,
    required this.employeeName,
    required this.createdAt,
    required this.productsCount,
  });
}
