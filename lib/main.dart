import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:stock_control_app/features/stats/presentation/bloc/stats_bloc.dart';

import 'app/di/injection_container.dart' as di;
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/main_shell.dart';
import 'features/auth/presentation/pages/home_page.dart';
import 'features/inventory/presentation/pages/update_stock_page.dart';
import 'features/inventory/presentation/pages/inventory_page.dart';
import 'features/orders/presentation/pages/orders_page.dart';
import 'features/auth/presentation/pages/profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final GoRouter _router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final authBloc = di.sl<AuthBloc>();
      final authState = authBloc.state;

      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToMain = state.matchedLocation.startsWith('/main');
      final isGoingToHome = state.matchedLocation == '/';

      if (authState is AuthAuthenticated && (isGoingToHome || isGoingToLogin)) {
        return '/main/inventory';
      }

      if (authState is AuthUnauthenticated && isGoingToMain) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomePage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/main',
            redirect: (context, state) => '/main/inventory',
          ),
          GoRoute(
            path: '/main/inventory',
            builder: (context, state) => const InventoryPage(),
          ),
          GoRoute(
            path: '/main/orders',
            builder: (context, state) => const OrdersPage(),
          ),
          GoRoute(
            path: '/main/profile',
            builder: (context, state) => ProfilePage(
              onNavigateToTab: (index) {
                switch (index) {
                  case 0:
                    context.go('/main/inventory');
                    break;
                  case 1:
                    context.go('/main/orders');
                    break;
                }
              },
            ),
          ),
          GoRoute(
            path: '/main/update-stock/:productId',
            builder: (context, state) {
              final productId = state.pathParameters['productId']!;
              return UpdateStockPage(productId: productId);
            },
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Error: ${state.error}'))),
  );

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => di.sl<AuthBloc>()..add(CheckAuthStatus()),
        ),
        BlocProvider(create: (context) => di.sl<StatsBloc>()),
      ],
      child: MaterialApp.router(
        title: 'Cayro Uniformes',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4285F4)),
          useMaterial3: true,
        ),
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
