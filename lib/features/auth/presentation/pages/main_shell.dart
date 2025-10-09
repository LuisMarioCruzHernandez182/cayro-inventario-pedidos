import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';
import '../../../../core/constants/app_colors.dart';

class MainShell extends StatefulWidget {
  final Widget? child;

  const MainShell({super.key, this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    if (location.contains('/main/inventory') || location == '/main') return 0;
    if (location.contains('/main/orders')) return 1;
    if (location.contains('/main/assigned-orders')) return 2;
    if (location.contains('/main/profile')) return 3;

    return -1;
  }

  void _navigateToTab(int index) {
    switch (index) {
      case 0:
        context.go('/main/inventory');
        break;
      case 1:
        context.go('/main/orders');
        break;
      case 2:
        context.go('/main/assigned-orders');
        break;
      case 3:
        context.go('/main/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _getCurrentIndex(context);

    return BlocProvider.value(
      value: context.read<AuthBloc>(),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            context.go('/');
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
          resizeToAvoidBottomInset: false,
          body: widget.child ?? const SizedBox(),
          bottomNavigationBar: currentIndex == -1
              ? null
              : BottomNavigationBar(
                  currentIndex: currentIndex,
                  onTap: _navigateToTab,
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
                      icon: Icon(Icons.assignment_ind_outlined),
                      activeIcon: Icon(Icons.assignment_ind),
                      label: 'Mis pedidos',
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
