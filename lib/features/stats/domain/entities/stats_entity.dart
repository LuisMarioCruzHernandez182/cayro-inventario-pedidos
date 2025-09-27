import 'package:equatable/equatable.dart';

class StatsEntity extends Equatable {
  final int totalProducts;
  final int monthlySales;
  final double monthlyRevenue;
  final Map<String, int> statusCounts;
  final int month;
  final int year;
  final DateTime periodStart;
  final DateTime periodEnd;

  const StatsEntity({
    required this.totalProducts,
    required this.monthlySales,
    required this.monthlyRevenue,
    required this.statusCounts,
    required this.month,
    required this.year,
    required this.periodStart,
    required this.periodEnd,
  });

  @override
  List<Object> get props => [
    totalProducts,
    monthlySales,
    monthlyRevenue,
    statusCounts,
    month,
    year,
    periodStart,
    periodEnd,
  ];
}
