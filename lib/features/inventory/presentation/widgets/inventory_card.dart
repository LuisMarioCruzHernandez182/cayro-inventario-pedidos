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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.gray900,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${product.brand.name} • ${product.category.name}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.gray600,
                          ),
                        ),
                      ],
                    ),
                  ),
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
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(
                    icon: Icons.inventory_2_outlined,
                    label: 'Stock: ${product.totalStock}',
                    color: AppColors.blue500,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    icon: Icons.palette_outlined,
                    label: '${product.variantCount} variantes',
                    color: AppColors.gray500,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildInfoChip(
                    icon: Icons.attach_money,
                    label: '\$${product.totalValue.toStringAsFixed(2)}',
                    color: AppColors.green500,
                  ),
                  const Spacer(),
                  if (product.totalReserved > 0)
                    _buildInfoChip(
                      icon: Icons.lock_outline,
                      label: 'Reservado: ${product.totalReserved}',
                      color: AppColors.orange500,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.shadowColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
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
