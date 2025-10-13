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
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    double scaleW(double value) => value * (width / 390);
    double scaleH(double value) => value * (height / 844);

    return Scaffold(
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return _buildProfileContent(context, state, scaleW, scaleH);
          } else if (state is AuthLoading) {
            return _buildLoadingState(scaleW, scaleH);
          } else if (state is AuthError) {
            return _buildErrorState(context, state, scaleW, scaleH);
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
            return _buildLoadingState(scaleW, scaleH);
          }
        },
      ),
    );
  }

  Widget _buildLoadingState(
    double Function(double) scaleW,
    double Function(double) scaleH,
  ) {
    return Container(
      color: AppColors.blue600,
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: scaleH(16)),
              Text(
                'Cargando perfil...',
                style: TextStyle(color: Colors.white, fontSize: scaleW(16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    AuthError state,
    double Function(double) scaleW,
    double Function(double) scaleH,
  ) {
    return Container(
      color: AppColors.blue600,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 4,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: scaleW(24)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: scaleW(70),
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: scaleH(20)),
                    Text(
                      'Error de Autenticación',
                      style: TextStyle(
                        fontSize: scaleW(28),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: scaleH(8)),
                    Text(
                      'No se pudo verificar tu sesión',
                      style: TextStyle(
                        fontSize: scaleW(16),
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
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(scaleW(32)),
                    topRight: Radius.circular(scaleW(32)),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    scaleW(24),
                    scaleH(20),
                    scaleW(24),
                    scaleH(16),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: scaleW(64),
                        color: AppColors.red600,
                      ),
                      SizedBox(height: scaleH(16)),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: scaleW(16),
                          color: AppColors.gray600,
                          height: 1.4,
                        ),
                      ),
                      Spacer(),
                      PrimaryButton(
                        text: 'Reintentar',
                        onPressed: () {
                          context.read<AuthBloc>().add(CheckAuthStatus());
                        },
                      ),
                      SizedBox(height: scaleH(12)),
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
                            padding: EdgeInsets.symmetric(vertical: scaleH(16)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(scaleW(12)),
                            ),
                          ),
                          child: Text(
                            'Iniciar Sesión',
                            style: TextStyle(
                              fontSize: scaleW(16),
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

  Widget _buildProfileContent(
    BuildContext context,
    AuthAuthenticated state,
    double Function(double) scaleW,
    double Function(double) scaleH,
  ) {
    final user = state.user;

    return Container(
      color: AppColors.blue600,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: scaleW(24)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: scaleH(20)),
                    CircleAvatar(
                      radius: scaleW(50),
                      backgroundColor: Colors.white,
                      child: Text(
                        _getInitials(user.name),
                        style: TextStyle(
                          color: AppColors.blue500,
                          fontSize: scaleW(32),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: scaleH(16)),
                    Text(
                      user.name,
                      style: TextStyle(
                        fontSize: scaleW(26),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: scaleH(4)),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: scaleW(16),
                        color: Colors.white70,
                        fontWeight: FontWeight.w300,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: scaleH(8)),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: scaleW(16),
                        vertical: scaleH(6),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(scaleW(20)),
                      ),
                      child: Text(
                        'Administrador de Inventario',
                        style: TextStyle(
                          color: Colors.blueGrey,
                          fontSize: scaleW(14),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
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
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(scaleW(32)),
                    topRight: Radius.circular(scaleW(32)),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    scaleW(24),
                    scaleH(20),
                    scaleW(24),
                    scaleH(16),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Información de la Empresa', scaleW),
                        SizedBox(height: scaleH(12)),
                        _buildInfoCard(
                          imagePath: 'assets/images/logo.png',
                          title: 'Cayro Uniformes',
                          subtitle: 'Sucursal Centro • ID: CAY-001',
                          color: AppColors.blue500,
                          scaleW: scaleW,
                          scaleH: scaleH,
                        ),
                        SizedBox(height: scaleH(20)),

                        _buildSectionTitle('Estadísticas', scaleW),
                        SizedBox(height: scaleH(12)),
                        _buildStatsSection(scaleW, scaleH),
                        SizedBox(height: scaleH(20)),

                        _buildSectionTitle('Acciones Rápidas', scaleW),
                        SizedBox(height: scaleH(12)),
                        _buildQuickAction(
                          icon: Icons.inventory_2,
                          title: 'Gestionar Inventario',
                          color: AppColors.blue500,
                          onTap: () => widget.onNavigateToTab?.call(0),
                          scaleW: scaleW,
                          scaleH: scaleH,
                        ),
                        SizedBox(height: scaleH(8)),
                        _buildQuickAction(
                          icon: Icons.receipt_long,
                          title: 'Ver Pedidos',
                          color: AppColors.green600,
                          onTap: () => widget.onNavigateToTab?.call(1),
                          scaleW: scaleW,
                          scaleH: scaleH,
                        ),
                        SizedBox(height: scaleH(24)),

                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () =>
                                _showLogoutDialog(context, scaleW, scaleH),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.red600,
                              side: BorderSide(color: AppColors.red600),
                              padding: EdgeInsets.symmetric(
                                vertical: scaleH(16),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(scaleW(12)),
                              ),
                            ),
                            child: Text(
                              'Cerrar Sesión',
                              style: TextStyle(
                                fontSize: scaleW(16),
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

  Widget _buildSectionTitle(String title, double Function(double) scaleW) {
    return Text(
      title,
      style: TextStyle(
        fontSize: scaleW(20),
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
    required double Function(double) scaleW,
    required double Function(double) scaleH,
  }) {
    return Container(
      padding: EdgeInsets.all(scaleW(16)),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(scaleW(12)),
      ),
      child: Row(
        children: [
          Container(
            width: scaleW(48),
            height: scaleW(48),
            decoration: BoxDecoration(
              color: imagePath != null ? Colors.white : Colors.white30,
              borderRadius: BorderRadius.circular(scaleW(12)),
            ),
            child: imagePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(scaleW(12)),
                    child: Image.asset(
                      imagePath,
                      width: scaleW(48),
                      height: scaleW(48),
                      fit: BoxFit.contain,
                    ),
                  )
                : Icon(icon, color: color, size: scaleW(24)),
          ),
          SizedBox(width: scaleW(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: scaleW(16),
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray900,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: scaleH(2)),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: scaleW(14),
                    color: AppColors.gray600,
                  ),
                  overflow: TextOverflow.ellipsis,
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
    required double Function(double) scaleW,
    required double Function(double) scaleH,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(scaleW(12)),
      child: Container(
        padding: EdgeInsets.all(scaleW(16)),
        decoration: BoxDecoration(
          color: AppColors.gray50,
          borderRadius: BorderRadius.circular(scaleW(12)),
        ),
        child: Row(
          children: [
            Container(
              width: scaleW(40),
              height: scaleW(40),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(scaleW(8)),
              ),
              child: Icon(icon, color: color, size: scaleW(20)),
            ),
            SizedBox(width: scaleW(16)),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: scaleW(16),
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray900,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: scaleW(16),
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

  void _showLogoutDialog(
    BuildContext context,
    double Function(double) scaleW,
    double Function(double) scaleH,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(scaleW(16)),
          ),
          title: Text(
            'Cerrar Sesión',
            style: TextStyle(
              color: AppColors.gray900,
              fontWeight: FontWeight.bold,
              fontSize: scaleW(18),
            ),
          ),
          content: Text(
            '¿Estás seguro de que quieres cerrar sesión?',
            style: TextStyle(color: AppColors.gray600, fontSize: scaleW(14)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: AppColors.gray600,
                  fontSize: scaleW(14),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(LogoutRequested());
                if (context.mounted) {
                  context.pushReplacement('/');
                }
              },
              child: Text(
                'Cerrar Sesión',
                style: TextStyle(
                  color: AppColors.red600,
                  fontSize: scaleW(14),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsSection(
    double Function(double) scaleW,
    double Function(double) scaleH,
  ) {
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
                  scaleW,
                  scaleH,
                ),
              ),
              SizedBox(width: scaleW(16)),
              Expanded(
                child: _buildStatCard(
                  '${statsState.stats.monthlySales}',
                  'Pedidos\nEste mes',
                  AppColors.green600,
                  scaleW,
                  scaleH,
                ),
              ),
            ],
          );
        } else if (statsState is StatsLoading) {
          return Row(
            children: [
              Expanded(child: _buildLoadingStatCard(scaleW, scaleH)),
              SizedBox(width: scaleW(16)),
              Expanded(child: _buildLoadingStatCard(scaleW, scaleH)),
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
                      scaleW,
                      scaleH,
                    ),
                  ),
                  SizedBox(width: scaleW(16)),
                  Expanded(
                    child: _buildStatCard(
                      '--',
                      'Pedidos\nEste mes',
                      AppColors.green600,
                      scaleW,
                      scaleH,
                    ),
                  ),
                ],
              ),
              SizedBox(height: scaleH(8)),
              Text(
                'Error al cargar estadísticas',
                style: TextStyle(color: AppColors.red600, fontSize: scaleW(12)),
              ),
              TextButton(
                onPressed: () {
                  context.read<StatsBloc>().add(LoadCurrentMonthStats());
                },
                child: Text(
                  'Reintentar',
                  style: TextStyle(fontSize: scaleW(14)),
                ),
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
                  scaleW,
                  scaleH,
                ),
              ),
              SizedBox(width: scaleW(16)),
              Expanded(
                child: _buildStatCard(
                  '--',
                  'Pedidos\nEste mes',
                  AppColors.green600,
                  scaleW,
                  scaleH,
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildStatCard(
    String number,
    String label,
    Color color,
    double Function(double) scaleW,
    double Function(double) scaleH,
  ) {
    return Container(
      padding: EdgeInsets.all(scaleW(20)),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(scaleW(12)),
      ),
      child: Column(
        children: [
          Text(
            number,
            style: TextStyle(
              fontSize: scaleW(28),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: scaleH(8)),
          Text(
            label,
            style: TextStyle(
              fontSize: scaleW(14),
              fontWeight: FontWeight.w600,
              color: AppColors.gray800,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingStatCard(
    double Function(double) scaleW,
    double Function(double) scaleH,
  ) {
    return Container(
      padding: EdgeInsets.all(scaleW(20)),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(scaleW(12)),
      ),
      child: Column(
        children: [
          Container(
            width: scaleW(40),
            height: scaleH(32),
            decoration: BoxDecoration(
              color: AppColors.gray500,
              borderRadius: BorderRadius.circular(scaleW(4)),
            ),
          ),
          SizedBox(height: scaleH(8)),
          Container(
            width: scaleW(60),
            height: scaleH(14),
            decoration: BoxDecoration(
              color: AppColors.gray500,
              borderRadius: BorderRadius.circular(scaleW(4)),
            ),
          ),
        ],
      ),
    );
  }
}
