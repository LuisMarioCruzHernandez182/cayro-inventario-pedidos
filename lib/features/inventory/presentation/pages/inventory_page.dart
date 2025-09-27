import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../core/constants/app_colors.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

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
          return Scaffold(
            backgroundColor: AppColors.gray50,
            body: const Center(
              child: CircularProgressIndicator(color: AppColors.blue500),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.gray50,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 120,
                backgroundColor: AppColors.blue500,
                flexibleSpace: const FlexibleSpaceBar(
                  title: Text(
                    'Inventario',
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  centerTitle: true,
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                ),
              ),
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 64,
                        color: AppColors.gray400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Gestión de Inventario',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gray800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Próximamente disponible',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.gray500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
