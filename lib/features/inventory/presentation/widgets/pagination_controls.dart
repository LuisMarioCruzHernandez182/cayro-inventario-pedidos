import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final bool isLoading;
  final Function(int) onPageChanged;

  const PaginationControls({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.isLoading,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIconButton(
            icon: Icons.chevron_left_rounded,
            isEnabled: currentPage > 1 && !isLoading,
            onTap: () => onPageChanged(currentPage - 1),
          ),

          const SizedBox(width: 16),

          Text(
            'Página $currentPage de $totalPages',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.gray700,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(width: 16),

          _buildIconButton(
            icon: Icons.chevron_right_rounded,
            isEnabled: currentPage < totalPages && !isLoading,
            onTap: () => onPageChanged(currentPage + 1),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isEnabled ? AppColors.blue500 : Colors.grey.shade300,
        shape: BoxShape.circle,
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: AppColors.blue500.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onTap : null,
          borderRadius: BorderRadius.circular(20),
          child: Icon(icon, size: 20, color: Colors.white),
        ),
      ),
    );
  }
}
