// lib/features/auth/presentation/pages/profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';
import '../../../stats/presentation/bloc/stats_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/buttons/primary_button.dart';

class ProfilePage extends StatefulWidget {
  final Function(int)? onNavigateToTab;

  const ProfilePage({super.key, this.onNavigateToTab});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<StatsBloc>().add(LoadCurrentMonthStats());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return _buildProfileContent(context, state);
          } else if (state is AuthLoading) {
            return _buildLoadingState();
          } else if (state is AuthError) {
            return _buildErrorState(context, state);
          } else if (state is AuthUnauthenticated) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                context.pushReplacement('/');
              }
            });
            return const SizedBox.shrink();
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                context.read<AuthBloc>().add(CheckAuthStatus());
              }
            });
            return _buildLoadingState();
          }
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

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
            // Header section (mismo diseño que InventoryPage)
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.width * 0.06,
                ),
                child: Row(
                  children: [
                    // Logo placeholder (mismo estilo que InventoryPage)
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: screenSize.width * 0.4,
                            height: screenSize.height * 0.06,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          SizedBox(height: screenSize.height * 0.01),
                          Container(
                            width: screenSize.width * 0.6,
                            height: screenSize.height * 0.02,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content section (mismo diseño que InventoryPage)
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
                  padding: EdgeInsets.fromLTRB(
                    screenSize.width * 0.06,
                    screenSize.height * 0.03,
                    screenSize.width * 0.06,
                    screenSize.height * 0.02,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Loading indicator centrado (mismo estilo que InventoryPage)
                      CircularProgressIndicator(
                        color: AppColors.blue500,
                        strokeWidth: 3,
                      ),
                      SizedBox(height: screenSize.height * 0.02),
                      Text(
                        'Cargando perfil...',
                        style: TextStyle(
                          fontSize: isSmallScreen
                              ? screenSize.width * 0.04
                              : screenSize.width * 0.045,
                          color: AppColors.gray600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      // Simulación de contenido de perfil (placeholder)
                      SizedBox(height: screenSize.height * 0.04),
                      _buildLoadingPlaceholder(screenSize),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder(Size screenSize) {
    return Column(
      children: [
        // Avatar placeholder
        Container(
          width: screenSize.width * 0.25,
          height: screenSize.width * 0.25,
          decoration: BoxDecoration(
            color: AppColors.gray200,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(height: screenSize.height * 0.02),

        // Name placeholder
        Container(
          width: screenSize.width * 0.5,
          height: screenSize.height * 0.02,
          decoration: BoxDecoration(
            color: AppColors.gray200,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(height: screenSize.height * 0.01),

        // Email placeholder
        Container(
          width: screenSize.width * 0.7,
          height: screenSize.height * 0.015,
          decoration: BoxDecoration(
            color: AppColors.gray200,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(height: screenSize.height * 0.03),

        // Stats placeholders
        Row(
          children: [
            Expanded(
              child: Container(
                height: screenSize.height * 0.1,
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(width: screenSize.width * 0.04),
            Expanded(
              child: Container(
                height: screenSize.height * 0.1,
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, AuthError state) {
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
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: 70,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Error de Autenticación',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'No se pudo verificar tu sesión',
                      style: TextStyle(
                        fontSize: 18,
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
              flex: 3,
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
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.red600,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.gray600,
                          height: 1.4,
                        ),
                      ),
                      const Spacer(),
                      PrimaryButton(
                        text: 'Reintentar',
                        onPressed: () {
                          context.read<AuthBloc>().add(CheckAuthStatus());
                        },
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            context.read<AuthBloc>().add(LogoutRequested());
                            context.pushReplacement('/login');
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.blue500,
                            side: BorderSide(color: AppColors.blue500),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Iniciar Sesión',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, AuthAuthenticated state) {
    final user = state.user;
    final screenSize = MediaQuery.of(context).size;

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
              flex: 3,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.width * 0.06,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    CircleAvatar(
                      radius: screenSize.width * 0.12,
                      backgroundColor: Colors.white,
                      child: Text(
                        _getInitials(user.name),
                        style: TextStyle(
                          color: AppColors.blue500,
                          fontSize: screenSize.width * 0.08,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.name,
                      style: TextStyle(
                        fontSize: screenSize.width * 0.065,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: screenSize.width * 0.04,
                        color: Colors.white70,
                        fontWeight: FontWeight.w300,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenSize.width * 0.04,
                        vertical: screenSize.height * 0.006,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Administrador de Inventario',
                        style: TextStyle(
                          color: Colors.blueGrey,
                          fontSize: screenSize.width * 0.035,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 5,
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
                  padding: EdgeInsets.fromLTRB(
                    screenSize.width * 0.06,
                    screenSize.height * 0.02,
                    screenSize.width * 0.06,
                    screenSize.height * 0.02,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(
                          'Información de la Empresa',
                          screenSize,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoCard(
                          imagePath: 'assets/images/logo.png',
                          title: 'Cayro Uniformes',
                          subtitle: 'Sucursal Centro • ID: CAY-001',
                          color: AppColors.blue500,
                          screenSize: screenSize,
                        ),
                        const SizedBox(height: 20),

                        _buildSectionTitle('Estadísticas', screenSize),
                        const SizedBox(height: 12),
                        _buildStatsSection(),
                        const SizedBox(height: 20),

                        _buildSectionTitle('Acciones Rápidas', screenSize),
                        const SizedBox(height: 12),
                        _buildQuickAction(
                          icon: Icons.inventory_2,
                          title: 'Gestionar Inventario',
                          color: AppColors.blue500,
                          onTap: () => widget.onNavigateToTab?.call(0),
                          screenSize: screenSize,
                        ),
                        const SizedBox(height: 8),
                        _buildQuickAction(
                          icon: Icons.receipt_long,
                          title: 'Ver Pedidos',
                          color: AppColors.green600,
                          onTap: () => widget.onNavigateToTab?.call(1),
                          screenSize: screenSize,
                        ),
                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => _showLogoutDialog(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.red600,
                              side: BorderSide(color: AppColors.red600),
                              padding: EdgeInsets.symmetric(
                                vertical: screenSize.height * 0.016,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Cerrar Sesión',
                              style: TextStyle(
                                fontSize: screenSize.width * 0.04,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
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

  Widget _buildSectionTitle(String title, Size screenSize) {
    return Text(
      title,
      style: TextStyle(
        fontSize: screenSize.width * 0.05,
        fontWeight: FontWeight.bold,
        color: AppColors.gray900,
      ),
    );
  }

  Widget _buildInfoCard({
    IconData? icon,
    String? imagePath,
    required String title,
    required String subtitle,
    required Color color,
    required Size screenSize,
  }) {
    return Container(
      padding: EdgeInsets.all(screenSize.width * 0.04),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: screenSize.width * 0.12,
            height: screenSize.width * 0.12,
            decoration: BoxDecoration(
              color: imagePath != null ? Colors.white : Colors.white30,
              borderRadius: BorderRadius.circular(12),
            ),
            child: imagePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      imagePath,
                      width: screenSize.width * 0.12,
                      height: screenSize.width * 0.12,
                      fit: BoxFit.contain,
                    ),
                  )
                : Icon(icon, color: color, size: screenSize.width * 0.06),
          ),
          SizedBox(width: screenSize.width * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: screenSize.width * 0.042,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: screenSize.width * 0.035,
                    color: AppColors.gray600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    required Size screenSize,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(screenSize.width * 0.04),
        decoration: BoxDecoration(
          color: AppColors.gray50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: screenSize.width * 0.1,
              height: screenSize.width * 0.1,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: screenSize.width * 0.05),
            ),
            SizedBox(width: screenSize.width * 0.04),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: screenSize.width * 0.04,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray900,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: screenSize.width * 0.04,
              color: AppColors.gray500,
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    List<String> names = name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Cerrar Sesión',
            style: TextStyle(
              color: AppColors.gray900,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            '¿Estás seguro de que quieres cerrar sesión?',
            style: TextStyle(color: AppColors.gray600),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(color: AppColors.gray600),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(LogoutRequested());
                context.pushReplacement('/');
              },
              child: Text(
                'Cerrar Sesión',
                style: TextStyle(color: AppColors.red600),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsSection() {
    return BlocBuilder<StatsBloc, StatsState>(
      builder: (context, statsState) {
        if (statsState is StatsLoaded) {
          return Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '${statsState.stats.totalProducts}',
                  'Productos\nGestionados',
                  AppColors.blue500,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  '${statsState.stats.monthlySales}',
                  'Pedidos\nEste mes',
                  AppColors.green600,
                ),
              ),
            ],
          );
        } else if (statsState is StatsLoading) {
          return Row(
            children: [
              Expanded(child: _buildLoadingStatCard()),
              const SizedBox(width: 16),
              Expanded(child: _buildLoadingStatCard()),
            ],
          );
        } else if (statsState is StatsError) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      '--',
                      'Productos\nGestionados',
                      AppColors.blue500,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      '--',
                      'Pedidos\nEste mes',
                      AppColors.green600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Error al cargar estadísticas',
                style: TextStyle(color: AppColors.red600, fontSize: 12),
              ),
              TextButton(
                onPressed: () {
                  context.read<StatsBloc>().add(LoadCurrentMonthStats());
                },
                child: const Text('Reintentar'),
              ),
            ],
          );
        } else {
          return Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '--',
                  'Productos\nGestionados',
                  AppColors.blue500,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  '--',
                  'Pedidos\nEste mes',
                  AppColors.green600,
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildStatCard(String number, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            number,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.gray800,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingStatCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.gray500,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 60,
            height: 14,
            decoration: BoxDecoration(
              color: AppColors.gray500,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
