import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:stock_control_app/features/inventory/presentation/bloc/inventory_event.dart';
import 'package:stock_control_app/features/inventory/presentation/bloc/inventory_state.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../app/di/injection_container.dart';
import '../bloc/inventory_bloc.dart';
import '../widgets/update_stock_modal.dart';

class UpdateStockPage extends StatefulWidget {
  final String productId;

  const UpdateStockPage({super.key, required this.productId});

  @override
  State<UpdateStockPage> createState() => _UpdateStockPageState();
}

class _UpdateStockPageState extends State<UpdateStockPage> {
  final ValueNotifier<bool> isUpdating = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    double scaleW(double v) => v * (width / 390);
    double scaleH(double v) => v * (height / 844);

    return BlocProvider(
      create: (context) => sl<InventoryBloc>()
        ..add(
          LoadProductDetailWithVariants(productId: int.parse(widget.productId)),
        ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColors.blue600,
        body: SafeArea(
          child: Stack(
            children: [
              BlocListener<InventoryBloc, InventoryState>(
                listener: (context, state) {
                  if (state is InventoryLoading) {
                    isUpdating.value = true;
                  } else if (state is VariantStockUpdated ||
                      state is ProductDetailWithVariantsLoaded ||
                      state is InventoryError) {
                    isUpdating.value = false;
                  }

                  if (state is VariantStockUpdated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.green600,
                      ),
                    );
                    context.read<InventoryBloc>().add(
                      LoadProductDetailWithVariants(
                        productId: int.parse(widget.productId),
                      ),
                    );
                  } else if (state is InventoryError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.red600,
                      ),
                    );
                  }
                },
                child: BlocBuilder<InventoryBloc, InventoryState>(
                  builder: (context, state) {
                    if (state is InventoryLoading || isUpdating.value) {
                      return Container(
                        color: AppColors.white,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                color: AppColors.blue600,
                                strokeWidth: scaleW(3),
                              ),
                              SizedBox(height: scaleH(16)),
                              Text(
                                "Cargando producto...",
                                style: TextStyle(
                                  color: AppColors.blue600,
                                  fontSize: scaleW(16),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (state is InventoryError) {
                      return Container(
                        color: AppColors.blue600,
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(scaleW(20)),
                            child: Text(
                              state.message,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: scaleW(16),
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    }

                    if (state is ProductDetailWithVariantsLoaded) {
                      return Column(
                        children: [
                          _buildHeader(context, scaleW, scaleH),
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(scaleW(32)),
                                  topRight: Radius.circular(scaleW(32)),
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(
                                  scaleW(24),
                                  scaleH(20),
                                  scaleW(24),
                                  scaleH(16),
                                ),
                                child: _buildProductContent(
                                  context,
                                  state.product,
                                  state.variants,
                                  scaleW,
                                  scaleH,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    return Container(
                      color: AppColors.blue600,
                      child: const SizedBox.shrink(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    double Function(double) scaleW,
    double Function(double) scaleH,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: scaleW(24),
        vertical: scaleH(16),
      ),
      child: Row(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () {
                context.pop(true);
              },
              icon: Icon(
                Icons.arrow_back,
                color: AppColors.blue600,
                size: scaleW(24),
              ),
            ),
          ),
          SizedBox(width: scaleW(12)),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Actualizar Stock',
                  style: TextStyle(
                    fontSize: scaleW(26),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: scaleH(4)),
                Text(
                  'Gestión de inventario por variante',
                  style: TextStyle(
                    fontSize: scaleW(14),
                    color: Colors.white70,
                    fontWeight: FontWeight.w300,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          SizedBox(width: scaleW(48)),
        ],
      ),
    );
  }

  Widget _buildProductContent(
    BuildContext context,
    dynamic product,
    List variants,
    double Function(double) scaleW,
    double Function(double) scaleH,
  ) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  product.name,
                  style: TextStyle(
                    fontSize: scaleW(18),
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray900,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                product.gender.name,
                style: TextStyle(
                  fontSize: scaleW(16),
                  color: AppColors.blue600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: scaleH(8)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  '${product.brand.name} • ${product.category.name}',
                  style: TextStyle(
                    fontSize: scaleW(14),
                    color: AppColors.gray600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                product.sleeve.name,
                style: TextStyle(
                  fontSize: scaleW(14),
                  color: AppColors.blue600,
                ),
              ),
            ],
          ),
          SizedBox(height: scaleH(6)),
          Text(
            product.description,
            style: TextStyle(fontSize: scaleW(14), color: AppColors.gray600),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: scaleH(24)),

          Container(
            padding: EdgeInsets.all(scaleW(16)),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(scaleW(12)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    '${product.totalStock}',
                    'Stock Total',
                    AppColors.blue600,
                    scaleW,
                    scaleH,
                  ),
                ),
                SizedBox(width: scaleW(20)),
                Expanded(
                  child: _buildStatCard(
                    '${product.variantCount}',
                    'Variantes',
                    AppColors.green600,
                    scaleW,
                    scaleH,
                  ),
                ),
                SizedBox(width: scaleW(20)),
                Expanded(
                  child: _buildStatCard(
                    '\$${product.totalValue.toStringAsFixed(0)}',
                    'Valor Total',
                    Colors.purple.shade600,
                    scaleW,
                    scaleH,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: scaleH(32)),

          Text(
            'Variantes del Producto',
            style: TextStyle(
              fontSize: scaleW(18),
              fontWeight: FontWeight.bold,
              color: AppColors.gray900,
            ),
          ),
          SizedBox(height: scaleH(16)),

          Column(
            children: variants
                .map<Widget>(
                  (variant) =>
                      _buildVariantCard(context, variant, scaleW, scaleH),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String value,
    String title,
    Color textColor,
    double Function(double) scaleW,
    double Function(double) scaleH,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: scaleW(22),
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        SizedBox(height: scaleH(4)),
        Text(
          title,
          style: TextStyle(
            fontSize: scaleW(12),
            color: AppColors.gray600,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildVariantCard(
    BuildContext context,
    dynamic variant,
    double Function(double) scaleW,
    double Function(double) scaleH,
  ) {
    final String? imageUrl =
        (variant.images != null && variant.images.isNotEmpty)
        ? variant.images.first.url
        : null;

    return Container(
      margin: EdgeInsets.only(bottom: scaleH(16)),
      padding: EdgeInsets.all(scaleW(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(scaleW(12)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(scaleW(8)),
                child: imageUrl != null
                    ? Image.network(
                        imageUrl,
                        width: scaleW(60),
                        height: scaleW(60),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: scaleW(60),
                            height: scaleW(60),
                            color: AppColors.gray100,
                            child: Icon(
                              Icons.broken_image,
                              color: AppColors.gray400,
                              size: scaleW(24),
                            ),
                          );
                        },
                      )
                    : Container(
                        width: scaleW(60),
                        height: scaleW(60),
                        color: AppColors.blue100,
                        child: Icon(
                          Icons.checkroom,
                          color: AppColors.blue600,
                          size: scaleW(28),
                        ),
                      ),
              ),
              SizedBox(width: scaleW(12)),
              Container(
                width: scaleW(20),
                height: scaleW(20),
                decoration: BoxDecoration(
                  color: Color(
                    int.parse(variant.color.hexValue.replaceFirst('#', '0xFF')),
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gray300),
                ),
              ),
              SizedBox(width: scaleW(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${variant.color.name} - ${variant.size.name}',
                      style: TextStyle(
                        fontSize: scaleW(16),
                        fontWeight: FontWeight.bold,
                        color: AppColors.gray900,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: scaleH(2)),
                    Text(
                      'Código:',
                      style: TextStyle(
                        fontSize: scaleW(12),
                        color: AppColors.gray600,
                      ),
                    ),
                    Text(
                      variant.barcode,
                      style: TextStyle(
                        fontSize: scaleW(12),
                        color: AppColors.gray600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Text(
                '\$${variant.price.toInt()}',
                style: TextStyle(
                  fontSize: scaleW(16),
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray900,
                ),
              ),
            ],
          ),
          SizedBox(height: scaleH(16)),
          Row(
            children: [
              _buildStockValue(
                '${variant.stock}',
                'Stock',
                AppColors.blue600,
                scaleW,
                scaleH,
              ),
              _buildStockValue(
                '${variant.reserved}',
                'Reservado',
                Colors.orange.shade600,
                scaleW,
                scaleH,
              ),
              _buildStockValue(
                '${variant.available}',
                'Disponible',
                AppColors.green600,
                scaleW,
                scaleH,
              ),
            ],
          ),
          SizedBox(height: scaleH(16)),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                _showStockAdjustmentModal(context, variant);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue600,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: scaleW(24),
                  vertical: scaleH(12),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(scaleW(8)),
                ),
              ),
              child: Text('Actualizar', style: TextStyle(fontSize: scaleW(14))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockValue(
    String value,
    String label,
    Color color,
    double Function(double) scaleW,
    double Function(double) scaleH,
  ) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: scaleW(20),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: scaleH(4)),
          Text(
            label,
            style: TextStyle(fontSize: scaleW(12), color: AppColors.gray600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showStockAdjustmentModal(BuildContext context, dynamic variant) {
    final inventoryBloc = context.read<InventoryBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return BlocProvider.value(
          value: inventoryBloc,
          child: UpdateStockModal(
            variant: variant,
            onUpdate: (adjustmentType, quantity, reason) {
              inventoryBloc.add(
                UpdateVariantStock(
                  variantId: variant.id,
                  adjustmentType: adjustmentType,
                  quantity: quantity,
                  reason: reason,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
