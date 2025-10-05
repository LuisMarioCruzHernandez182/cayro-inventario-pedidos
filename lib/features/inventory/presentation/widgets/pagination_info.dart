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
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    final isVerySmallScreen = screenSize.width < 320;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: screenSize.width * 0.04,
        vertical: screenSize.height * 0.004,
      ),
      padding: EdgeInsets.all(screenSize.width * 0.03),
      decoration: BoxDecoration(
        color: AppColors.blue50,
        borderRadius: BorderRadius.circular(screenSize.width * 0.03),
        border: Border.all(color: AppColors.blue100, width: 1),
      ),
      child: Row(
        children: [
          // Información de productos
          Expanded(
            child: _buildCompactItem(
              icon: Icons.inventory_2_outlined,
              title: isVerySmallScreen ? 'Productos' : 'Productos encontrados',
              value: isVerySmallScreen
                  ? '$currentProductsCount/$totalProducts'
                  : '$currentProductsCount de $totalProducts',
              screenSize: screenSize,
              isSmallScreen: isSmallScreen,
              isVerySmallScreen: isVerySmallScreen,
            ),
          ),

          // Separador vertical
          Container(
            width: 1,
            height: screenSize.height * 0.035,
            margin: EdgeInsets.symmetric(horizontal: screenSize.width * 0.015),
            color: AppColors.blue100.withOpacity(0.3),
          ),

          // Información de página
          Expanded(
            child: _buildCompactItem(
              icon: Icons.layers_outlined,
              title: isVerySmallScreen ? 'Página' : 'Página actual',
              value: isVerySmallScreen
                  ? '$currentPage/$totalPages'
                  : '$currentPage de $totalPages',
              screenSize: screenSize,
              isSmallScreen: isSmallScreen,
              isVerySmallScreen: isVerySmallScreen,
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
    required Size screenSize,
    required bool isSmallScreen,
    required bool isVerySmallScreen,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fila superior: Icono y título
        Row(
          children: [
            Icon(
              icon,
              size: isVerySmallScreen
                  ? screenSize.width * 0.035
                  : screenSize.width * 0.04,
              color: AppColors.blue600,
            ),
            SizedBox(width: screenSize.width * 0.012),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: isVerySmallScreen
                      ? screenSize.width * 0.03
                      : screenSize.width * 0.033,
                  color: AppColors.gray600,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),

        // Espacio entre título y valor
        SizedBox(height: screenSize.height * 0.002),

        // Valor
        Padding(
          padding: EdgeInsets.only(
            left: isVerySmallScreen
                ? screenSize.width * 0.045
                : screenSize.width * 0.05,
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: isVerySmallScreen
                  ? screenSize.width * 0.036
                  : screenSize.width * 0.04,
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
