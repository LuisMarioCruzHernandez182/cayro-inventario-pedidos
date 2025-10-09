import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/product_entity.dart';

class InventoryCard extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback? onTap;

  const InventoryCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    final stockStatus = _getStockStatus(product.totalAvailable);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(screenSize.width * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fila superior: Nombre, marca y estado de stock
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: TextStyle(
                            fontSize: isSmallScreen
                                ? screenSize.width * 0.042
                                : screenSize.width * 0.045,
                            fontWeight: FontWeight.bold,
                            color: AppColors.gray900,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: screenSize.height * 0.004),
                        Text(
                          '${product.brand.name} • ${product.category.name}',
                          style: TextStyle(
                            fontSize: isSmallScreen
                                ? screenSize.width * 0.035
                                : screenSize.width * 0.038,
                            color: AppColors.gray600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: screenSize.width * 0.02),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: stockStatus.backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.shadowColor),
                    ),
                    child: Text(
                      stockStatus.text,
                      style: TextStyle(
                        color: stockStatus.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: screenSize.height * 0.012),

              // Primera fila de chips
              _buildChipsRow(
                screenSize: screenSize,
                isSmallScreen: isSmallScreen,
                isVerySmallScreen: isVerySmallScreen,
              ),

              SizedBox(height: screenSize.height * 0.008),

              // Segunda fila de chips
              _buildSecondChipsRow(
                screenSize: screenSize,
                isSmallScreen: isSmallScreen,
                isVerySmallScreen: isVerySmallScreen,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChipsRow({
    required Size screenSize,
    required bool isSmallScreen,
    required bool isVerySmallScreen,
  }) {
    return Wrap(
      spacing: screenSize.width * 0.02,
      runSpacing: screenSize.height * 0.008,
      children: [
        _buildInfoChip(
          icon: Icons.inventory_2_outlined,
          label: 'Stock: ${product.totalStock}',
          color: AppColors.blue500,
          screenSize: screenSize,
          isSmallScreen: isSmallScreen,
          isVerySmallScreen: isVerySmallScreen,
        ),
        _buildInfoChip(
          icon: Icons.palette_outlined,
          label: '${product.variantCount} variantes',
          color: AppColors.gray500,
          screenSize: screenSize,
          isSmallScreen: isSmallScreen,
          isVerySmallScreen: isVerySmallScreen,
        ),
      ],
    );
  }

  Widget _buildSecondChipsRow({
    required Size screenSize,
    required bool isSmallScreen,
    required bool isVerySmallScreen,
  }) {
    return Wrap(
      spacing: screenSize.width * 0.02,
      runSpacing: screenSize.height * 0.008,
      alignment: WrapAlignment.spaceBetween,
      children: [
        _buildInfoChip(
          icon: Icons.attach_money,
          label: '\$${product.totalValue.toStringAsFixed(2)}',
          color: AppColors.green500,
          screenSize: screenSize,
          isSmallScreen: isSmallScreen,
          isVerySmallScreen: isVerySmallScreen,
        ),
        if (product.totalReserved > 0)
          _buildInfoChip(
            icon: Icons.lock_outline,
            label: 'Res: ${product.totalReserved}',
            color: AppColors.orange500,
            screenSize: screenSize,
            isSmallScreen: isSmallScreen,
            isVerySmallScreen: isVerySmallScreen,
          ),
      ],
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
    required Size screenSize,
    required bool isSmallScreen,
    required bool isVerySmallScreen,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenSize.width * 0.02,
        vertical: screenSize.height * 0.004,
      ),
      decoration: BoxDecoration(
        color: AppColors.shadowColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: isVerySmallScreen
                ? screenSize.width * 0.032
                : screenSize.width * 0.035,
            color: color,
          ),
          SizedBox(width: screenSize.width * 0.01),
          Text(
            label,
            style: TextStyle(
              fontSize: isVerySmallScreen
                  ? screenSize.width * 0.028
                  : screenSize.width * 0.032,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  StockStatus _getStockStatus(int stock) {
    if (stock == 0) {
      return StockStatus(
        text: 'Agotado',
        color: AppColors.red500,
        backgroundColor: AppColors.red50,
      );
    } else if (stock <= 5) {
      return StockStatus(
        text: 'Poco Stock',
        color: AppColors.orange500,
        backgroundColor: AppColors.orange50,
      );
    } else {
      return StockStatus(
        text: 'En Stock',
        color: AppColors.green500,
        backgroundColor: AppColors.green50,
      );
    }
  }
}

class StockStatus {
  final String text;
  final Color color;
  final Color backgroundColor;

  StockStatus({
    required this.text,
    required this.color,
    required this.backgroundColor,
  });
}
