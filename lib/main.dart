// lib/main.dart
import 'dart:async'; // 👈 necesario para StreamSubscription
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:stock_control_app/features/orders/presentation/pages/assigned_orders_page.dart';
import 'package:stock_control_app/features/stats/presentation/bloc/stats_bloc.dart';
import 'app/di/injection_container.dart' as di;

import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/main_shell.dart';
import 'features/auth/presentation/pages/home_page.dart';
import 'features/inventory/presentation/pages/update_stock_page.dart';
import 'features/inventory/presentation/pages/inventory_page.dart';
import 'features/orders/presentation/pages/orders_page.dart';
import 'features/orders/presentation/pages/order_detail_page.dart';
import 'features/auth/presentation/pages/profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();

  final authBloc = di.sl<AuthBloc>()..add(CheckAuthStatus());
  final statsBloc = di.sl<StatsBloc>();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<StatsBloc>.value(value: statsBloc),
      ],
      child: MyApp(authBloc: authBloc),
    ),
  );
}

/// Helper para refrescar GoRouter cuando cambia un Stream (AuthBloc)
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class MyApp extends StatelessWidget {
  final AuthBloc authBloc;

  MyApp({super.key, required this.authBloc});

  late final GoRouter _router = GoRouter(
    initialLocation: '/',
    // 👇 Se refresca cuando cambia el estado del AuthBloc
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
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

      // Shell principal
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
            path: '/main/assigned-orders',
            builder: (context, state) => const AssignedOrdersPage(),
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
                  case 2:
                    context.go('/main/assigned-orders');
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
          // 👇💥 mueve esta ruta aquí (dentro del ShellRoute)
          GoRoute(
            path: '/main/order-detail/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return OrderDetailPage(orderId: id);
            },
          ),
        ],
      ),

      // Si también quieres permitir fuera del shell:
      GoRoute(
        path: '/order-detail/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return OrderDetailPage(orderId: id);
        },
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Error: ${state.error}'))),
  );

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go('/');
        }
      },
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
