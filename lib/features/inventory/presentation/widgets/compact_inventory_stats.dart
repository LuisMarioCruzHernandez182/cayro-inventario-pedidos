import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/inventory_stats_entity.dart';

class CompactInventoryStats extends StatelessWidget {
  final InventoryStatsEntity stats;

  const CompactInventoryStats({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    final isVerySmallScreen = screenSize.width < 320;

    return Column(
      children: [
        // Primera fila: Tarjetas grandes
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
                screenSize: screenSize,
                isSmallScreen: isSmallScreen,
              ),
            ),
            SizedBox(width: screenSize.width * 0.03),
            Expanded(
              child: _buildStatCard(
                title: 'Valor Total',
                value: '\$${_formatCurrency(stats.totalInventoryValue)}',
                subtitle: 'Inventario actual',
                color: AppColors.green600,
                backgroundColor: AppColors.green50,
                icon: Icons.attach_money,
                screenSize: screenSize,
                isSmallScreen: isSmallScreen,
              ),
            ),
          ],
        ),
        SizedBox(height: screenSize.height * 0.012),

        // Segunda fila: Tarjetas pequeñas
        Row(
          children: [
            Expanded(
              child: _buildSmallStatCard(
                value:
                    (stats.totalStock -
                            stats.lowStockCount -
                            stats.outOfStockCount)
                        .toString(),
                title: 'En Stock',
                color: AppColors.green500,
                backgroundColor: AppColors.green50,
                icon: Icons.check_circle,
                screenSize: screenSize,
                isVerySmallScreen: isVerySmallScreen,
              ),
            ),
            SizedBox(width: screenSize.width * 0.02),
            Expanded(
              child: _buildSmallStatCard(
                value: stats.lowStockCount.toString(),
                title: 'Poco Stock',
                color: AppColors.orange500,
                backgroundColor: AppColors.orange50,
                icon: Icons.warning,
                screenSize: screenSize,
                isVerySmallScreen: isVerySmallScreen,
              ),
            ),
            SizedBox(width: screenSize.width * 0.02),
            Expanded(
              child: _buildSmallStatCard(
                value: stats.outOfStockCount.toString(),
                title: 'Agotados',
                color: AppColors.red500,
                backgroundColor: AppColors.red50,
                icon: Icons.cancel,
                screenSize: screenSize,
                isVerySmallScreen: isVerySmallScreen,
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
    required Size screenSize,
    required bool isSmallScreen,
  }) {
    return Container(
      padding: EdgeInsets.all(screenSize.width * 0.04),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(screenSize.width * 0.04),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: screenSize.width * 0.05),
              SizedBox(width: screenSize.width * 0.02),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: isSmallScreen
                        ? screenSize.width * 0.03
                        : screenSize.width * 0.032,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: screenSize.height * 0.008),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: isSmallScreen
                    ? screenSize.width * 0.06
                    : screenSize.width * 0.065,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          SizedBox(height: screenSize.height * 0.004),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: isSmallScreen
                  ? screenSize.width * 0.028
                  : screenSize.width * 0.03,
              color: color.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
    required Size screenSize,
    required bool isVerySmallScreen,
  }) {
    return Container(
      padding: EdgeInsets.all(screenSize.width * 0.03),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(screenSize.width * 0.03),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icono circular
          Container(
            padding: EdgeInsets.all(screenSize.width * 0.02),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(screenSize.width * 0.05),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: isVerySmallScreen
                  ? screenSize.width * 0.035
                  : screenSize.width * 0.04,
            ),
          ),
          SizedBox(height: screenSize.height * 0.008),

          // Valor
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: isVerySmallScreen
                    ? screenSize.width * 0.045
                    : screenSize.width * 0.05,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          SizedBox(height: screenSize.height * 0.002),

          // Título
          Text(
            title,
            style: TextStyle(
              fontSize: isVerySmallScreen
                  ? screenSize.width * 0.025
                  : screenSize.width * 0.028,
              color: color,
              fontWeight: FontWeight.w600,
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
    return value.toStringAsFixed(0);
  }
}
