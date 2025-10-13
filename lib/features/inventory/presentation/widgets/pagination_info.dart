import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class PaginationInfo extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalProducts;
  final int currentProductsCount;
  final bool hasReachedMax;
  final bool isLoadingMore;

  const PaginationInfo({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.totalProducts,
    required this.currentProductsCount,
    required this.hasReachedMax,
    required this.isLoadingMore,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    double scaleW(double v) => v * (width / 390);
    double scaleH(double v) => v * (height / 844);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: scaleW(16), vertical: scaleH(4)),
      padding: EdgeInsets.all(scaleW(10)),
      decoration: BoxDecoration(
        color: AppColors.blue50,
        borderRadius: BorderRadius.circular(scaleW(12)),
        border: Border.all(color: AppColors.blue100, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.blue600.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Información de productos
          Expanded(
            child: _buildCompactItem(
              icon: Icons.inventory_2_outlined,
              title: 'Productos encontrados',
              value: '$currentProductsCount de $totalProducts',
              scaleW: scaleW,
            ),
          ),

          // Separador vertical
          Container(
            width: 1,
            height: scaleH(32),
            margin: EdgeInsets.symmetric(horizontal: scaleW(8)),
            color: AppColors.blue100.withValues(alpha: 0.4),
          ),

          // Información de página
          Expanded(
            child: _buildCompactItem(
              icon: Icons.layers_outlined,
              title: 'Página actual',
              value: '$currentPage de $totalPages',
              scaleW: scaleW,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactItem({
    required IconData icon,
    required String title,
    required String value,
    required double Function(double) scaleW,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fila superior: Icono y título
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: scaleW(18), color: AppColors.blue600),
            SizedBox(width: scaleW(6)),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: scaleW(13),
                  color: AppColors.gray600,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: scaleW(3)),

        Padding(
          padding: EdgeInsets.only(left: scaleW(24)),
          child: Text(
            value,
            style: TextStyle(
              fontSize: scaleW(15),
              color: AppColors.blue600,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
