import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/inventory_stats_entity.dart';

class InventoryStatsCard extends StatelessWidget {
  final InventoryStatsEntity stats;

  const InventoryStatsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen del Inventario',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.gray900,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.inventory_2,
                    title: 'Productos',
                    value: stats.totalProducts.toString(),
                    color: AppColors.blue500,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.palette,
                    title: 'Variantes',
                    value: stats.totalVariants.toString(),
                    color: AppColors.purple500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.warning_amber,
                    title: 'Poco Stock',
                    value: stats.lowStockCount.toString(),
                    color: AppColors.orange500,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.error_outline,
                    title: 'Sin Stock',
                    value: stats.outOfStockCount.toString(),
                    color: AppColors.red500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.green50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.green200),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.attach_money,
                        color: AppColors.green600,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Valor Total del Inventario',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.green800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${stats.totalInventoryValue.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.green700,
                    ),
                  ),
                  Text(
                    '${stats.totalStock} unidades totales',
                    style: TextStyle(fontSize: 14, color: AppColors.green600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.gray600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
