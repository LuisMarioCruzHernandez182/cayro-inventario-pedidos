import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/inventory_stats_entity.dart';

class InventoryStatsCard extends StatelessWidget {
  final InventoryStatsEntity stats;

  const InventoryStatsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return Card(
      margin: EdgeInsets.all(screenSize.width * 0.04),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(screenSize.width * 0.04),
      ),
      child: Padding(
        padding: EdgeInsets.all(screenSize.width * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Resumen del Inventario',
                style: TextStyle(
                  fontSize: isSmallScreen
                      ? screenSize.width * 0.055
                      : screenSize.width * 0.06,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray900,
                ),
              ),
            ),

            SizedBox(height: screenSize.height * 0.016),

            // Primera fila de estadísticas
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.inventory_2,
                    title: 'Productos',
                    value: stats.totalProducts.toString(),
                    color: AppColors.blue500,
                    screenSize: screenSize,
                    isSmallScreen: isSmallScreen,
                  ),
                ),
                SizedBox(width: screenSize.width * 0.03),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.palette,
                    title: 'Variantes',
                    value: stats.totalVariants.toString(),
                    color: AppColors.purple500,
                    screenSize: screenSize,
                    isSmallScreen: isSmallScreen,
                  ),
                ),
              ],
            ),

            SizedBox(height: screenSize.height * 0.016),

            // Segunda fila de estadísticas
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.check_circle,
                    title: 'En Stock',
                    value: stats.inStockCount.toString(),
                    color: AppColors.green600,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.warning_amber,
                    title: 'Poco Stock',
                    value: stats.lowStockCount.toString(),
                    color: AppColors.orange500,
                    screenSize: screenSize,
                    isSmallScreen: isSmallScreen,
                  ),
                ),
                SizedBox(width: screenSize.width * 0.03),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.error_outline,
                    title: 'Agotados',
                    value: stats.outOfStockCount.toString(),
                    color: AppColors.red500,
                    screenSize: screenSize,
                    isSmallScreen: isSmallScreen,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(screenSize.width * 0.04),
              decoration: BoxDecoration(
                color: AppColors.green50,
                borderRadius: BorderRadius.circular(screenSize.width * 0.03),
                border: Border.all(color: AppColors.green200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.attach_money,
                        color: AppColors.green600,
                        size: isSmallScreen
                            ? screenSize.width * 0.06
                            : screenSize.width * 0.065,
                      ),
                      SizedBox(width: screenSize.width * 0.02),
                      Flexible(
                        child: Text(
                          'Valor Total del Inventario',
                          style: TextStyle(
                            fontSize: isSmallScreen
                                ? screenSize.width * 0.04
                                : screenSize.width * 0.045,
                            fontWeight: FontWeight.w600,
                            color: AppColors.green800,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: screenSize.height * 0.008),

                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '\$${_formatCurrency(stats.totalInventoryValue)}',
                      style: TextStyle(
                        fontSize: isSmallScreen
                            ? screenSize.width * 0.065
                            : screenSize.width * 0.075,
                        fontWeight: FontWeight.bold,
                        color: AppColors.green700,
                      ),
                    ),
                  ),

                  SizedBox(height: screenSize.height * 0.004),

                  Text(
                    '${stats.totalStock} unidades totales',
                    style: TextStyle(
                      fontSize: isSmallScreen
                          ? screenSize.width * 0.035
                          : screenSize.width * 0.04,
                      color: AppColors.green600,
                    ),
                    textAlign: TextAlign.center,
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
    required Size screenSize,
    required bool isSmallScreen,
  }) {
    return Container(
      padding: EdgeInsets.all(screenSize.width * 0.03),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(screenSize.width * 0.03),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: isSmallScreen
                ? screenSize.width * 0.07
                : screenSize.width * 0.075,
          ),

          SizedBox(height: screenSize.height * 0.008),

          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: isSmallScreen
                    ? screenSize.width * 0.055
                    : screenSize.width * 0.06,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),

          SizedBox(height: screenSize.height * 0.004),

          Text(
            title,
            style: TextStyle(
              fontSize: isSmallScreen
                  ? screenSize.width * 0.03
                  : screenSize.width * 0.035,
              color: AppColors.gray600,
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
