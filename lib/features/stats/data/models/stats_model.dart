import '../../domain/entities/stats_entity.dart';

class StatsModel extends StatsEntity {
  const StatsModel({
    required super.totalProducts,
    required super.monthlySales,
    required super.monthlyRevenue,
    required super.statusCounts,
    required super.month,
    required super.year,
    required super.periodStart,
    required super.periodEnd,
  });

  factory StatsModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final period = data['period'] as Map<String, dynamic>;
    final statusCounts = Map<String, int>.from(data['statusCounts'] as Map);

    return StatsModel(
      totalProducts: data['totalProducts'] as int,
      monthlySales: data['monthlySales'] as int,
      monthlyRevenue: (data['monthlyRevenue'] as num).toDouble(),
      statusCounts: statusCounts,
      month: data['month'] as int,
      year: data['year'] as int,
      periodStart: DateTime.parse(period['start'] as String),
      periodEnd: DateTime.parse(period['end'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {
        'totalProducts': totalProducts,
        'monthlySales': monthlySales,
        'monthlyRevenue': monthlyRevenue,
        'statusCounts': statusCounts,
        'month': month,
        'year': year,
        'period': {
          'start': periodStart.toIso8601String(),
          'end': periodEnd.toIso8601String(),
        },
      },
    };
  }
}
