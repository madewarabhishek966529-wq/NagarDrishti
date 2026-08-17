import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nagardrishti/src/features/auth/domain/app_user.dart';
import 'package:nagardrishti/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:nagardrishti/src/features/auth/presentation/screens/login_screen.dart';
import 'package:nagardrishti/src/features/shell/presentation/screens/main_shell_screen.dart';
import 'package:nagardrishti/src/features/issues/presentation/screens/issue_detail_screen.dart';
import 'package:nagardrishti/src/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:nagardrishti/src/features/admin/presentation/screens/city_gis_map_screen.dart';
import 'package:nagardrishti/src/features/admin/presentation/screens/ten_zone_performance_screen.dart';
import 'package:nagardrishti/src/features/admin/presentation/screens/admin_major_problems_screen.dart';
import 'package:nagardrishti/src/features/admin/presentation/screens/red_alert_center_screen.dart';
import 'package:nagardrishti/src/features/admin/presentation/screens/sos_command_screen.dart';
import 'package:nagardrishti/src/features/admin/presentation/screens/sla_command_center_screen.dart';
import 'package:nagardrishti/src/features/admin/presentation/screens/department_performance_screen.dart';
import 'package:nagardrishti/src/features/admin/presentation/screens/cso_management_screen.dart';
import 'package:nagardrishti/src/features/admin/presentation/screens/financial_analytics_screen.dart';
import 'package:nagardrishti/src/features/admin/presentation/screens/proof_of_fix_audit_screen.dart';
import 'package:nagardrishti/src/features/admin/presentation/screens/citizen_validation_screen.dart';
import 'package:nagardrishti/src/features/admin/presentation/screens/city_analytics_screen.dart';
import 'package:nagardrishti/src/features/admin/presentation/screens/audit_logs_screen.dart';
import 'package:nagardrishti/src/features/cso/presentation/screens/cso_dashboard_screen.dart';
import 'package:nagardrishti/src/features/cso/presentation/screens/major_problems_screen.dart';
import 'package:nagardrishti/src/features/cso/presentation/screens/cso_zone_map_screen.dart';
import 'package:nagardrishti/src/features/public_feed/presentation/screens/public_feed_screen.dart';
import 'package:nagardrishti/src/features/active_work/presentation/screens/active_work_screen.dart';

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
        path: '/admin/map',
        builder: (context, state) => const CityGisMapScreen(),
      ),
      GoRoute(
        path: '/admin/zones',
        builder: (context, state) => const TenZonePerformanceScreen(),
      ),
      GoRoute(
        path: '/admin/major-problems',
        builder: (context, state) => const AdminMajorProblemsScreen(),
      ),
      GoRoute(
        path: '/admin/red-alerts',
        builder: (context, state) => const RedAlertCenterScreen(),
      ),
      GoRoute(
        path: '/admin/sos',
        builder: (context, state) => const SosCommandScreen(),
      ),
      GoRoute(
        path: '/admin/sla',
        builder: (context, state) => const SlaCommandCenterScreen(),
      ),
      GoRoute(
        path: '/admin/departments',
        builder: (context, state) => const DepartmentPerformanceScreen(),
      ),
      GoRoute(
        path: '/admin/csos',
        builder: (context, state) => const CsoManagementScreen(),
      ),
      GoRoute(
        path: '/admin/finance',
        builder: (context, state) => const FinancialAnalyticsScreen(),
      ),
      GoRoute(
        path: '/admin/proof-of-fix',
        builder: (context, state) => const ProofOfFixAuditScreen(),
      ),
      GoRoute(
        path: '/admin/citizen-validation',
        builder: (context, state) => const CitizenValidationScreen(),
      ),
      GoRoute(
        path: '/admin/analytics',
        builder: (context, state) => const CityAnalyticsScreen(),
      ),
      GoRoute(
        path: '/admin/audit-logs',
        builder: (context, state) => const AuditLogsScreen(),
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
