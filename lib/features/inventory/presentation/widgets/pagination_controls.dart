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
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    double scaleW(double v) => v * (width / 390);
    double scaleH(double v) => v * (height / 844);

    if (totalPages <= 1) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: scaleH(16),
        horizontal: scaleW(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Botón anterior
          _buildIconButton(
            icon: Icons.chevron_left_rounded,
            isEnabled: currentPage > 1 && !isLoading,
            onTap: () => onPageChanged(currentPage - 1),
            scaleW: scaleW,
          ),

          SizedBox(width: scaleW(20)),

          Text(
            'Página $currentPage de $totalPages',
            style: TextStyle(
              fontSize: scaleW(14),
              color: AppColors.gray700,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(width: scaleW(20)),

          // Botón siguiente
          _buildIconButton(
            icon: Icons.chevron_right_rounded,
            isEnabled: currentPage < totalPages && !isLoading,
            onTap: () => onPageChanged(currentPage + 1),
            scaleW: scaleW,
          ),
        ],
      ),
    );
  }

  String _buildPageText(bool isVerySmallScreen) {
    if (isVerySmallScreen) {
      return '$currentPage / $totalPages';
    }
    return 'Página $currentPage de $totalPages';
  }

  Widget _buildIconButton({
    required IconData icon,
    required bool isEnabled,
    required VoidCallback onTap,
    required double Function(double) scaleW,
  }) {
    final buttonSize = isSmallScreen
        ? screenSize.width * 0.1
        : screenSize.width * 0.11;

    final iconSize = isSmallScreen
        ? screenSize.width * 0.05
        : screenSize.width * 0.055;

    return Container(
      width: scaleW(42),
      height: scaleW(42),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isEnabled ? AppColors.blue600 : AppColors.gray300,
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: AppColors.blue600.withValues(alpha: 0.25),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onTap : null,
          borderRadius: BorderRadius.circular(scaleW(21)),
          splashColor: Colors.white.withValues(alpha: 0.2),
          highlightColor: Colors.white.withValues(alpha: 0.1),
          child: Icon(icon, size: scaleW(22), color: Colors.white),
        ),
      ),
    );
  }
}
