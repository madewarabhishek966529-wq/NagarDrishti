import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nagardrishti/src/features/issues/data/issues_repository.dart';
import 'package:nagardrishti/src/features/issues/domain/issue_model.dart';
import 'package:nagardrishti/src/features/notifications/data/notification_service.dart';
import 'package:nagardrishti/src/features/auth/presentation/controllers/auth_controller.dart';
import '../../data/admin_command_center_repository.dart';
import '../../domain/admin_command_center_models.dart';

final adminCommandCenterRepositoryProvider = Provider<AdminCommandCenterRepository>((ref) {
  final issuesRepo = FirestoreIssuesRepository();
  final notificationService = FcmNotificationService();
  return FirestoreAdminCommandCenterRepository(
    issuesRepository: issuesRepo,
    notificationService: notificationService,
  );
});

final cityKpiOverviewProvider = FutureProvider<CityKpiOverview>((ref) async {
  final repo = ref.watch(adminCommandCenterRepositoryProvider);
  return repo.fetchCityKpiOverview();
});

final tenZonePerformanceProvider = FutureProvider<List<ZonePerformanceDetail>>((ref) async {
  final repo = ref.watch(adminCommandCenterRepositoryProvider);
  return repo.fetchTenZonePerformance();
});

final departmentPerformanceProvider = FutureProvider<List<DepartmentPerformanceDetail>>((ref) async {
  final repo = ref.watch(adminCommandCenterRepositoryProvider);
  return repo.fetchDepartmentPerformance();
});

final csoManagementProvider = FutureProvider<List<CsoOfficerDetail>>((ref) async {
  final repo = ref.watch(adminCommandCenterRepositoryProvider);
  return repo.fetchAllCsos();
});

final financialAnalyticsProvider = FutureProvider<FinancialAnalyticsModel>((ref) async {
  final repo = ref.watch(adminCommandCenterRepositoryProvider);
  return repo.fetchFinancialAnalytics();
});

final cityAuditLogsProvider = FutureProvider<List<CityAuditLog>>((ref) async {
  final repo = ref.watch(adminCommandCenterRepositoryProvider);
  return repo.fetchAuditLogs();
});

final sosEmergencyQueueProvider = FutureProvider<List<IssueModel>>((ref) async {
  final issuesRepo = FirestoreIssuesRepository();
  final issues = await issuesRepo.fetchIssues();
  return issues.where((i) =>
      i.status != IssueStatus.resolved &&
      (i.category == 'SOS Emergency' || i.slaDeadline.difference(i.createdAt).inHours <= 4)
  ).toList()
    ..sort((a, b) => a.slaDeadline.compareTo(b.slaDeadline));
});

final redAlertMasterQueueProvider = FutureProvider<List<IssueModel>>((ref) async {
  final issuesRepo = FirestoreIssuesRepository();
  final issues = await issuesRepo.fetchIssues();
  return issues.where((i) => i.redAlert).toList()
    ..sort((a, b) => b.reportCount.compareTo(a.reportCount));
});

final proofOfFixAuditProvider = FutureProvider<List<IssueModel>>((ref) async {
  final issuesRepo = FirestoreIssuesRepository();
  final issues = await issuesRepo.fetchIssues();
  return issues.where((i) => i.status == IssueStatus.resolved || i.afterImageUrl != null).toList()
    ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
});

final citizenValidationQueueProvider = FutureProvider<List<IssueModel>>((ref) async {
  final issuesRepo = FirestoreIssuesRepository();
  final issues = await issuesRepo.fetchIssues();
  return issues.where((i) => i.reopenCount > 0 || (i.citizenRating != null && i.citizenRating! <= 2) || (!i.isVerifiedFixed && i.afterImageUrl != null)).toList()
    ..sort((a, b) => b.reopenCount.compareTo(a.reopenCount));
});

class AdminActionController extends StateNotifier<AsyncValue<void>> {
  final AdminCommandCenterRepository _repository;
  final Ref _ref;

  AdminActionController(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<void> executeAdminAction({
    required String issueId,
    required String actionType,
    required String details,
    String? assignedDepartment,
    String? assignedWorker,
    IssueStatus? newStatus,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = _ref.read(authStateProvider).value;
      final adminUid = user?.uid ?? 'admin_master';
      final adminName = user?.displayName ?? 'NMC City Administrator';

      await _repository.performAdminAction(
        issueId: issueId,
        adminUid: adminUid,
        adminName: adminName,
        actionType: actionType,
        details: details,
        assignedDepartment: assignedDepartment,
        assignedWorker: assignedWorker,
        newStatus: newStatus,
      );

      _ref.invalidate(cityKpiOverviewProvider);
      _ref.invalidate(tenZonePerformanceProvider);
      _ref.invalidate(departmentPerformanceProvider);
      _ref.invalidate(sosEmergencyQueueProvider);
      _ref.invalidate(redAlertMasterQueueProvider);
      _ref.invalidate(cityAuditLogsProvider);
    });
  }

  Future<void> updateCsoActiveStatus(String uid, bool active) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.updateCsoStatus(uid, active);
      _ref.invalidate(csoManagementProvider);
      _ref.invalidate(tenZonePerformanceProvider);
    });
  }

  Future<void> createNewCso(CsoOfficerDetail cso) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.createCso(cso);
      _ref.invalidate(csoManagementProvider);
      _ref.invalidate(tenZonePerformanceProvider);
    });
  }
}

final adminActionControllerProvider = StateNotifierProvider<AdminActionController, AsyncValue<void>>((ref) {
  final repo = ref.watch(adminCommandCenterRepositoryProvider);
  return AdminActionController(repo, ref);
});
