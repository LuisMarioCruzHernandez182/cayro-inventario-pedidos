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

    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    final isVerySmallScreen = screenSize.width < 320;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: screenSize.height * 0.016,
        horizontal: screenSize.width * 0.05,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Botón anterior
          _buildIconButton(
            icon: Icons.chevron_left_rounded,
            isEnabled: currentPage > 1 && !isLoading,
            onTap: () => onPageChanged(currentPage - 1),
            screenSize: screenSize,
            isSmallScreen: isSmallScreen,
          ),

          SizedBox(width: screenSize.width * 0.04),

          // Información de página
          Flexible(
            child: Text(
              _buildPageText(isVerySmallScreen),
              style: TextStyle(
                fontSize: isSmallScreen
                    ? screenSize.width * 0.035
                    : screenSize.width * 0.038,
                color: AppColors.gray700,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          SizedBox(width: screenSize.width * 0.04),

          // Botón siguiente
          _buildIconButton(
            icon: Icons.chevron_right_rounded,
            isEnabled: currentPage < totalPages && !isLoading,
            onTap: () => onPageChanged(currentPage + 1),
            screenSize: screenSize,
            isSmallScreen: isSmallScreen,
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
    required Size screenSize,
    required bool isSmallScreen,
  }) {
    final buttonSize = isSmallScreen
        ? screenSize.width * 0.1
        : screenSize.width * 0.11;

    final iconSize = isSmallScreen
        ? screenSize.width * 0.05
        : screenSize.width * 0.055;

    return Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        color: isEnabled ? AppColors.blue500 : Colors.grey.shade300,
        shape: BoxShape.circle,
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: AppColors.blue500.withOpacity(0.3),
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
          borderRadius: BorderRadius.circular(buttonSize / 2),
          child: Icon(icon, size: iconSize, color: Colors.white),
        ),
      ),
    );
  }
}
