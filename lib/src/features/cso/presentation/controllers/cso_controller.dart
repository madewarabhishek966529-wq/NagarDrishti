import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nagardrishti/src/features/issues/data/issues_repository.dart';
import 'package:nagardrishti/src/features/issues/domain/issue_model.dart';
import 'package:nagardrishti/src/features/notifications/data/notification_service.dart';
import 'package:nagardrishti/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:nagardrishti/src/features/cso/data/cso_repository.dart';
import 'package:nagardrishti/src/features/cso/domain/cso_performance_model.dart';

final csoRepositoryProvider = Provider<CsoRepository>((ref) {
  final issuesRepo = FirestoreIssuesRepository();
  final notificationService = FcmNotificationService();
  return FirestoreCsoRepository(
    issuesRepository: issuesRepo,
    notificationService: notificationService,
  );
});

final csoZoneIssuesProvider = FutureProvider.family<List<IssueModel>, String>((ref, zoneId) async {
  final repo = ref.watch(csoRepositoryProvider);
  return repo.fetchZoneIssues(zoneId);
});

final csoZonePerformanceProvider = FutureProvider.family<CsoZonePerformance, String>((ref, zoneId) async {
  final repo = ref.watch(csoRepositoryProvider);
  return repo.fetchZonePerformance(zoneId);
});

class RankedMajorProblem {
  final IssueModel issue;
  final double urgencyScore;
  final String primaryReason;

  const RankedMajorProblem({
    required this.issue,
    required this.urgencyScore,
    required this.primaryReason,
  });
}

final majorProblemsProvider = FutureProvider.family<List<RankedMajorProblem>, String>((ref, zoneId) async {
  final issues = await ref.watch(csoZoneIssuesProvider(zoneId).future);
  final ranked = <RankedMajorProblem>[];
  final now = DateTime.now();

  for (final issue in issues) {
    if (issue.status == IssueStatus.resolved) continue;

    double score = 0;
    String reason = 'Active Zone Problem';

    if (issue.redAlert) {
      score += 120;
      reason = 'RED ALERT: High Duplicate Density (${issue.reportCount} Citizen Reports)';
    } else if (issue.severity == IssueSeverity.critical) {
      score += 90;
      reason = 'Critical Hazard Safety Risk';
    }

    score += (issue.reportCount * 8);

    if (now.isAfter(issue.slaDeadline)) {
      score += 70;
      reason = 'SLA BREACHED: Overdue Resolution';
    } else if (issue.slaDeadline.difference(now).inHours <= 6) {
      score += 40;
      if (!issue.redAlert) reason = 'SLA AT RISK: Deadline in ${issue.slaDeadline.difference(now).inHours} Hours';
    }

    if (issue.reopenCount > 0) {
      score += (issue.reopenCount * 35);
      reason = 'Citizen Re-opened Defect (Count: ${issue.reopenCount})';
    }

    ranked.add(RankedMajorProblem(
      issue: issue,
      urgencyScore: score,
      primaryReason: reason,
    ));
  }

  ranked.sort((a, b) => b.urgencyScore.compareTo(a.urgencyScore));
  return ranked;
});

class CsoActionController extends StateNotifier<AsyncValue<void>> {
  final CsoRepository _repository;
  final Ref _ref;

  CsoActionController(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<void> executeAction({
    required String issueId,
    required String actionType,
    required String details,
    String? evidenceUrl,
    String? assignedWorker,
    String? assignedDepartment,
    required String zoneId,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = _ref.read(authStateProvider).value;
      final officerUid = user?.uid ?? 'cso_officer';
      final officerName = user?.displayName ?? 'Rajesh Gaidhani (CSO)';

      await _repository.performCsoAction(
        issueId: issueId,
        officerUid: officerUid,
        officerName: officerName,
        actionType: actionType,
        details: details,
        evidenceUrl: evidenceUrl,
        assignedWorker: assignedWorker,
        assignedDepartment: assignedDepartment,
      );

      _ref.invalidate(csoZoneIssuesProvider(zoneId));
      _ref.invalidate(csoZonePerformanceProvider(zoneId));
      _ref.invalidate(majorProblemsProvider(zoneId));
    });
  }
}

final csoActionControllerProvider = StateNotifierProvider<CsoActionController, AsyncValue<void>>((ref) {
  final repo = ref.watch(csoRepositoryProvider);
  return CsoActionController(repo, ref);
});
