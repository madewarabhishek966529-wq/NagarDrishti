import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nagardrishti/src/core/constants/app_constants.dart';
import 'package:nagardrishti/src/features/issues/data/issues_repository.dart';
import 'package:nagardrishti/src/features/issues/domain/issue_model.dart';
import 'package:nagardrishti/src/features/notifications/data/notification_service.dart';
import '../domain/admin_command_center_models.dart';

abstract class AdminCommandCenterRepository {
  Future<CityKpiOverview> fetchCityKpiOverview();
  Future<List<ZonePerformanceDetail>> fetchTenZonePerformance();
  Future<List<DepartmentPerformanceDetail>> fetchDepartmentPerformance();
  Future<List<CsoOfficerDetail>> fetchAllCsos();
  Future<void> updateCsoStatus(String uid, bool active);
  Future<void> createCso(CsoOfficerDetail cso);
  Future<FinancialAnalyticsModel> fetchFinancialAnalytics();
  Future<List<CityAuditLog>> fetchAuditLogs();
  Future<void> recordAuditLog(CityAuditLog log);
  Future<void> performAdminAction({
    required String issueId,
    required String adminUid,
    required String adminName,
    required String actionType,
    required String details,
    String? assignedDepartment,
    String? assignedWorker,
    IssueStatus? newStatus,
  });
}

class FirestoreAdminCommandCenterRepository implements AdminCommandCenterRepository {
  final IssuesRepository issuesRepository;
  final NotificationService notificationService;
  final FirebaseFirestore? _customFirestore;

  final List<CityAuditLog> _mockAuditLogs = [];
  final List<CsoOfficerDetail> _mockCsos = [
    const CsoOfficerDetail(
      uid: 'cso_01',
      name: 'Ramesh Patil',
      phone: '9823300001',
      email: 'cso.laxminagar@nagpur.gov.in',
      zoneId: 'zone_01',
      zoneName: 'Laxmi Nagar',
      active: true,
      assignedComplaints: 28,
      criticalComplaints: 3,
      resolvedComplaints: 21,
      overdueComplaints: 2,
      slaCompliancePercentage: 92.8,
      averageResolutionTimeHours: 19.4,
    ),
    const CsoOfficerDetail(
      uid: 'cso_02',
      name: 'Sunil Deshmukh',
      phone: '9823300002',
      email: 'cso.dharampeth@nagpur.gov.in',
      zoneId: 'zone_02',
      zoneName: 'Dharampeth',
      active: true,
      assignedComplaints: 42,
      criticalComplaints: 8,
      resolvedComplaints: 30,
      overdueComplaints: 6,
      slaCompliancePercentage: 85.7,
      averageResolutionTimeHours: 24.1,
    ),
    const CsoOfficerDetail(
      uid: 'cso_03',
      name: 'Anil Kulkarni',
      phone: '9823300003',
      email: 'cso.hanumannagar@nagpur.gov.in',
      zoneId: 'zone_03',
      zoneName: 'Hanuman Nagar',
      active: true,
      assignedComplaints: 19,
      criticalComplaints: 1,
      resolvedComplaints: 16,
      overdueComplaints: 1,
      slaCompliancePercentage: 94.7,
      averageResolutionTimeHours: 16.2,
    ),
    const CsoOfficerDetail(
      uid: 'cso_04',
      name: 'Rajesh Gaidhani',
      phone: '9823350242',
      email: 'cso.dhantoli@nagpur.gov.in',
      zoneId: 'zone_04',
      zoneName: 'Dhantoli',
      active: true,
      assignedComplaints: 35,
      criticalComplaints: 5,
      resolvedComplaints: 26,
      overdueComplaints: 3,
      slaCompliancePercentage: 91.4,
      averageResolutionTimeHours: 18.2,
    ),
    const CsoOfficerDetail(
      uid: 'cso_05',
      name: 'Pravin Shinde',
      phone: '9823300005',
      email: 'cso.nehrunagar@nagpur.gov.in',
      zoneId: 'zone_05',
      zoneName: 'Nehru Nagar',
      active: true,
      assignedComplaints: 31,
      criticalComplaints: 4,
      resolvedComplaints: 22,
      overdueComplaints: 5,
      slaCompliancePercentage: 83.8,
      averageResolutionTimeHours: 26.5,
    ),
    const CsoOfficerDetail(
      uid: 'cso_06',
      name: 'Vikas Meshram',
      phone: '9823300006',
      email: 'cso.gandhibagh@nagpur.gov.in',
      zoneId: 'zone_06',
      zoneName: 'Gandhi Bagh',
      active: true,
      assignedComplaints: 25,
      criticalComplaints: 2,
      resolvedComplaints: 20,
      overdueComplaints: 2,
      slaCompliancePercentage: 92.0,
      averageResolutionTimeHours: 17.8,
    ),
    const CsoOfficerDetail(
      uid: 'cso_07',
      name: 'Sanjay Wankhede',
      phone: '9823300007',
      email: 'cso.satranjipura@nagpur.gov.in',
      zoneId: 'zone_07',
      zoneName: 'Satranjipura',
      active: true,
      assignedComplaints: 38,
      criticalComplaints: 6,
      resolvedComplaints: 25,
      overdueComplaints: 7,
      slaCompliancePercentage: 81.5,
      averageResolutionTimeHours: 28.0,
    ),
    const CsoOfficerDetail(
      uid: 'cso_08',
      name: 'Dinesh Agrawal',
      phone: '9823300008',
      email: 'cso.lakadganj@nagpur.gov.in',
      zoneId: 'zone_08',
      zoneName: 'Lakadganj',
      active: true,
      assignedComplaints: 22,
      criticalComplaints: 3,
      resolvedComplaints: 18,
      overdueComplaints: 2,
      slaCompliancePercentage: 90.9,
      averageResolutionTimeHours: 19.0,
    ),
    const CsoOfficerDetail(
      uid: 'cso_09',
      name: 'Vijay Chawla',
      phone: '9823300009',
      email: 'cso.ashinagar@nagpur.gov.in',
      zoneId: 'zone_09',
      zoneName: 'Ashi Nagar',
      active: true,
      assignedComplaints: 45,
      criticalComplaints: 9,
      resolvedComplaints: 31,
      overdueComplaints: 8,
      slaCompliancePercentage: 82.2,
      averageResolutionTimeHours: 29.5,
    ),
    const CsoOfficerDetail(
      uid: 'cso_10',
      name: 'Manoj Joshi',
      phone: '9823300010',
      email: 'cso.mangalwari@nagpur.gov.in',
      zoneId: 'zone_10',
      zoneName: 'Mangalwari',
      active: true,
      assignedComplaints: 29,
      criticalComplaints: 4,
      resolvedComplaints: 23,
      overdueComplaints: 3,
      slaCompliancePercentage: 89.6,
      averageResolutionTimeHours: 20.4,
    ),
  ];

  FirestoreAdminCommandCenterRepository({
    required this.issuesRepository,
    required this.notificationService,
    FirebaseFirestore? firestore,
  }) : _customFirestore = firestore;

  FirebaseFirestore? get _db {
    if (_customFirestore != null) return _customFirestore;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<CityKpiOverview> fetchCityKpiOverview() async {
    final issues = await issuesRepository.fetchIssues();
    final now = DateTime.now();

    int total = issues.length;
    int critical = 0;
    int redAlerts = 0;
    int sosCount = 0;
    int overdue = 0;
    int atRisk = 0;
    int inProgress = 0;
    int resolved = 0;
    double totalSpend = 0;

    for (final issue in issues) {
      if (issue.severity == IssueSeverity.critical) critical++;
      if (issue.redAlert) redAlerts++;
      if (issue.category == 'SOS Emergency' || issue.slaDeadline.difference(issue.createdAt).inHours <= 4) sosCount++;

      if (issue.status == IssueStatus.inProgress) inProgress++;
      if (issue.status == IssueStatus.resolved) resolved++;

      if (issue.status != IssueStatus.resolved) {
        if (now.isAfter(issue.slaDeadline)) {
          overdue++;
        } else {
          final hoursLeft = issue.slaDeadline.difference(now).inHours;
          if (hoursLeft <= 6) atRisk++;
        }
      }

      totalSpend += issue.estimatedCost ?? 18000;
    }

    final slaCompliance = total > 0 ? ((total - overdue) / total * 100).clamp(0.0, 100.0) : 94.2;

    return CityKpiOverview(
      totalComplaints: total,
      criticalComplaints: critical,
      redAlertCount: redAlerts,
      sosCount: sosCount,
      overdueComplaints: overdue,
      atRiskComplaints: atRisk,
      inProgressComplaints: inProgress,
      resolvedComplaints: resolved,
      overallSlaCompliancePercentage: slaCompliance,
      totalEstimatedBudgetSpent: totalSpend,
    );
  }

  @override
  Future<List<ZonePerformanceDetail>> fetchTenZonePerformance() async {
    final issues = await issuesRepository.fetchIssues();
    final now = DateTime.now();

    return AppConstants.zoneIdToNameMap.entries.map((entry) {
      final zoneId = entry.key;
      final zoneName = entry.value;

      final zoneIssues = issues.where((i) {
        final wardZone = AppConstants.wardToZoneIdMap[i.ward];
        return wardZone == zoneId || i.ward.toLowerCase().contains(zoneName.toLowerCase());
      }).toList();

      int count = zoneIssues.length;
      int critical = zoneIssues.where((i) => i.severity == IssueSeverity.critical).length;
      int redAlerts = zoneIssues.where((i) => i.redAlert).length;
      int overdue = zoneIssues.where((i) => i.status != IssueStatus.resolved && now.isAfter(i.slaDeadline)).length;
      int rejections = zoneIssues.where((i) => i.reopenCount > 0 || (i.citizenRating != null && i.citizenRating! <= 2)).length;

      double slaComp = count > 0 ? ((count - overdue) / count * 100).clamp(0.0, 100.0) : 95.0;
      double rejectionRate = count > 0 ? (rejections / count * 100).clamp(0.0, 100.0) : 4.0;
      double avgResHours = 18.0 + (overdue * 2.5);
      double validationScore = (5.0 - (rejectionRate / 20.0)).clamp(1.0, 5.0);

      ZoneHealthGrade grade = ZoneHealthGrade.excellent;
      if (slaComp < 85) {
        grade = ZoneHealthGrade.poor;
      } else if (slaComp < 90) {
        grade = ZoneHealthGrade.fair;
      } else if (slaComp < 94) {
        grade = ZoneHealthGrade.good;
      }
      if (overdue >= 5 || critical >= 6) {
        grade = ZoneHealthGrade.critical;
      }

      final cso = _mockCsos.firstWhere(
        (c) => c.zoneId == zoneId,
        orElse: () => CsoOfficerDetail(
          uid: 'cso_$zoneId',
          name: 'CSO $zoneName Officer',
          phone: '9823300000',
          email: 'cso.$zoneId@nagpur.gov.in',
          zoneId: zoneId,
          zoneName: zoneName,
          active: true,
          assignedComplaints: count,
          criticalComplaints: critical,
          resolvedComplaints: count - overdue,
          overdueComplaints: overdue,
          slaCompliancePercentage: slaComp,
          averageResolutionTimeHours: avgResHours,
        ),
      );

      return ZonePerformanceDetail(
        zoneId: zoneId,
        zoneName: zoneName,
        complaintCount: count,
        criticalCount: critical,
        redAlertCount: redAlerts,
        overdueCount: overdue,
        slaCompliancePercentage: slaComp,
        averageResolutionTimeHours: avgResHours,
        citizenValidationScore: validationScore,
        citizenRejectionRate: rejectionRate,
        zoneHealth: grade,
        assignedCsoName: cso.name,
        assignedCsoPhone: cso.phone,
      );
    }).toList();
  }

  @override
  Future<List<DepartmentPerformanceDetail>> fetchDepartmentPerformance() async {
    final issues = await issuesRepository.fetchIssues();
    final now = DateTime.now();

    final depts = [
      {'id': 'DEPT_ROADS', 'name': 'Roads & Infrastructure'},
      {'id': 'DEPT_WATER', 'name': 'Water Supply & Pipelines'},
      {'id': 'DEPT_DRAINAGE', 'name': 'Sewerage & Storm Drain'},
      {'id': 'DEPT_ELECTRIC', 'name': 'Street Lighting & Power'},
      {'id': 'DEPT_SANITATION', 'name': 'Solid Waste & Sanitation'},
    ];

    return depts.map((d) {
      final deptId = d['id']!;
      final deptName = d['name']!;

      final deptIssues = issues.where((i) => i.assignedDepartmentId == deptId || i.category.contains(deptName.split(' ').first)).toList();
      int assigned = deptIssues.length;
      int inProgress = deptIssues.where((i) => i.status == IssueStatus.inProgress).length;
      int resolved = deptIssues.where((i) => i.status == IssueStatus.resolved).length;
      int overdue = deptIssues.where((i) => i.status != IssueStatus.resolved && now.isAfter(i.slaDeadline)).length;
      int rejections = deptIssues.where((i) => i.citizenRating != null && i.citizenRating! <= 2).length;
      int reopened = deptIssues.fold<int>(0, (total, i) => total + i.reopenCount);

      double slaComp = assigned > 0 ? ((assigned - overdue) / assigned * 100).clamp(0.0, 100.0) : 92.5;

      return DepartmentPerformanceDetail(
        departmentId: deptId,
        departmentName: deptName,
        assignedComplaints: assigned,
        inProgressComplaints: inProgress,
        resolvedComplaints: resolved,
        overdueComplaints: overdue,
        slaCompliancePercentage: slaComp,
        averageResolutionTimeHours: 21.4,
        citizenRejectionCount: rejections,
        reopenedCount: reopened,
      );
    }).toList();
  }

  @override
  Future<List<CsoOfficerDetail>> fetchAllCsos() async {
    final db = _db;
    if (db != null) {
      try {
        final snap = await db.collection('users').where('role', isEqualTo: 'CSO_ZONAL_OFFICER').get();
        if (snap.docs.isNotEmpty) {
          return snap.docs.map((doc) {
            final data = doc.data();
            return CsoOfficerDetail(
              uid: doc.id,
              name: data['name'] as String? ?? 'Zonal CSO',
              phone: data['phone'] as String? ?? '9823350242',
              email: data['email'] as String? ?? 'cso@nagpur.gov.in',
              zoneId: data['zoneId'] as String? ?? 'zone_04',
              zoneName: data['zoneName'] as String? ?? 'Dhantoli',
              active: data['active'] as bool? ?? true,
              assignedComplaints: 35,
              criticalComplaints: 4,
              resolvedComplaints: 28,
              overdueComplaints: 3,
              slaCompliancePercentage: 91.2,
              averageResolutionTimeHours: 18.5,
            );
          }).toList();
        }
      } catch (_) {}
    }
    return _mockCsos;
  }

  @override
  Future<void> updateCsoStatus(String uid, bool active) async {
    final idx = _mockCsos.indexWhere((c) => c.uid == uid);
    if (idx != -1) {
      final old = _mockCsos[idx];
      _mockCsos[idx] = CsoOfficerDetail(
        uid: old.uid,
        name: old.name,
        phone: old.phone,
        email: old.email,
        zoneId: old.zoneId,
        zoneName: old.zoneName,
        active: active,
        assignedComplaints: old.assignedComplaints,
        criticalComplaints: old.criticalComplaints,
        resolvedComplaints: old.resolvedComplaints,
        overdueComplaints: old.overdueComplaints,
        slaCompliancePercentage: old.slaCompliancePercentage,
        averageResolutionTimeHours: old.averageResolutionTimeHours,
      );
    }

    final db = _db;
    if (db != null) {
      try {
        await db.collection('users').doc(uid).update({'active': active});
      } catch (_) {}
    }
  }

  @override
  Future<void> createCso(CsoOfficerDetail cso) async {
    _mockCsos.insert(0, cso);
    final db = _db;
    if (db != null) {
      try {
        await db.collection('users').doc(cso.uid).set({
          'uid': cso.uid,
          'name': cso.name,
          'phone': cso.phone,
          'email': cso.email,
          'role': 'CSO_ZONAL_OFFICER',
          'zoneId': cso.zoneId,
          'zoneName': cso.zoneName,
          'active': cso.active,
          'createdAt': DateTime.now().toIso8601String(),
        });
      } catch (_) {}
    }
  }

  @override
  Future<FinancialAnalyticsModel> fetchFinancialAnalytics() async {
    final issues = await issuesRepository.fetchIssues();
    double totalEstimated = 0;
    Map<String, double> zoneSpend = {};
    Map<String, double> deptSpend = {};
    Map<String, double> contractorSpend = {
      'Shree Infrastructures Ltd': 184000,
      'Vidarbha Waterworks Tech': 142000,
      'Nagpur Electricals & Power': 98000,
      'Sanitation Fast Action Squad': 76000,
    };

    for (final issue in issues) {
      double cost = issue.estimatedCost ?? 18000;
      totalEstimated += cost;

      final zoneId = AppConstants.wardToZoneIdMap[issue.ward] ?? 'zone_04';
      final zoneName = AppConstants.zoneIdToNameMap[zoneId] ?? 'Dhantoli';
      zoneSpend[zoneName] = (zoneSpend[zoneName] ?? 0) + cost;

      final deptName = issue.assignedDepartmentId.replaceAll('DEPT_', '');
      deptSpend[deptName] = (deptSpend[deptName] ?? 0) + cost;
    }

    double allocated = 2500000;
    double actual = totalEstimated;
    double remaining = (allocated - actual).clamp(0, allocated);

    return FinancialAnalyticsModel(
      estimatedTotalRepairCost: totalEstimated,
      allocatedBudget: allocated,
      actualExpenditure: actual,
      remainingBudget: remaining,
      zoneWiseExpenditure: zoneSpend,
      departmentWiseExpenditure: deptSpend,
      contractorWiseExpenditure: contractorSpend,
    );
  }

  @override
  Future<List<CityAuditLog>> fetchAuditLogs() async {
    final db = _db;
    if (db != null) {
      try {
        final snap = await db.collection('auditLogs').orderBy('timestamp', descending: true).get();
        if (snap.docs.isNotEmpty) {
          return snap.docs.map((d) => CityAuditLog.fromMap(d.data(), d.id)).toList();
        }
      } catch (_) {}
    }

    if (_mockAuditLogs.isEmpty) {
      _mockAuditLogs.addAll([
        CityAuditLog(
          id: 'log_01',
          userUid: 'admin_master',
          userName: 'NMC City Commissioner',
          role: 'CITY_ADMIN',
          action: 'ESCALATED_TO_RED_ALERT',
          issueId: 'doc_red_alert_1',
          trackingId: 'NMC-2026-8841',
          oldValue: 'SEVERITY_HIGH',
          newValue: 'RED_ALERT_CRITICAL',
          timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
        CityAuditLog(
          id: 'log_02',
          userUid: 'cso_04',
          userName: 'Rajesh Gaidhani',
          role: 'CSO_ZONAL_OFFICER',
          action: 'ASSIGNED_FIELD_SQUAD',
          issueId: 'doc_sos_1',
          trackingId: 'NMC-2026-9102',
          oldValue: 'UNASSIGNED',
          newValue: 'Contractor Squad 1 (Roads)',
          timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 20)),
        ),
        CityAuditLog(
          id: 'log_03',
          userUid: 'admin_master',
          userName: 'NMC City Commissioner',
          role: 'CITY_ADMIN',
          action: 'REOPENED_CITIZEN_REJECTED',
          issueId: 'doc_03',
          trackingId: 'NMC-2026-4412',
          oldValue: 'RESOLVED',
          newValue: 'REOPENED_PRIORITY_INCREASED',
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        ),
      ]);
    }

    return _mockAuditLogs;
  }

  @override
  Future<void> recordAuditLog(CityAuditLog log) async {
    _mockAuditLogs.insert(0, log);
    final db = _db;
    if (db != null) {
      try {
        await db.collection('auditLogs').doc(log.id).set(log.toMap());
      } catch (_) {}
    }
  }

  @override
  Future<void> performAdminAction({
    required String issueId,
    required String adminUid,
    required String adminName,
    required String actionType,
    required String details,
    String? assignedDepartment,
    String? assignedWorker,
    IssueStatus? newStatus,
  }) async {
    final issue = await issuesRepository.getIssueById(issueId);
    if (issue == null) return;

    if (actionType == 'REASSIGN_DEPT' && assignedDepartment != null) {
      await issuesRepository.updateIssueStatus(issueId, issue.status);
    } else if (actionType == 'CHANGE_STATUS' && newStatus != null) {
      await issuesRepository.updateIssueStatus(issueId, newStatus);
    } else if (actionType == 'REOPEN_CITIZEN_REJECT') {
      await issuesRepository.updateIssueStatus(issueId, IssueStatus.inProgress);
    }

    final audit = CityAuditLog(
      id: 'log_${DateTime.now().millisecondsSinceEpoch}',
      userUid: adminUid,
      userName: adminName,
      role: 'DEPT_ADMIN',
      action: actionType,
      issueId: issueId,
      trackingId: issue.trackingId,
      oldValue: 'Status: ${issue.status.toValue()}',
      newValue: details,
      timestamp: DateTime.now(),
    );

    await recordAuditLog(audit);

    if (actionType == 'ESCALATE_EMERGENCY') {
      final zoneId = AppConstants.wardToZoneIdMap[issue.ward] ?? 'zone_04';
      await notificationService.notifyCsoSosEmergency(
        zoneId: zoneId,
        trackingId: issue.trackingId,
        title: issue.title,
      );
    }
  }
}
