import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/shell/presentation/screens/main_shell_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const MainShellScreen(),
      ),
    ],
    redirect: (context, state) {
      final user = authState.value;
      final isLoggingIn = state.matchedLocation == '/login';

      if (user == null && !isLoggingIn) {
        return '/login';
      }
      if (user != null && isLoggingIn) {
        return '/';
      }
      return null;
    },
  );
});
