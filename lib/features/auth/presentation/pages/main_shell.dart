import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: AppColors.blue600,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

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
          backgroundColor: AppColors.blue600,
          resizeToAvoidBottomInset: true,
          body: AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              statusBarColor: AppColors.blue600,
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.dark,
            ),
            child: SafeArea(
              bottom: false,
              child: Container(
                color: AppColors.gray50,
                child: widget.child ?? const SizedBox(),
              ),
            ),
          ),
          bottomNavigationBar: currentIndex == -1
              ? null
              : Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowColor,
                        blurRadius: 8,
                        offset: const Offset(0, -1),
                      ),
                    ],
                  ),
                  child: BottomNavigationBar(
                    currentIndex: currentIndex,
                    onTap: _navigateToTab,
                    type: BottomNavigationBarType.fixed,
                    backgroundColor: AppColors.white,
                    elevation: 0,
                    selectedFontSize: 0,
                    unselectedFontSize: 0,
                    showSelectedLabels: false,
                    showUnselectedLabels: false,
                    items: [
                      _buildNavItem(
                        index: 0,
                        currentIndex: currentIndex,
                        icon: Icons.inventory_2_outlined,
                        activeIcon: Icons.inventory_2,
                        label: 'Inventario',
                      ),
                      _buildNavItem(
                        index: 1,
                        currentIndex: currentIndex,
                        icon: Icons.receipt_long_outlined,
                        activeIcon: Icons.receipt_long,
                        label: 'Pedidos',
                      ),
                      _buildNavItem(
                        index: 2,
                        currentIndex: currentIndex,
                        icon: Icons.assignment_ind_outlined,
                        activeIcon: Icons.assignment_ind,
                        label: 'Mis pedidos',
                      ),
                      _buildNavItem(
                        index: 3,
                        currentIndex: currentIndex,
                        icon: Icons.person_outline,
                        activeIcon: Icons.person,
                        label: 'Perfil',
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem({
    required int index,
    required int currentIndex,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isActive = index == currentIndex;

    return BottomNavigationBarItem(
      label: '',
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isActive ? AppColors.blue600 : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isActive ? activeIcon : icon,
              color: isActive ? Colors.white : AppColors.gray400,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? AppColors.blue600 : AppColors.gray400,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
