import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/issue_model.dart';
import 'duplicate_detection_service.dart';
import '../../notifications/data/notification_service.dart';

abstract class IssuesRepository {
  Future<IssueModel> createIssue(IssueModel issue);
  Future<IssueModel> processNewIssueWithClustering(
    IssueModel issue,
    DuplicateDetectionService duplicateService,
    NotificationService notificationService,
  );
  Future<List<IssueModel>> fetchIssues();
  Future<List<IssueModel>> fetchRedAlertIssues();
  Future<List<IssueModel>> fetchIssuesByWard(String ward);
  Future<IssueModel?> getIssueById(String id);
  Future<void> resolveIssueWithProof({
    required String issueId,
    required String afterImageUrl,
    required double fixQualityScore,
    required bool isVerifiedFixed,
    required String verificationSummary,
  });
  Future<void> reopenIssue({
    required String issueId,
    required String citizenFeedback,
  });
  Future<void> rateResolvedIssue({
    required String issueId,
    required int rating,
    String? feedback,
  });
  Future<void> updateIssueStatus(String issueId, IssueStatus newStatus);
}

class FirestoreIssuesRepository implements IssuesRepository {
  final FirebaseFirestore? _customFirestore;
  final List<IssueModel> _mockIssues = [];

  FirestoreIssuesRepository({FirebaseFirestore? firestore})
      : _customFirestore = firestore {
    _seedMockData();
  }

  void _seedMockData() {
    if (_mockIssues.isEmpty) {
      _mockIssues.addAll([
        IssueModel(
          id: 'doc_red_alert_1',
          trackingId: 'NAG-8942',
          title: 'Major Sewer Water Overflow on Wardha Road',
          description: 'Dangerous sewage water overflowing onto main traffic road near Dharampeth Square.',
          category: 'Drainage & Waterlogging',
          severity: IssueSeverity.critical,
          confidenceScore: 0.96,
          imageUrl: 'https://images.unsplash.com/photo-1515162816999-a0c47dc192f7',
          afterImageUrl: 'https://images.unsplash.com/photo-1541888946425-d0fbb186a5b7',
          fixQualityScore: 0.95,
          isVerifiedFixed: true,
          verificationSummary: 'Gemini Vision AI: Road asphalt patch is seamless and drainage is clear.',
          latitude: 21.1458,
          longitude: 79.0882,
          address: 'Wardha Road, Dharampeth, Nagpur',
          ward: 'Ward 2 - Dharampeth',
          status: IssueStatus.resolved,
          redAlert: true,
          reportCount: 14,
          createdBy: 'user_101',
          assignedDepartmentId: 'DEPT_WATER',
          assignedWorker: 'Ramesh Kumar (Zone 2 Team)',
          estimatedCost: 15000,
          createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
          updatedAt: DateTime.now().subtract(const Duration(minutes: 5)),
          slaDeadline: DateTime.now().add(const Duration(hours: 48)),
        ),
        IssueModel(
          id: 'doc_red_alert_2',
          trackingId: 'NAG-7710',
          title: 'Deep Hazardous Pothole near Square',
          description: 'Multiple vehicles damaged due to deep asphalt crater on active lane.',
          category: 'Pothole & Roads',
          severity: IssueSeverity.critical,
          confidenceScore: 0.94,
          imageUrl: 'https://images.unsplash.com/photo-1584467735871-8e85353a8413',
          latitude: 21.1380,
          longitude: 79.0720,
          address: 'Dhantoli Square, Nagpur',
          ward: 'Ward 4 - Dhantoli',
          status: IssueStatus.inProgress,
          redAlert: true,
          reportCount: 11,
          createdBy: 'user_102',
          assignedDepartmentId: 'DEPT_ROADS',
          assignedWorker: 'Sunil Patil (Contractor Squad)',
          estimatedCost: 22000,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          updatedAt: DateTime.now().subtract(const Duration(minutes: 20)),
          slaDeadline: DateTime.now().add(const Duration(hours: 120)),
        ),
      ]);
    }
  }

  FirebaseFirestore? get _db {
    if (_customFirestore != null) return _customFirestore;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<IssueModel> createIssue(IssueModel issue) async {
    final db = _db;
    if (db != null) {
      try {
        final docRef = db.collection('issues').doc(issue.id);
        await docRef.set(issue.toMap());
        return issue;
      } catch (_) {}
    }

    _mockIssues.insert(0, issue);
    return issue;
  }

  @override
  Future<IssueModel> processNewIssueWithClustering(
    IssueModel issue,
    DuplicateDetectionService duplicateService,
    NotificationService notificationService,
  ) async {
    final existing = await fetchIssues();
    final match = duplicateService.findNearbyDuplicate(issue, existing);

    if (match.isDuplicate && match.parentIssue != null) {
      final parent = match.parentIssue!;
      final updatedReportCount = parent.reportCount + 1;
      final isNowRedAlert = updatedReportCount >= 10;

      final updatedParent = IssueModel(
        id: parent.id,
        trackingId: parent.trackingId,
        title: parent.title,
        description: parent.description,
        category: parent.category,
        subCategory: parent.subCategory,
        severity: isNowRedAlert ? IssueSeverity.critical : parent.severity,
        confidenceScore: parent.confidenceScore,
        imageUrl: parent.imageUrl,
        afterImageUrl: parent.afterImageUrl,
        latitude: parent.latitude,
        longitude: parent.longitude,
        address: parent.address,
        ward: parent.ward,
        status: parent.status,
        redAlert: isNowRedAlert || parent.redAlert,
        reportCount: updatedReportCount,
        parentIssueId: parent.parentIssueId,
        createdBy: parent.createdBy,
        assignedDepartmentId: parent.assignedDepartmentId,
        createdAt: parent.createdAt,
        updatedAt: DateTime.now(),
        slaDeadline: parent.slaDeadline,
      );

      // Create linked child ticket
      final childTicket = IssueModel(
        id: issue.id,
        trackingId: issue.trackingId,
        title: issue.title,
        description: issue.description,
        category: issue.category,
        subCategory: issue.subCategory,
        severity: issue.severity,
        confidenceScore: issue.confidenceScore,
        imageUrl: issue.imageUrl,
        latitude: issue.latitude,
        longitude: issue.longitude,
        address: issue.address,
        ward: issue.ward,
        status: issue.status,
        redAlert: updatedParent.redAlert,
        reportCount: 1,
        parentIssueId: parent.id,
        createdBy: issue.createdBy,
        assignedDepartmentId: issue.assignedDepartmentId,
        createdAt: issue.createdAt,
        updatedAt: issue.updatedAt,
        slaDeadline: issue.slaDeadline,
      );

      await createIssue(childTicket);
      await createIssue(updatedParent);

      if (isNowRedAlert && !parent.redAlert) {
        await notificationService.sendRedAlertPushNotification(
          departmentId: parent.assignedDepartmentId,
          ward: parent.ward,
          trackingId: parent.trackingId,
          reportCount: updatedReportCount,
        );
        await notificationService.notifyCitizensEscalated(
          trackingId: parent.trackingId,
          reportCount: updatedReportCount,
        );
      }

      return childTicket;
    }

    return await createIssue(issue);
  }

  @override
  Future<List<IssueModel>> fetchIssues() async {
    final db = _db;
    if (db != null) {
      try {
        final snapshot = await db.collection('issues').orderBy('createdAt', descending: true).get();
        return snapshot.docs.map((doc) => IssueModel.fromMap(doc.data(), doc.id)).toList();
      } catch (_) {}
    }
    return _mockIssues;
  }

  @override
  Future<List<IssueModel>> fetchRedAlertIssues() async {
    final all = await fetchIssues();
    return all.where((i) => i.redAlert).toList();
  }

  @override
  Future<List<IssueModel>> fetchIssuesByWard(String ward) async {
    final all = await fetchIssues();
    return all.where((i) => i.ward == ward).toList();
  }

  @override
  Future<IssueModel?> getIssueById(String id) async {
    final all = await fetchIssues();
    try {
      return all.firstWhere((i) => i.id == id || i.trackingId == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> resolveIssueWithProof({
    required String issueId,
    required String afterImageUrl,
    required double fixQualityScore,
    required bool isVerifiedFixed,
    required String verificationSummary,
  }) async {
    final db = _db;
    final data = {
      'afterImageUrl': afterImageUrl,
      'fixQualityScore': fixQualityScore,
      'isVerifiedFixed': isVerifiedFixed,
      'verificationSummary': verificationSummary,
      'status': IssueStatus.resolved.toValue(),
      'updatedAt': DateTime.now().toIso8601String(),
    };

    if (db != null) {
      try {
        await db.collection('issues').doc(issueId).update(data);
      } catch (_) {}
    }

    final index = _mockIssues.indexWhere((i) => i.id == issueId || i.trackingId == issueId);
    if (index != -1) {
      final old = _mockIssues[index];
      _mockIssues[index] = IssueModel(
        id: old.id,
        trackingId: old.trackingId,
        title: old.title,
        description: old.description,
        category: old.category,
        severity: old.severity,
        confidenceScore: old.confidenceScore,
        imageUrl: old.imageUrl,
        afterImageUrl: afterImageUrl,
        fixQualityScore: fixQualityScore,
        isVerifiedFixed: isVerifiedFixed,
        verificationSummary: verificationSummary,
        latitude: old.latitude,
        longitude: old.longitude,
        address: old.address,
        ward: old.ward,
        status: IssueStatus.resolved,
        redAlert: old.redAlert,
        reportCount: old.reportCount,
        createdBy: old.createdBy,
        assignedDepartmentId: old.assignedDepartmentId,
        assignedWorker: old.assignedWorker,
        estimatedCost: old.estimatedCost,
        createdAt: old.createdAt,
        updatedAt: DateTime.now(),
        slaDeadline: old.slaDeadline,
      );
    }
  }

  @override
  Future<void> reopenIssue({
    required String issueId,
    required String citizenFeedback,
  }) async {
    final db = _db;
    final index = _mockIssues.indexWhere((i) => i.id == issueId || i.trackingId == issueId);
    final old = index != -1 ? _mockIssues[index] : null;
    final reopenCount = (old?.reopenCount ?? 0) + 1;

    final data = {
      'status': IssueStatus.inProgress.toValue(),
      'reopenCount': reopenCount,
      'citizenFeedback': citizenFeedback,
      'redAlert': true, // Auto escalate on re-open
      'updatedAt': DateTime.now().toIso8601String(),
    };

    if (db != null) {
      try {
        await db.collection('issues').doc(issueId).update(data);
      } catch (_) {}
    }

    if (old != null) {
      _mockIssues[index] = IssueModel(
        id: old.id,
        trackingId: old.trackingId,
        title: old.title,
        description: old.description,
        category: old.category,
        severity: IssueSeverity.critical,
        confidenceScore: old.confidenceScore,
        imageUrl: old.imageUrl,
        afterImageUrl: old.afterImageUrl,
        fixQualityScore: old.fixQualityScore,
        isVerifiedFixed: false,
        verificationSummary: 'Re-opened by citizen: $citizenFeedback',
        reopenCount: reopenCount,
        citizenFeedback: citizenFeedback,
        latitude: old.latitude,
        longitude: old.longitude,
        address: old.address,
        ward: old.ward,
        status: IssueStatus.inProgress,
        redAlert: true,
        reportCount: old.reportCount,
        createdBy: old.createdBy,
        assignedDepartmentId: old.assignedDepartmentId,
        assignedWorker: old.assignedWorker,
        estimatedCost: old.estimatedCost,
        createdAt: old.createdAt,
        updatedAt: DateTime.now(),
        slaDeadline: old.slaDeadline,
      );
    }
  }

  @override
  Future<void> rateResolvedIssue({
    required String issueId,
    required int rating,
    String? feedback,
  }) async {
    final db = _db;
    final data = {
      'citizenRating': rating,
      'citizenFeedback': feedback ?? '',
      'updatedAt': DateTime.now().toIso8601String(),
    };

    if (db != null) {
      try {
        await db.collection('issues').doc(issueId).update(data);
      } catch (_) {}
    }

    final index = _mockIssues.indexWhere((i) => i.id == issueId || i.trackingId == issueId);
    if (index != -1) {
      final old = _mockIssues[index];
      _mockIssues[index] = IssueModel(
        id: old.id,
        trackingId: old.trackingId,
        title: old.title,
        description: old.description,
        category: old.category,
        severity: old.severity,
        confidenceScore: old.confidenceScore,
        imageUrl: old.imageUrl,
        afterImageUrl: old.afterImageUrl,
        fixQualityScore: old.fixQualityScore,
        isVerifiedFixed: old.isVerifiedFixed,
        verificationSummary: old.verificationSummary,
        reopenCount: old.reopenCount,
        citizenRating: rating,
        citizenFeedback: feedback,
        latitude: old.latitude,
        longitude: old.longitude,
        address: old.address,
        ward: old.ward,
        status: old.status,
        redAlert: old.redAlert,
        reportCount: old.reportCount,
        createdBy: old.createdBy,
        assignedDepartmentId: old.assignedDepartmentId,
        assignedWorker: old.assignedWorker,
        estimatedCost: old.estimatedCost,
        createdAt: old.createdAt,
        updatedAt: DateTime.now(),
        slaDeadline: old.slaDeadline,
      );
    }
  }

  @override
  Future<void> updateIssueStatus(String issueId, IssueStatus newStatus) async {
    final db = _db;
    final data = {
      'status': newStatus.toValue(),
      'updatedAt': DateTime.now().toIso8601String(),
    };

    if (db != null) {
      try {
        await db.collection('issues').doc(issueId).update(data);
      } catch (_) {}
    }

    final index = _mockIssues.indexWhere((i) => i.id == issueId || i.trackingId == issueId);
    if (index != -1) {
      final old = _mockIssues[index];
      _mockIssues[index] = IssueModel(
        id: old.id,
        trackingId: old.trackingId,
        title: old.title,
        description: old.description,
        category: old.category,
        severity: old.severity,
        confidenceScore: old.confidenceScore,
        imageUrl: old.imageUrl,
        afterImageUrl: old.afterImageUrl,
        fixQualityScore: old.fixQualityScore,
        isVerifiedFixed: old.isVerifiedFixed,
        verificationSummary: old.verificationSummary,
        reopenCount: old.reopenCount,
        citizenRating: old.citizenRating,
        citizenFeedback: old.citizenFeedback,
        latitude: old.latitude,
        longitude: old.longitude,
        address: old.address,
        ward: old.ward,
        status: newStatus,
        redAlert: old.redAlert,
        reportCount: old.reportCount,
        createdBy: old.createdBy,
        assignedDepartmentId: old.assignedDepartmentId,
        assignedWorker: old.assignedWorker,
        estimatedCost: old.estimatedCost,
        createdAt: old.createdAt,
        updatedAt: DateTime.now(),
        slaDeadline: old.slaDeadline,
      );
    }
  }
}

