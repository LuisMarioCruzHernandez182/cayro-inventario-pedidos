import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/home_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/main_shell.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../di/injection_container.dart' as di;

class AppRoutes {
  static final router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final authBloc = di.sl<AuthBloc>();
      final authState = authBloc.state;

      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToMain = state.matchedLocation == '/main';
      final isGoingToHome = state.matchedLocation == '/';

      if (authState is AuthAuthenticated && (isGoingToHome || isGoingToLogin)) {
        return '/main';
      }

      if (authState is AuthUnauthenticated && isGoingToMain) {
        return '/';
      }

      if (authState is AuthError && isGoingToMain) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomePage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/main', builder: (context, state) => const MainShell()),
    ],
  );
}
