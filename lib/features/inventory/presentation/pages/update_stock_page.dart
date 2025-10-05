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
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<InventoryBloc>()
        ..add(
          LoadProductDetailWithVariants(productId: int.parse(widget.productId)),
        ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.blue600, AppColors.blue500, AppColors.blue400],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // 🔹 Encabezado
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () => context.pop(),
                            icon: const Icon(
                              Icons.arrow_back,
                              color: AppColors.blue600,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Actualizar Stock',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Gestión de inventario por variante',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w300,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                ),

                // 🔹 Contenido
                Expanded(
                  flex: 6,
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                      child: BlocListener<InventoryBloc, InventoryState>(
                        listener: (context, state) {
                          if (state is VariantStockUpdated) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(state.message),
                                backgroundColor: AppColors.green600,
                              ),
                            );
                            // 🔁 Recargar variantes actualizadas
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
                            if (state is InventoryLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            // ✅ Nuevo estado combinado
                            if (state is ProductDetailWithVariantsLoaded) {
                              return _buildProductContent(
                                context,
                                state.product,
                                state.variants,
                              );
                            }

                            if (state is InventoryError) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: 64,
                                      color: AppColors.red500,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Error cargando producto',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: AppColors.red600,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      state.message,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.gray600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: () {
                                        context.read<InventoryBloc>().add(
                                          LoadProductDetailWithVariants(
                                            productId: int.parse(
                                              widget.productId,
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Text('Reintentar'),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔹 Sección del contenido del producto y variantes
  Widget _buildProductContent(BuildContext context, product, List variants) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Encabezado del producto
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray900,
                  ),
                ),
              ),
              Text(
                product.gender.name,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.blue600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${product.brand.name} • ${product.category.name}',
                style: const TextStyle(fontSize: 14, color: AppColors.gray600),
              ),
              Text(
                product.sleeve.name,
                style: const TextStyle(fontSize: 14, color: AppColors.blue600),
              ),
            ],
          ),

          const SizedBox(height: 4),
          Text(
            product.description,
            style: const TextStyle(fontSize: 14, color: AppColors.gray600),
          ),

          const SizedBox(height: 24),

          // 🔹 Estadísticas del producto
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 10,
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
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildStatCard(
                    '${product.variantCount}',
                    'Variantes',
                    AppColors.green600,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildStatCard(
                    '\$${product.totalValue.toStringAsFixed(0)}',
                    'Valor Total',
                    Colors.purple.shade600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          const Text(
            'Variantes del Producto',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: 16),

          Column(
            children: (variants)
                .map<Widget>((variant) => _buildVariantCard(context, variant))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String title, Color textColor) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.gray600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildVariantCard(BuildContext context, variant) {
    // ✅ Detectar si la variante tiene imágenes
    final String? imageUrl =
        (variant.images != null && variant.images.isNotEmpty)
        ? variant.images.first.url
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
              // 🔹 Imagen de la variante (o ícono si no hay imagen)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageUrl != null
                    ? Image.network(
                        imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 60,
                            height: 60,
                            color: AppColors.gray100,
                            child: const Icon(
                              Icons.broken_image,
                              color: AppColors.gray400,
                            ),
                          );
                        },
                      )
                    : Container(
                        width: 60,
                        height: 60,
                        color: AppColors.blue100,
                        child: const Icon(
                          Icons.checkroom,
                          color: AppColors.blue600,
                          size: 28,
                        ),
                      ),
              ),
              const SizedBox(width: 12),

              // 🔹 Indicador de color de la variante
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Color(
                    int.parse(variant.color.hexValue.replaceFirst('#', '0xFF')),
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gray300),
                ),
              ),
              const SizedBox(width: 12),

              // 🔹 Descripción breve
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${variant.color.name} - ${variant.size.name}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gray900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Código:',
                      style: TextStyle(fontSize: 12, color: AppColors.gray600),
                    ),
                    Text(
                      variant.barcode,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.gray600,
                      ),
                    ),
                  ],
                ),
              ),

              // 🔹 Precio y estado del stock
              // 🔹 Precio y estado del stock
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${variant.price.toInt()}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gray900,
                    ),
                  ),

                  // 🔹 Etiqueta de estado de stock
                  Builder(
                    builder: (context) {
                      String stockLabel = '';
                      Color bgColor = AppColors.gray200;
                      Color textColor = AppColors.gray700;

                      if (variant.stock > 5) {
                        stockLabel = 'En stock';
                        bgColor = AppColors.green100;
                        textColor = AppColors.green600;
                      } else if (variant.stock > 0 && variant.stock <= 5) {
                        stockLabel = 'Poco stock';
                        bgColor = Colors.orange.shade100;
                        textColor = Colors.orange.shade700;
                      } else {
                        stockLabel = 'Sin stock';
                        bgColor = AppColors.red100;
                        textColor = AppColors.red600;
                      }

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          stockLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 🔹 Stock, reservado y disponible
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${variant.stock}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.blue600,
                      ),
                    ),
                    const Text(
                      'Stock',
                      style: TextStyle(fontSize: 12, color: AppColors.gray600),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${variant.reserved}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade600,
                      ),
                    ),
                    const Text(
                      'Reservado',
                      style: TextStyle(fontSize: 12, color: AppColors.gray600),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${variant.available}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.green600,
                      ),
                    ),
                    const Text(
                      'Disponible',
                      style: TextStyle(fontSize: 12, color: AppColors.gray600),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 🔹 Botón de actualizar stock
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  _showStockAdjustmentModal(context, variant);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Actualizar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showStockAdjustmentModal(BuildContext context, variant) {
    // Guarda el bloc actual antes de abrir el modal
    final inventoryBloc = context.read<InventoryBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        // Inyectamos el mismo bloc dentro del bottomsheet
        return BlocProvider.value(
          value: inventoryBloc,
          child: UpdateStockModal(
            variant: variant,
            onUpdate: (adjustmentType, quantity, reason) {
              // 🚀 Llamamos directamente al bloc, sin usar context.read()
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
