import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/domain/app_user.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/shell/presentation/screens/main_shell_screen.dart';
import '../../features/issues/presentation/screens/issue_detail_screen.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/cso/presentation/screens/cso_dashboard_screen.dart';
import '../../features/cso/presentation/screens/major_problems_screen.dart';
import '../../features/cso/presentation/screens/cso_zone_map_screen.dart';
import '../../features/public_feed/presentation/screens/public_feed_screen.dart';
import '../../features/active_work/presentation/screens/active_work_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authStreamState = ref.watch(authStateProvider);
  final authCtrlState = ref.watch(authControllerProvider);
  final user = authStreamState.value ?? authCtrlState.value;

  return GoRouter(
    initialLocation: user == null
        ? '/login'
        : (user.role == UserRole.csoZonalOfficer
            ? '/cso'
            : (user.role == UserRole.deptAdmin ? '/admin' : '/')),
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const MainShellScreen(),
      ),
      GoRoute(
        path: '/cso',
        builder: (context, state) => const CsoDashboardScreen(),
      ),
      GoRoute(
        path: '/cso/major-problems',
        builder: (context, state) => const MajorProblemsScreen(),
      ),
      GoRoute(
        path: '/cso/map',
        builder: (context, state) => const CsoZoneMapScreen(),
      ),
      GoRoute(
        path: '/issue/:id',
        builder: (context, state) {
          final issueId = state.pathParameters['id'] ?? 'doc_red_alert_1';
          return IssueDetailScreen(issueId: issueId);
        },
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/public-feed',
        builder: (context, state) => const PublicFeedScreen(),
      ),
      GoRoute(
        path: '/active-work',
        builder: (context, state) => const ActiveWorkScreen(),
      ),
    ],
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final isLoggingIn = loc == '/login';

      if (user == null && !isLoggingIn) {
        return '/login';
      }

      if (user != null) {
        if (user.role == UserRole.csoZonalOfficer) {
          if (isLoggingIn || loc == '/' || loc.startsWith('/admin')) {
            return '/cso';
          }
        } else if (user.role == UserRole.deptAdmin) {
          if (isLoggingIn || loc == '/' || loc.startsWith('/cso')) {
            return '/admin';
          }
        } else if (user.role == UserRole.citizen) {
          if (isLoggingIn || loc.startsWith('/cso') || loc.startsWith('/admin')) {
            return '/';
          }
        }
      }

      return null;
    },
  );
});

