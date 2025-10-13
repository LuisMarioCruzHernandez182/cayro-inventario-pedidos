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
  String _adjustmentType = 'ADD';

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _handleUpdate() {
    if (!_formKey.currentState!.validate()) return;

    final quantity = int.parse(_quantityController.text);
    widget.onUpdate(_adjustmentType, quantity, null);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    double scaleW(double v) => v * (width / 390);
    double scaleH(double v) => v * (height / 844);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(scaleW(20))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(scaleW(24)),
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
                        fontSize: scaleW(22),
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
                      size: scaleW(22),
                    ),
                  ),
                ],
              ),
              SizedBox(height: scaleH(16)),

              // Información del producto
              Container(
                padding: EdgeInsets.all(scaleW(16)),
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  borderRadius: BorderRadius.circular(scaleW(12)),
                  border: Border.all(color: AppColors.gray200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Variante: ${widget.variant.color.name} - ${widget.variant.size.name}',
                      style: TextStyle(
                        fontSize: scaleW(16),
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray900,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: scaleH(6)),
                    Text(
                      'Stock actual: ${widget.variant.stock}',
                      style: TextStyle(
                        fontSize: scaleW(14),
                        color: AppColors.gray600,
                      ),
                    ),
                    Text(
                      'Disponible: ${widget.variant.available}',
                      style: TextStyle(
                        fontSize: scaleW(14),
                        color: AppColors.gray600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: scaleH(24)),

              // Formulario
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tipo de ajuste
                    Text(
                      'Tipo de ajuste',
                      style: TextStyle(
                        fontSize: scaleW(16),
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray900,
                      ),
                    ),
                    SizedBox(height: scaleH(8)),

                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment<String>(
                          value: 'ADD',
                          label: Text('Agregar'),
                          icon: Icon(Icons.add),
                        ),
                        ButtonSegment<String>(
                          value: 'SUBTRACT',
                          label: Text('Reducir'),
                          icon: Icon(Icons.remove),
                        ),
                      ],
                      selected: {_adjustmentType},
                      onSelectionChanged: (Set<String> newSelection) {
                        setState(() => _adjustmentType = newSelection.first);
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.resolveWith<Color?>((states) {
                              if (states.contains(WidgetState.selected)) {
                                return AppColors.blue600;
                              }
                              return AppColors.gray100;
                            }),
                        foregroundColor:
                            WidgetStateProperty.resolveWith<Color?>((states) {
                              if (states.contains(WidgetState.selected)) {
                                return Colors.white;
                              }
                              return AppColors.gray700;
                            }),
                        side: WidgetStateProperty.all(
                          BorderSide(color: AppColors.gray300),
                        ),
                      ),
                    ),

                    SizedBox(height: scaleH(20)),

                    // Campo de cantidad
                    Text(
                      'Cantidad',
                      style: TextStyle(
                        fontSize: scaleW(16),
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray900,
                      ),
                    ),
                    SizedBox(height: scaleH(8)),

                    TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        hintText: 'Ingrese la cantidad',
                        hintStyle: TextStyle(
                          color: AppColors.gray400,
                          fontSize: scaleW(14),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(scaleW(12)),
                          borderSide: BorderSide(color: AppColors.gray300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(scaleW(12)),
                          borderSide: BorderSide(
                            color: AppColors.blue600,
                            width: 1.5,
                          ),
                        ),
                        prefixIcon: Icon(
                          _adjustmentType == 'ADD' ? Icons.add : Icons.remove,
                          color: AppColors.blue600,
                          size: scaleW(22),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: scaleW(14),
                          vertical: scaleH(14),
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
                          return 'Ingrese una cantidad válida';
                        }
                        if (_adjustmentType == 'SUBTRACT' &&
                            quantity > widget.variant.stock) {
                          return 'No puede reducir más del stock disponible';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: scaleH(24)),

                    // Botón de acción
                    PrimaryButton(
                      text: _adjustmentType == 'ADD'
                          ? 'Agregar Stock'
                          : 'Reducir Stock',
                      onPressed: _handleUpdate,
                      backgroundColor: AppColors.blue600,
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
