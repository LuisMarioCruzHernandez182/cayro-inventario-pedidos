import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';
import '../../../../app/di/injection_container.dart' as di;
import 'profile_page.dart';
import '../../../inventory/presentation/pages/inventory_page.dart';
import '../../../orders/presentation/pages/orders_page.dart';
import '../../../../core/constants/app_colors.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 2;

  void _changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  List<Widget> get _pages => [
    const InventoryPage(),
    const OrdersPage(),
    ProfilePage(onNavigateToTab: _changeTab),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = di.sl<AuthBloc>();
        Future.microtask(() => bloc.add(CheckAuthStatus()));
        return bloc;
      },
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            context.pushReplacement('/');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error de autenticación: ${state.message}'),
                backgroundColor: AppColors.red600,
                action: SnackBarAction(
                  label: 'Reintentar',
                  textColor: AppColors.white,
                  onPressed: () {
                    context.read<AuthBloc>().add(CheckAuthStatus());
                  },
                ),
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.gray50,
          body: IndexedStack(index: _currentIndex, children: _pages),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppColors.white,
            selectedItemColor: AppColors.blue500,
            unselectedItemColor: AppColors.gray400,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.inventory_2_outlined),
                activeIcon: Icon(Icons.inventory_2),
                label: 'Inventario',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined),
                activeIcon: Icon(Icons.receipt_long),
                label: 'Pedidos',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Perfil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
