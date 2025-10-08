import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class OrderDetailPage extends StatelessWidget {
  final String orderId;
  const OrderDetailPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: AppBar(
        title: const Text(
          'Detalle del Pedido',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.white),
        ),
        centerTitle: true,
        backgroundColor: AppColors.blue600,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // 🔹 Scroll sin franja amarilla y con animación de entrada
      body: ScrollConfiguration(
        behavior: const ScrollBehavior().copyWith(overscroll: false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🧾 Información del cliente
                _buildInfoCard(
                  title: 'Información del Cliente',
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoItem('Nombre', 'María García'),
                      _infoItem('Teléfono', '+52 55 1234 5678'),
                      _infoItem('Email', 'maria.garcia@email.com'),
                      _infoItem(
                        'Dirección de Entrega',
                        'Av. Revolución 123, Col. Centro, CDMX, 06000',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 📦 Productos del pedido
                _buildInfoCard(
                  title: 'Productos del Pedido',
                  content: Column(
                    children: [
                      _productItem(
                        'Uniforme Escolar Completo',
                        'Azul Marino',
                        'M',
                        2,
                        450,
                        900,
                        'https://images.unsplash.com/photo-1606813902916-53fd09b0bb72?auto=format&fit=crop&w=200&q=60',
                      ),
                      _productItem(
                        'Camisa Polo Empresarial',
                        'Blanco',
                        'L',
                        3,
                        280,
                        840,
                        'https://images.unsplash.com/photo-1562157873-818bc0726f0d?auto=format&fit=crop&w=200&q=60',
                      ),
                      _productItem(
                        'Pantalón de Vestir',
                        'Negro',
                        '32',
                        1,
                        399.98,
                        399.98,
                        'https://images.unsplash.com/photo-1602810314072-88c34c22a3dd?auto=format&fit=crop&w=200&q=60',
                      ),
                      const Divider(height: 24, color: AppColors.gray200),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Total: \$1,579.98',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.blue600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🧱 Tarjeta con título e información
  Widget _buildInfoCard({required String title, required Widget content}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.gray800,
            ),
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  // 👤 Item de información de cliente
  Widget _infoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.gray600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(color: AppColors.gray800, fontSize: 15),
          ),
        ],
      ),
    );
  }

  // 📦 Item de producto
  Widget _productItem(
    String name,
    String color,
    String size,
    int qty,
    double price,
    double total,
    String imageUrl,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Imagen del producto
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 60,
                height: 60,
                color: AppColors.gray100,
                child: const Icon(
                  Icons.image_not_supported,
                  color: AppColors.gray400,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Detalles del producto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Cantidad: $qty • Talla: $size • Color: $color',
                  style: const TextStyle(
                    color: AppColors.gray600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  '\$$price c/u',
                  style: const TextStyle(
                    color: AppColors.gray500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Total a la derecha
          Text(
            '\$$total',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.gray800,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
