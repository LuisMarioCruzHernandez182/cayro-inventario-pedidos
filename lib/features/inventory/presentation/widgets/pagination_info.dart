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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.blue50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.blue100, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildCompactItem(
              icon: Icons.inventory_2_outlined,
              title: 'Productos encontrados',
              value: '$currentProductsCount de $totalProducts',
            ),
          ),

          Container(
            width: 1,
            height: 35,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            color: AppColors.blue100.withValues(alpha: 0.3),
          ),

          Expanded(
            child: _buildCompactItem(
              icon: Icons.layers_outlined,
              title: 'Página actual',
              value: '$currentPage de $totalPages',
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
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.blue600),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.gray600,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.only(left: 22),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.blue600,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
