import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../core/constants/app_colors.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final TextEditingController _searchController = TextEditingController();

  final List<Product> _products = [
    Product(
      id: 'UNI-001',
      name: 'Uniforme Escolar Completo',
      category: 'Uniformes Escolares',
      price: 450,
      stock: 25,
      status: ProductStatus.inStock,
      image: 'assets/images/uniform_school.png',
    ),
    Product(
      id: 'POL-002',
      name: 'Camisa Polo Empresarial',
      category: 'Uniformes Corporativos',
      price: 280,
      stock: 45,
      status: ProductStatus.inStock,
      image: 'assets/images/polo_shirt.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthUnauthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.pushReplacement('/login');
          });
          return const SizedBox.shrink();
        }

        if (state is AuthLoading) {
          return _buildLoadingState();
        }

        return _buildInventoryContent(context);
      },
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.blue600, AppColors.blue500, AppColors.blue400],
        ),
      ),
      child: const SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Cargando inventario...',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInventoryContent(BuildContext context) {
    return Container(
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
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Inventario',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Gestión de productos y stock',
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
            ),
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
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.gray50,
                            borderRadius: BorderRadius.circular(16),
                            // Sombra muy suave
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x1A000000), // 10% opacity
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Buscar productos, SKU o categoría...',
                              hintStyle: TextStyle(color: AppColors.gray500),
                              prefixIcon: Icon(
                                Icons.search,
                                color: AppColors.gray500,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Expanded(
                              child: _buildMainStatCard(
                                '6',
                                'Total Productos',
                                '4 disponibles',
                                AppColors.blue100,
                                AppColors.blue600,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildMainStatCard(
                                '\$31,110',
                                'Valor Total',
                                'Inventario actual',
                                AppColors.green100,
                                AppColors.green600,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: _buildStatusCard(
                                '4',
                                'En Stock',
                                Icons.check_circle,
                                AppColors.green100,
                                AppColors.green600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildStatusCard(
                                '1',
                                'Poco Stock',
                                Icons.warning,
                                AppColors.amber100,
                                AppColors.amber600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildStatusCard(
                                '1',
                                'Agotados',
                                Icons.cancel,
                                AppColors.red100,
                                AppColors.red600,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        ...(_products
                            .map((product) => _buildProductCard(product))
                            .toList()),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainStatCard(
    String value,
    String title,
    String subtitle,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          Text(subtitle, style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildStatusCard(
    String value,
    String title,
    IconData icon,
    Color bgColor,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: iconColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.blue50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.checkroom,
                  color: AppColors.blue500,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gray900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'SKU: ${product.id}',
                      style: TextStyle(fontSize: 14, color: AppColors.gray600),
                    ),
                    Text(
                      product.category,
                      style: TextStyle(fontSize: 14, color: AppColors.gray600),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${product.price}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gray900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.green100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'En stock',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.green600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Stock Total: ${product.stock} unidades',
                style: TextStyle(fontSize: 14, color: AppColors.gray600),
              ),
              ElevatedButton(
                onPressed: () {
                  context.push('/main/update-stock/${product.id}');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 1,
                ),
                child: const Text(
                  'Actualizar Stock',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final int stock;
  final ProductStatus status;
  final String image;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    required this.status,
    required this.image,
  });
}

enum ProductStatus { inStock, lowStock, outOfStock }
