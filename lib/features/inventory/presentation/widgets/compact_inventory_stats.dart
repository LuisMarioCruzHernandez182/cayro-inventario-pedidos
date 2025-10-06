import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/inventory_stats_entity.dart';
import '../bloc/inventory_bloc.dart';
import '../bloc/inventory_event.dart';

class CompactInventoryStats extends StatelessWidget {
  final InventoryStatsEntity stats;

  const CompactInventoryStats({super.key, required this.stats});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Total Productos',
                value: stats.totalProducts.toString(),
                subtitle: '${stats.totalStock} disponibles',
                color: AppColors.blue500,
                backgroundColor: AppColors.blue50,
                icon: Icons.inventory_2,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Valor Total',
                value: '\$${_formatCurrency(stats.totalInventoryValue)}',
                subtitle: 'Inventario actual',
                color: AppColors.green600,
                backgroundColor: AppColors.green50,
                icon: Icons.attach_money,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // 🔹 En stock
            Expanded(
              child: GestureDetector(
                onTap: () {
                  context.read<InventoryBloc>().add(
                    LoadInventoryWithStats(
                      page: 1,
                      search: null,
                      stockStatus: 'IN_STOCK',
                    ),
                  );
                },
                child: _buildSmallStatCard(
                  value: stats.inStockCount.toString(),
                  title: 'En Stock',
                  color: AppColors.green500,
                  backgroundColor: AppColors.green50,
                  icon: Icons.check_circle,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // 🔹 Poco stock
            Expanded(
              child: GestureDetector(
                onTap: () {
                  context.read<InventoryBloc>().add(
                    LoadInventoryWithStats(
                      page: 1,
                      search: null,
                      stockStatus: 'LOW_STOCK',
                    ),
                  );
                },
                child: _buildSmallStatCard(
                  value: stats.lowStockCount.toString(),
                  title: 'Poco Stock',
                  color: AppColors.orange500,
                  backgroundColor: AppColors.orange50,
                  icon: Icons.warning,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // 🔹 Sin stock
            Expanded(
              child: GestureDetector(
                onTap: () {
                  context.read<InventoryBloc>().add(
                    LoadInventoryWithStats(
                      page: 1,
                      search: null,
                      stockStatus: 'OUT_OF_STOCK',
                    ),
                  );
                },
                child: _buildSmallStatCard(
                  value: stats.outOfStockCount.toString(),
                  title: 'Agotados',
                  color: AppColors.red500,
                  backgroundColor: AppColors.red50,
                  icon: Icons.cancel,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required Color backgroundColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: color.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallStatCard({
    required String value,
    required String title,
    required Color color,
    required Color backgroundColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }
}
