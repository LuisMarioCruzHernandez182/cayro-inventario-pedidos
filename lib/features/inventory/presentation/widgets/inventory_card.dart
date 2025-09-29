import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/product_entity.dart';

class InventoryCard extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback? onTap;

  const InventoryCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStockStatusColor(product.totalAvailable),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStockStatusText(product.totalAvailable),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
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
        color: color.withValues(alpha: 0.1),
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

  Color _getStockStatusColor(int stock) {
    if (stock == 0) return AppColors.red500;
    if (stock <= 5) return AppColors.orange500;
    return AppColors.green500;
  }

  String _getStockStatusText(int stock) {
    if (stock == 0) return 'Sin stock';
    if (stock <= 5) return 'Poco stock';
    return 'En stock';
  }
}
