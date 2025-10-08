import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final TextEditingController _searchController = TextEditingController();

  void _onSearch() {
    final query = _searchController.text.trim();
    debugPrint("Buscando pedido: $query");
  }

  void _onClear() {
    _searchController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.blue600, AppColors.blue500, AppColors.blue400],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 🔹 Encabezado
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    const Text(
                      'Pedidos',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Gestión y seguimiento de pedidos',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),

              // 🔹 Contenido principal
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: Column(
                      children: [
                        // 🔍 Buscador para pedidos
                        _buildSearchBar(),
                        const SizedBox(height: 24),

                        // 🔹 Métricas principales
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                title: 'Total Pedidos',
                                value: '5',
                                subtitle: '3 activos',
                                color: AppColors.blue500,
                                backgroundColor: AppColors.blue50,
                                icon: Icons.receipt_long_outlined,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                title: 'Ventas del Mes',
                                value: '\$12.5K',
                                subtitle: '+12% vs mes anterior',
                                color: AppColors.green600,
                                backgroundColor: AppColors.green50,
                                icon: Icons.attach_money,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // 🔹 Estados
                        Row(
                          children: [
                            // 🔹 Procesando
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  // Navegar a pedidos procesando
                                },
                                child: _buildSmallStatCard(
                                  value: '1',
                                  title: 'Procesando',
                                  color: AppColors.amber500,
                                  backgroundColor: AppColors.amber50,
                                  icon: Icons.timelapse_rounded,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // 🔹 Empacado
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  // Navegar a pedidos empacados
                                },
                                child: _buildSmallStatCard(
                                  value: '1',
                                  title: 'Empacado',
                                  color: AppColors.blue500,
                                  backgroundColor: AppColors.blue50,
                                  icon: Icons.inventory_2_rounded,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // 🔹 Enviado
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  // Navegar a pedidos enviados
                                },
                                child: _buildSmallStatCard(
                                  value: '1',
                                  title: 'Enviado',
                                  color: AppColors.purple500,
                                  backgroundColor: AppColors.purple100,
                                  icon: Icons.local_shipping_rounded,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // 🔹 Entregado
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  // Navegar a pedidos entregados
                                },
                                child: _buildSmallStatCard(
                                  value: '1',
                                  title: 'Entregado',
                                  color: AppColors.green500,
                                  backgroundColor: AppColors.green50,
                                  icon: Icons.check_circle_rounded,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        // 🔹 Lista de pedidos
                        _buildOrderCard(
                          context,
                          orderId: 'ORD-001',
                          customer: 'María García',
                          total: '\$1,579.98',
                          date: '2024-01-15',
                          status: 'Entregado',
                          productsCount: 3,
                          employee: 'Ana Díaz',
                          color: AppColors.green500,
                          backgroundColor: AppColors.green50,
                        ),
                        const SizedBox(height: 12),
                        _buildOrderCard(
                          context,
                          orderId: 'ORD-002',
                          customer: 'Pedro López',
                          total: '\$299.99',
                          date: '2024-01-20',
                          status: 'Procesando',
                          productsCount: 2,
                          employee: 'Sin asignar',
                          color: AppColors.amber500,
                          backgroundColor: AppColors.amber50,
                        ),
                        const SizedBox(height: 12),
                        _buildOrderCard(
                          context,
                          orderId: 'ORD-003',
                          customer: 'Carlos Rodríguez',
                          total: '\$845.50',
                          date: '2024-01-18',
                          status: 'Enviado',
                          productsCount: 4,
                          employee: 'Luis Martínez',
                          color: AppColors.purple500,
                          backgroundColor: AppColors.purple100,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔍 Buscador personalizado
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _onSearch(),
              decoration: InputDecoration(
                hintText: 'Buscar pedidos, clientes o estados...',
                hintStyle: TextStyle(color: AppColors.gray500, fontSize: 14),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.gray500,
                  size: 20,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: _onClear,
                        icon: const Icon(
                          Icons.clear,
                          color: AppColors.gray500,
                          size: 20,
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              style: const TextStyle(fontSize: 14, color: AppColors.gray900),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 4),
            child: Material(
              color: AppColors.blue500,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: _onSearch,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: const Icon(
                    Icons.search,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🟦 Tarjeta de estadísticas
  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required Color backgroundColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: color.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // 🟨 Tarjeta pequeña de estadísticas
  Widget _buildSmallStatCard({
    required String value,
    required String title,
    required Color color,
    required Color backgroundColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 🟩 Tarjeta individual de pedido con navegación
  Widget _buildOrderCard(
    BuildContext context, {
    required String orderId,
    required String customer,
    required String total,
    required String date,
    required String status,
    required int productsCount,
    required String employee,
    required Color color,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                orderId,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.gray900,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            customer,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.gray700,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$date • $productsCount productos',
                    style: const TextStyle(
                      color: AppColors.gray500,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Asignado a: $employee',
                    style: const TextStyle(
                      color: AppColors.gray600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Text(
                total,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.blue600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => context.push('/main/order-detail/$orderId'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.blue600,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              child: const Text('Ver detalles'),
            ),
          ),
        ],
      ),
    );
  }
}
