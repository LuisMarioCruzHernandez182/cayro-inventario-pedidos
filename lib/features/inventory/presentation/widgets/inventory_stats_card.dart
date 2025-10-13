import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/inventory_stats_entity.dart';

class InventoryStatsCard extends StatelessWidget {
  final InventoryStatsEntity stats;

  const InventoryStatsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    double scaleW(double v) => v * (width / 390);
    double scaleH(double v) => v * (height / 844);

    return Container(
      margin: EdgeInsets.all(scaleW(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(scaleW(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: AppColors.gray200),
      ),
      child: Padding(
        padding: EdgeInsets.all(scaleW(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen del Inventario',
              style: TextStyle(
                fontSize: scaleW(20),
                fontWeight: FontWeight.bold,
                color: AppColors.gray900,
              ),
            ),
            SizedBox(height: scaleH(16)),

            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.inventory_2_rounded,
                    title: 'Productos',
                    value: stats.totalProducts.toString(),
                    color: AppColors.blue600,
                    scaleW: scaleW,
                  ),
                ),
                SizedBox(width: scaleW(12)),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.palette_rounded,
                    title: 'Variantes',
                    value: stats.totalVariants.toString(),
                    color: AppColors.purple500,
                    scaleW: scaleW,
                  ),
                ),
              ],
            ),
            SizedBox(height: scaleH(16)),

            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.check_circle,
                    title: 'En Stock',
                    value: stats.inStockCount.toString(),
                    color: AppColors.green600,
                    scaleW: scaleW,
                  ),
                ),
                SizedBox(width: scaleW(8)),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.warning_amber_rounded,
                    title: 'Poco Stock',
                    value: stats.lowStockCount.toString(),
                    color: AppColors.amber600,
                    scaleW: scaleW,
                  ),
                ),
                SizedBox(width: scaleW(8)),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.cancel_rounded,
                    title: 'Agotados',
                    value: stats.outOfStockCount.toString(),
                    color: AppColors.red600,
                    scaleW: scaleW,
                  ),
                ),
              ],
            ),

            SizedBox(height: scaleH(20)),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(scaleW(16)),
              decoration: BoxDecoration(
                color: AppColors.green50,
                borderRadius: BorderRadius.circular(scaleW(12)),
                border: Border.all(color: AppColors.green200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.attach_money_rounded,
                        color: AppColors.green600,
                        size: scaleW(24),
                      ),
                      SizedBox(width: scaleW(8)),
                      Expanded(
                        child: Text(
                          'Valor Total del Inventario',
                          style: TextStyle(
                            fontSize: scaleW(16),
                            fontWeight: FontWeight.w600,
                            color: AppColors.green800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: scaleH(8)),
                  Text(
                    '\$${stats.totalInventoryValue.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: scaleW(24),
                      fontWeight: FontWeight.bold,
                      color: AppColors.green700,
                    ),
                  ),

                  SizedBox(height: screenSize.height * 0.004),

                  Text(
                    '${stats.totalStock} unidades totales',
                    style: TextStyle(
                      fontSize: scaleW(13),
                      color: AppColors.green600,
                      fontWeight: FontWeight.w500,
                    ),
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
    required double Function(double) scaleW,
  }) {
    return Container(
      padding: EdgeInsets.all(scaleW(12)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(scaleW(12)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: scaleW(28)),
          SizedBox(height: scaleW(8)),
          Text(
            value,
            style: TextStyle(
              fontSize: scaleW(20),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: scaleW(4)),
          Text(
            title,
            style: TextStyle(
              fontSize: scaleW(12),
              color: AppColors.gray700,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
    return value.toStringAsFixed(2);
  }
}
