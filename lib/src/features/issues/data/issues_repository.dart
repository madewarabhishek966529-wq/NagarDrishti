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
          latitude: 21.1458,
          longitude: 79.0882,
          address: 'Wardha Road, Dharampeth, Nagpur',
          ward: 'Ward 2 - Dharampeth',
          status: IssueStatus.reported,
          redAlert: true,
          reportCount: 14,
          createdBy: 'user_101',
          assignedDepartmentId: 'DEPT_WATER',
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
}
