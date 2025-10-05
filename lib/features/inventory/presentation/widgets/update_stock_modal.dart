import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../domain/entities/product_variant_entity.dart';

class UpdateStockModal extends StatefulWidget {
  final ProductVariantEntity variant;
  final Function(String adjustmentType, int quantity, String? reason) onUpdate;

  const UpdateStockModal({
    super.key,
    required this.variant,
    required this.onUpdate,
  });

  @override
  State<UpdateStockModal> createState() => _UpdateStockModalState();
}

class _UpdateStockModalState extends State<UpdateStockModal> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _reasonController = TextEditingController();
  String _adjustmentType = 'ADD';

  @override
  void dispose() {
    _quantityController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _handleUpdate() {
    if (!_formKey.currentState!.validate()) return;

    final quantity = int.parse(_quantityController.text);
    final reason = _reasonController.text.trim().isEmpty
        ? null
        : _reasonController.text.trim();

    widget.onUpdate(_adjustmentType, quantity, reason);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenSize.width * 0.06),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con título y botón cerrar
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Actualizar Stock',
                      style: TextStyle(
                        fontSize: isSmallScreen
                            ? screenSize.width * 0.06
                            : screenSize.width * 0.065,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gray900,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: AppColors.gray600,
                      size: isSmallScreen
                          ? screenSize.width * 0.06
                          : screenSize.width * 0.065,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenSize.height * 0.016),

              // Información del producto
              Container(
                padding: EdgeInsets.all(screenSize.width * 0.04),
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  borderRadius: BorderRadius.circular(screenSize.width * 0.03),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Producto: ${widget.variant.color.name} - ${widget.variant.size.name}',
                      style: TextStyle(
                        fontSize: isSmallScreen
                            ? screenSize.width * 0.04
                            : screenSize.width * 0.045,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray900,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: screenSize.height * 0.004),
                    Text(
                      'Stock actual: ${widget.variant.stock}',
                      style: TextStyle(
                        fontSize: isSmallScreen
                            ? screenSize.width * 0.035
                            : screenSize.width * 0.038,
                        color: AppColors.gray600,
                      ),
                    ),
                    Text(
                      'Disponible: ${widget.variant.available}',
                      style: TextStyle(
                        fontSize: isSmallScreen
                            ? screenSize.width * 0.035
                            : screenSize.width * 0.038,
                        color: AppColors.gray600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenSize.height * 0.02),

              // Formulario
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tipo de ajuste
                    Text(
                      'Tipo de Ajuste',
                      style: TextStyle(
                        fontSize: isSmallScreen
                            ? screenSize.width * 0.042
                            : screenSize.width * 0.045,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray900,
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.008),

                    // Segmented Button responsivo
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Row(
                          children: [
                            Expanded(
                              child: _buildAdjustmentButton(
                                value: 'ADD',
                                label: 'Agregar',
                                icon: Icons.add,
                                isSelected: _adjustmentType == 'ADD',
                                screenSize: screenSize,
                              ),
                            ),
                            SizedBox(width: screenSize.width * 0.02),
                            Expanded(
                              child: _buildAdjustmentButton(
                                value: 'SUBTRACT',
                                label: 'Reducir',
                                icon: Icons.remove,
                                isSelected: _adjustmentType == 'SUBTRACT',
                                screenSize: screenSize,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: screenSize.height * 0.016),

                    // Campo de cantidad
                    Text(
                      'Cantidad',
                      style: TextStyle(
                        fontSize: isSmallScreen
                            ? screenSize.width * 0.042
                            : screenSize.width * 0.045,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray900,
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.008),
                    TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        hintText: 'Ingrese la cantidad',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            screenSize.width * 0.03,
                          ),
                        ),
                        prefixIcon: Icon(
                          _adjustmentType == 'ADD' ? Icons.add : Icons.remove,
                          color: _adjustmentType == 'ADD'
                              ? AppColors.green500
                              : AppColors.red500,
                          size: isSmallScreen
                              ? screenSize.width * 0.05
                              : screenSize.width * 0.055,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: screenSize.width * 0.04,
                          vertical: isSmallScreen
                              ? screenSize.height * 0.014
                              : screenSize.height * 0.016,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: isSmallScreen
                            ? screenSize.width * 0.04
                            : screenSize.width * 0.042,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese una cantidad';
                        }
                        final quantity = int.tryParse(value);
                        if (quantity == null || quantity <= 0) {
                          return 'Por favor ingrese una cantidad válida';
                        }
                        if (_adjustmentType == 'SUBTRACT' &&
                            quantity > widget.variant.stock) {
                          return 'No puede reducir más del stock disponible';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: screenSize.height * 0.016),

                    // Campo de motivo
                    Text(
                      'Motivo (Opcional)',
                      style: TextStyle(
                        fontSize: isSmallScreen
                            ? screenSize.width * 0.042
                            : screenSize.width * 0.045,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray900,
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.008),
                    TextFormField(
                      controller: _reasonController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Ingrese el motivo del ajuste...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            screenSize.width * 0.03,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: screenSize.width * 0.04,
                          vertical: screenSize.height * 0.012,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: isSmallScreen
                            ? screenSize.width * 0.04
                            : screenSize.width * 0.042,
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.024),

                    // Botón de acción
                    PrimaryButton(
                      text: _adjustmentType == 'ADD'
                          ? 'Agregar Stock'
                          : 'Reducir Stock',
                      onPressed: _handleUpdate,
                      backgroundColor: _adjustmentType == 'ADD'
                          ? AppColors.green500
                          : AppColors.red500,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdjustmentButton({
    required String value,
    required String label,
    required IconData icon,
    required bool isSelected,
    required Size screenSize,
  }) {
    final isSmallScreen = screenSize.width < 360;

    return Material(
      color: isSelected
          ? (value == 'ADD' ? AppColors.green500 : AppColors.red500)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(screenSize.width * 0.02),
      child: InkWell(
        onTap: () {
          setState(() {
            _adjustmentType = value;
          });
        },
        borderRadius: BorderRadius.circular(screenSize.width * 0.02),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenSize.width * 0.02,
            vertical: screenSize.height * 0.012,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(screenSize.width * 0.02),
            border: Border.all(
              color: isSelected
                  ? (value == 'ADD' ? AppColors.green500 : AppColors.red500)
                  : AppColors.gray300,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.gray600,
                size: isSmallScreen
                    ? screenSize.width * 0.045
                    : screenSize.width * 0.05,
              ),
              SizedBox(width: screenSize.width * 0.01),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: isSmallScreen
                        ? screenSize.width * 0.035
                        : screenSize.width * 0.038,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.gray700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
