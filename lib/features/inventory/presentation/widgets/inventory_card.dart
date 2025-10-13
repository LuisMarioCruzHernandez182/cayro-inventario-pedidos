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

    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    double scaleW(double v) => v * (width / 390);
    double scaleH(double v) => v * (height / 844);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: scaleW(16), vertical: scaleH(8)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(scaleW(16)),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(scaleW(16)),
        child: Padding(
          padding: EdgeInsets.all(scaleW(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                            fontSize: scaleW(16),
                            fontWeight: FontWeight.bold,
                            color: AppColors.gray900,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: scaleH(4)),
                        Text(
                          '${product.brand.name} • ${product.category.name}',
                          style: TextStyle(
                            fontSize: scaleW(13),
                            color: AppColors.gray600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: scaleW(10),
                      vertical: scaleH(6),
                    ),
                    decoration: BoxDecoration(
                      color: stockStatus.backgroundColor,
                      borderRadius: BorderRadius.circular(scaleW(8)),
                      border: Border.all(
                        color: stockStatus.color.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Text(
                      stockStatus.text,
                      style: TextStyle(
                        color: stockStatus.color,
                        fontSize: scaleW(12),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: scaleH(12)),

              Row(
                children: [
                  _buildInfoChip(
                    icon: Icons.inventory_2_outlined,
                    label: 'Stock: ${product.totalStock}',
                    color: AppColors.blue600,
                    scaleW: scaleW,
                  ),
                  SizedBox(width: scaleW(8)),
                  _buildInfoChip(
                    icon: Icons.palette_outlined,
                    label: '${product.variantCount} variantes',
                    color: AppColors.gray600,
                    scaleW: scaleW,
                  ),
                ],
              ),

              SizedBox(height: scaleH(8)),

              Row(
                children: [
                  _buildInfoChip(
                    icon: Icons.attach_money,
                    label: '\$${product.totalValue.toStringAsFixed(2)}',
                    color: AppColors.green600,
                    scaleW: scaleW,
                  ),
                  const Spacer(),
                  if (product.totalReserved > 0)
                    _buildInfoChip(
                      icon: Icons.lock_outline,
                      label: 'Reservado: ${product.totalReserved}',
                      color: AppColors.amber600,
                      scaleW: scaleW,
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
    required double Function(double) scaleW,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: scaleW(8), vertical: scaleW(4)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(scaleW(8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: scaleW(14), color: color),
          SizedBox(width: scaleW(4)),
          Text(
            label,
            style: TextStyle(
              fontSize: scaleW(12),
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
        color: AppColors.red600,
        backgroundColor: AppColors.red50,
      );
    } else if (stock <= 5) {
      return StockStatus(
        text: 'Poco Stock',
        color: AppColors.amber600,
        backgroundColor: AppColors.amber50,
      );
    } else {
      return StockStatus(
        text: 'En Stock',
        color: AppColors.green600,
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
