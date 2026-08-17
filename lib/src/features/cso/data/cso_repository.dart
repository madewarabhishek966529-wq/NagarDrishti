import 'package:cloud_firestore/cloud_firestore.dart';
import '../../issues/domain/issue_model.dart';
import '../../issues/data/issues_repository.dart';
import '../domain/cso_performance_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../notifications/data/notification_service.dart';

abstract class CsoRepository {
  Future<List<IssueModel>> fetchZoneIssues(String zoneId);
  Future<CsoZonePerformance> fetchZonePerformance(String zoneId);
  Future<List<CsoActionLog>> fetchActionLogsForIssue(String issueId);
  Future<void> performCsoAction({
    required String issueId,
    required String officerUid,
    required String officerName,
    required String actionType,
    required String details,
    String? evidenceUrl,
    String? assignedWorker,
    String? assignedDepartment,
  });
}

class FirestoreCsoRepository implements CsoRepository {
  final IssuesRepository issuesRepository;
  final NotificationService notificationService;
  final FirebaseFirestore? _customFirestore;

  final List<CsoActionLog> _mockLogs = [];

  FirestoreCsoRepository({
    required this.issuesRepository,
    required this.notificationService,
    FirebaseFirestore? firestore,
  })  : _customFirestore = firestore;

  IssuesRepository get _issuesRepository => issuesRepository;
  NotificationService get _notificationService => notificationService;

  FirebaseFirestore? get _db {
    if (_customFirestore != null) return _customFirestore;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<IssueModel>> fetchZoneIssues(String zoneId) async {
    final allIssues = await _issuesRepository.fetchIssues();
    final targetZoneName = AppConstants.zoneIdToNameMap[zoneId]?.toLowerCase() ?? '';

    return allIssues.where((issue) {
      final issueWardZoneId = AppConstants.wardToZoneIdMap[issue.ward];
      if (issueWardZoneId == zoneId) return true;
      if (targetZoneName.isNotEmpty && issue.ward.toLowerCase().contains(targetZoneName)) return true;
      return false;
    }).toList();
  }

  @override
  Future<CsoZonePerformance> fetchZonePerformance(String zoneId) async {
    final issues = await fetchZoneIssues(zoneId);
    final zoneName = AppConstants.zoneIdToNameMap[zoneId] ?? 'NMC Zone';

    int total = issues.length;
    int newCount = 0;
    int pending = 0;
    int inProgress = 0;
    int resolved = 0;
    int overdue = 0;
    int critical = 0;
    int redAlerts = 0;
    int approachingSla = 0;
    int awaitingValidation = 0;
    int reopenedCount = 0;

    double totalResolutionHours = 0;
    int resolvedWithTimeCount = 0;
    double ratingSum = 0;
    int ratingCount = 0;

    final now = DateTime.now();

    for (final issue in issues) {
      if (issue.status == IssueStatus.reported) newCount++;
      if (issue.status == IssueStatus.reported || issue.status == IssueStatus.acknowledged) pending++;
      if (issue.status == IssueStatus.inProgress) inProgress++;
      if (issue.status == IssueStatus.resolved) {
        resolved++;
        final durationHours = issue.updatedAt.difference(issue.createdAt).inHours.toDouble();
        totalResolutionHours += durationHours > 0 ? durationHours : 1.0;
        resolvedWithTimeCount++;
      }

      if (issue.status != IssueStatus.resolved && now.isAfter(issue.slaDeadline)) {
        overdue++;
      }

      if (issue.severity == IssueSeverity.critical) critical++;
      if (issue.redAlert) redAlerts++;

      if (issue.status != IssueStatus.resolved && !now.isAfter(issue.slaDeadline)) {
        final hoursLeft = issue.slaDeadline.difference(now).inHours;
        if (hoursLeft <= 6) approachingSla++;
      }

      if (issue.afterImageUrl != null && issue.afterImageUrl!.isNotEmpty && !issue.isVerifiedFixed) {
        awaitingValidation++;
      }

      if (issue.reopenCount > 0) reopenedCount += issue.reopenCount;

      if (issue.citizenRating != null) {
        ratingSum += issue.citizenRating!;
        ratingCount++;
      }
    }

    final avgResolutionHours = resolvedWithTimeCount > 0 ? totalResolutionHours / resolvedWithTimeCount : 18.5;
    final slaCompliance = total > 0 ? ((total - overdue) / total * 100).clamp(0.0, 100.0) : 95.5;
    final citizenScore = ratingCount > 0 ? ratingSum / ratingCount : 4.8;

    return CsoZonePerformance(
      zoneId: zoneId,
      zoneName: zoneName,
      totalComplaints: total,
      newComplaints: newCount,
      pendingComplaints: pending,
      inProgressComplaints: inProgress,
      resolvedComplaints: resolved,
      overdueComplaints: overdue,
      criticalComplaints: critical,
      redAlertCount: redAlerts,
      approachingSlaCount: approachingSla,
      awaitingValidationCount: awaitingValidation,
      averageResolutionTimeHours: avgResolutionHours,
      slaComplianceRatePercentage: slaCompliance,
      citizenValidationScore: citizenScore,
      reopenedCount: reopenedCount,
    );
  }

  @override
  Future<List<CsoActionLog>> fetchActionLogsForIssue(String issueId) async {
    final db = _db;
    if (db != null) {
      try {
        final snap = await db.collection('issues').doc(issueId).collection('actionLogs').orderBy('timestamp', descending: true).get().timeout(const Duration(seconds: 3));
        return snap.docs.map((doc) => CsoActionLog.fromMap(doc.data(), doc.id)).toList();
      } catch (_) {}
    }
    return _mockLogs.where((l) => l.issueId == issueId).toList();
  }

  @override
  Future<void> performCsoAction({
    required String issueId,
    required String officerUid,
    required String officerName,
    required String actionType,
    required String details,
    String? evidenceUrl,
    String? assignedWorker,
    String? assignedDepartment,
  }) async {
    final issue = await _issuesRepository.getIssueById(issueId);
    if (issue == null) return;

    final log = CsoActionLog(
      id: 'log_${DateTime.now().millisecondsSinceEpoch}',
      issueId: issueId,
      trackingId: issue.trackingId,
      officerUid: officerUid,
      officerName: officerName,
      actionType: actionType,
      details: details,
      evidenceUrl: evidenceUrl,
      timestamp: DateTime.now(),
    );

    _mockLogs.insert(0, log);

    final db = _db;
    if (db != null) {
      try {
        await db.collection('issues').doc(issueId).collection('actionLogs').doc(log.id).set(log.toMap()).timeout(const Duration(seconds: 3));
      } catch (_) {}
    }

    if (actionType == 'ESCALATE') {
      final zoneId = AppConstants.wardToZoneIdMap[issue.ward] ?? 'zone_04';
      await _notificationService.notifyCsoRedAlert(
        zoneId: zoneId,
        trackingId: issue.trackingId,
        category: issue.category,
        reportCount: issue.reportCount,
      );
    }
  }
}
