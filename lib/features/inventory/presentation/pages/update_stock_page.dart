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
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return BlocProvider(
      create: (context) => sl<InventoryBloc>()
        ..add(
          LoadProductDetailWithVariants(productId: int.parse(widget.productId)),
        ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            BlocListener<InventoryBloc, InventoryState>(
              listener: (context, state) {
                // 🔹 Control del loader igual que en OrderDetailPage
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
                  if (state is InventoryLoading || isUpdating.value) {
                    return const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: AppColors.blue600),
                          SizedBox(height: 16),
                          Text(
                            "Cargando producto...",
                            style: TextStyle(
                              color: AppColors.blue600,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // 🔹 Error
                  if (state is InventoryError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          state.message,
                          style: const TextStyle(
                            color: AppColors.red500,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  // 🔹 Contenido cargado
                  if (state is ProductDetailWithVariantsLoaded) {
                    return Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.blue600,
                            AppColors.blue500,
                            AppColors.blue400,
                          ],
                        ),
                      ),
                      child: SafeArea(
                        child: Column(
                          children: [
                            _buildHeader(context),
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
                                  padding: const EdgeInsets.fromLTRB(
                                    24,
                                    20,
                                    24,
                                    16,
                                  ),
                                  child: _buildProductContent(
                                    context,
                                    state.product,
                                    state.variants,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Expanded(
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
                onPressed: () => context.pop(true),
                icon: const Icon(Icons.arrow_back, color: AppColors.blue600),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Actualizar Stock',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
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
    );
  }

  Widget _buildProductContent(BuildContext context, product, List variants) {
  Widget _buildProductContent(
    BuildContext context,
    product,
    variants,
    Size screenSize,
    bool isSmallScreen,
  ) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Encabezado producto
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  product.name,
                  style: TextStyle(
                    fontSize: isSmallScreen
                        ? screenSize.width * 0.045
                        : screenSize.width * 0.05,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray900,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                product.gender.name,
                style: TextStyle(
                  fontSize: isSmallScreen
                      ? screenSize.width * 0.038
                      : screenSize.width * 0.042,
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
              Flexible(
                child: Text(
                  '${product.brand.name} • ${product.category.name}',
                  style: TextStyle(
                    fontSize: isSmallScreen
                        ? screenSize.width * 0.033
                        : screenSize.width * 0.036,
                    color: AppColors.gray600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                product.sleeve.name,
                style: TextStyle(
                  fontSize: isSmallScreen
                      ? screenSize.width * 0.033
                      : screenSize.width * 0.036,
                  color: AppColors.blue600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(height: screenSize.height * 0.004),

          // Product description
          Text(
            product.description,
            style: TextStyle(
              fontSize: isSmallScreen
                  ? screenSize.width * 0.033
                  : screenSize.width * 0.036,
              color: AppColors.gray600,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 24),

          // 🔹 Estadísticas
          Container(
            padding: EdgeInsets.all(screenSize.width * 0.04),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(screenSize.width * 0.03),
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
                    screenSize,
                    isSmallScreen,
                  ),
                ),
                SizedBox(width: screenSize.width * 0.04),
                Expanded(
                  child: _buildStatCard(
                    '${product.variantCount}',
                    'Variantes',
                    AppColors.green600,
                    screenSize,
                    isSmallScreen,
                  ),
                ),
                SizedBox(width: screenSize.width * 0.04),
                Expanded(
                  child: _buildStatCard(
                    '\$${product.totalValue.toStringAsFixed(0)}',
                    'Valor Total',
                    Colors.purple.shade600,
                    screenSize,
                    isSmallScreen,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Variantes del Producto',
            style: TextStyle(
              fontSize: isSmallScreen
                  ? screenSize.width * 0.045
                  : screenSize.width * 0.05,
              fontWeight: FontWeight.bold,
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: variants
                .map<Widget>((variant) => _buildVariantCard(context, variant))
                .toList(),
          ),

          SizedBox(height: screenSize.height * 0.016),

          // Variants list
          BlocBuilder<InventoryBloc, InventoryState>(
            builder: (context, state) {
              if (state is ProductVariantsLoaded) {
                return Column(
                  children: state.variants
                      .map(
                        (variant) => _buildVariantCard(
                          context,
                          variant,
                          screenSize,
                          isSmallScreen,
                        ),
                      )
                      .toList(),
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVariantsContent(
    BuildContext context,
    variants,
    Size screenSize,
    bool isSmallScreen,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Variantes del Producto',
            style: TextStyle(
              fontSize: isSmallScreen
                  ? screenSize.width * 0.045
                  : screenSize.width * 0.05,
              fontWeight: FontWeight.bold,
              color: AppColors.gray900,
            ),
          ),
          SizedBox(height: screenSize.height * 0.016),
          ...variants
              .map(
                (variant) => _buildVariantCard(
                  context,
                  variant,
                  screenSize,
                  isSmallScreen,
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String value,
    String title,
    Color textColor,
    Size screenSize,
    bool isSmallScreen,
  ) {
    return Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              fontSize: isSmallScreen
                  ? screenSize.width * 0.055
                  : screenSize.width * 0.065,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
        SizedBox(height: screenSize.height * 0.004),
        Text(
          title,
          style: TextStyle(
            fontSize: isSmallScreen
                ? screenSize.width * 0.028
                : screenSize.width * 0.032,
            fontWeight: FontWeight.w600,
            color: AppColors.gray600,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildVariantCard(BuildContext context, variant) {
    final String? imageUrl =
        (variant.images != null && variant.images.isNotEmpty)
        ? variant.images.first.url
        : null;

  Widget _buildVariantCard(
    BuildContext context,
    variant,
    Size screenSize,
    bool isSmallScreen,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: screenSize.height * 0.016),
      padding: EdgeInsets.all(screenSize.width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenSize.width * 0.03),
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
          // Variant header
          Row(
            children: [
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
              Container(
                width: isSmallScreen
                    ? screenSize.width * 0.12
                    : screenSize.width * 0.14,
                height: isSmallScreen
                    ? screenSize.width * 0.12
                    : screenSize.width * 0.14,
                decoration: BoxDecoration(
                  color: AppColors.blue100,
                  borderRadius: BorderRadius.circular(screenSize.width * 0.02),
                ),
                child: Center(
                  child: Icon(
                    Icons.checkroom,
                    color: AppColors.blue600,
                    size: isSmallScreen
                        ? screenSize.width * 0.06
                        : screenSize.width * 0.065,
                  ),
                ),
              ),

              SizedBox(width: screenSize.width * 0.03),

              // Color indicator
              Container(
                width: isSmallScreen
                    ? screenSize.width * 0.05
                    : screenSize.width * 0.06,
                height: isSmallScreen
                    ? screenSize.width * 0.05
                    : screenSize.width * 0.06,
                decoration: BoxDecoration(
                  color: Color(
                    int.parse(variant.color.hexValue.replaceFirst('#', '0xFF')),
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gray300),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${variant.color.name} - ${variant.size.name}',
                      style: TextStyle(
                        fontSize: isSmallScreen
                            ? screenSize.width * 0.038
                            : screenSize.width * 0.042,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gray900,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    const Text(
                    SizedBox(height: screenSize.height * 0.002),
                    Text(
                      'Código:',
                      style: TextStyle(
                        fontSize: isSmallScreen
                            ? screenSize.width * 0.028
                            : screenSize.width * 0.03,
                        color: AppColors.gray600,
                      ),
                    ),
                    Text(
                      variant.barcode,
                      style: TextStyle(
                        fontSize: isSmallScreen
                            ? screenSize.width * 0.028
                            : screenSize.width * 0.03,
                        color: AppColors.gray600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${variant.price.toInt()}',
                    style: TextStyle(
                      fontSize: isSmallScreen
                          ? screenSize.width * 0.038
                          : screenSize.width * 0.042,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gray900,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${variant.stock}',
                      style: TextStyle(
                        fontSize: isSmallScreen
                            ? screenSize.width * 0.045
                            : screenSize.width * 0.05,
                        fontWeight: FontWeight.bold,
                        color: AppColors.blue600,
                      ),
                    ),
                    Text(
                      'Stock',
                      style: TextStyle(
                        fontSize: isSmallScreen
                            ? screenSize.width * 0.028
                            : screenSize.width * 0.03,
                        color: AppColors.gray600,
                      ),
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
                        fontSize: isSmallScreen
                            ? screenSize.width * 0.045
                            : screenSize.width * 0.05,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade600,
                      ),
                    ),
                    Text(
                      'Reservado',
                      style: TextStyle(
                        fontSize: isSmallScreen
                            ? screenSize.width * 0.028
                            : screenSize.width * 0.03,
                        color: AppColors.gray600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${variant.available}',
                      style: TextStyle(
                        fontSize: isSmallScreen
                            ? screenSize.width * 0.045
                            : screenSize.width * 0.05,
                        fontWeight: FontWeight.bold,
                        color: AppColors.green600,
                      ),
                    ),
                    Text(
                      'Disponible',
                      style: TextStyle(
                        fontSize: isSmallScreen
                            ? screenSize.width * 0.028
                            : screenSize.width * 0.03,
                        color: AppColors.gray600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen
                        ? screenSize.width * 0.05
                        : screenSize.width * 0.06,
                    vertical: isSmallScreen
                        ? screenSize.height * 0.012
                        : screenSize.height * 0.014,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      screenSize.width * 0.02,
                    ),
                  ),
                ),
                child: Text(
                  'Actualizar',
                  style: TextStyle(
                    fontSize: isSmallScreen
                        ? screenSize.width * 0.035
                        : screenSize.width * 0.038,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    InventoryError state,
    BuildContext context,
    Size screenSize,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: screenSize.width * 0.15,
            color: AppColors.red500,
          ),
          SizedBox(height: screenSize.height * 0.02),
          Text(
            'Error cargando producto',
            style: TextStyle(
              fontSize: screenSize.width * 0.04,
              color: AppColors.red600,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: screenSize.height * 0.01),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.1),
            child: Text(
              state.message,
              style: TextStyle(
                fontSize: screenSize.width * 0.035,
                color: AppColors.gray600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: screenSize.height * 0.02),
          ElevatedButton(
            onPressed: () {
              context.read<InventoryBloc>().add(
                LoadProductById(productId: int.parse(widget.productId)),
              );
            },
            child: Text(
              'Reintentar',
              style: TextStyle(fontSize: screenSize.width * 0.04),
            ),
          ),
        ],
      ),
    );
  }

  void _showStockAdjustmentModal(BuildContext context, variant) {
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
