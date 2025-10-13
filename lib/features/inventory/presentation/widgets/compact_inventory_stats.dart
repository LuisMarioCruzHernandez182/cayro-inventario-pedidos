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
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    double scaleW(double v) => v * (width / 390);
    double scaleH(double v) => v * (height / 844);

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
                color: AppColors.blue600,
                backgroundColor: AppColors.blue50,
                icon: Icons.inventory_2,
                scaleW: scaleW,
              ),
            ),
            SizedBox(width: scaleW(12)),
            Expanded(
              child: _buildStatCard(
                title: 'Valor Total',
                value: '\$${_formatCurrency(stats.totalInventoryValue)}',
                subtitle: 'Inventario actual',
                color: AppColors.green600,
                backgroundColor: AppColors.green50,
                icon: Icons.attach_money,
                scaleW: scaleW,
              ),
            ),
          ],
        ),
        SizedBox(height: scaleH(12)),
        Row(
          children: [
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
                  color: AppColors.green600,
                  backgroundColor: AppColors.green50,
                  icon: Icons.check_circle,
                  scaleW: scaleW,
                ),
              ),
            ),
            SizedBox(width: scaleW(8)),

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
                  color: AppColors.amber600,
                  backgroundColor: AppColors.amber50,
                  icon: Icons.warning_amber_rounded,
                  scaleW: scaleW,
                ),
              ),
            ),
            SizedBox(width: scaleW(8)),

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
                  color: AppColors.red600,
                  backgroundColor: AppColors.red50,
                  icon: Icons.cancel,
                  scaleW: scaleW,
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
    required double Function(double) scaleW,
  }) {
    return Container(
      padding: EdgeInsets.all(scaleW(16)),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(scaleW(16)),
        border: Border.all(color: color.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: scaleW(20)),
              SizedBox(width: scaleW(8)),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: scaleW(12),
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: scaleW(8)),
          Text(
            value,
            style: TextStyle(
              fontSize: scaleW(22),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: scaleW(4)),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: scaleW(11),
              color: color.withValues(alpha: 0.7),
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
    required double Function(double) scaleW,
  }) {
    return Container(
      padding: EdgeInsets.all(scaleW(12)),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(scaleW(12)),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icono circular
          Container(
            padding: EdgeInsets.all(scaleW(8)),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(scaleW(20)),
            ),
            child: Icon(icon, color: Colors.white, size: scaleW(16)),
          ),
          SizedBox(height: scaleW(8)),
          Text(
            value,
            style: TextStyle(
              fontSize: scaleW(18),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: scaleW(2)),
          Text(
            title,
            style: TextStyle(
              fontSize: scaleW(10),
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
