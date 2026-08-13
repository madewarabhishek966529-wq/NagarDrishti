import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/active_work_model.dart';
import '../../issues/domain/issue_model.dart';
import '../../../core/utils/demo_seed_data.dart';

abstract class ActiveWorkRepository {
  Future<List<ActiveWorkModel>> fetchActiveWorks();
  Future<ActiveWorkModel> createActiveWorkFromIssue(IssueModel issue);
  Future<void> upvoteActiveWork(String workId);
  Future<void> flagStalledWork(String workId);
}

class FirestoreActiveWorkRepository implements ActiveWorkRepository {
  final FirebaseFirestore? _customFirestore;
  final List<ActiveWorkModel> _mockActiveWorks = DemoSeedData.getInitialActiveWorks();

  FirestoreActiveWorkRepository({FirebaseFirestore? firestore})
      : _customFirestore = firestore;

  FirebaseFirestore? get _db {
    if (_customFirestore != null) return _customFirestore;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<ActiveWorkModel>> fetchActiveWorks() async {
    final db = _db;
    if (db != null) {
      try {
        final snapshot = await db.collection('activeWork').orderBy('createdAt', descending: true).get();
        return snapshot.docs.map((doc) => ActiveWorkModel.fromMap(doc.data(), doc.id)).toList();
      } catch (_) {}
    }
    return _mockActiveWorks;
  }

  @override
  Future<ActiveWorkModel> createActiveWorkFromIssue(IssueModel issue) async {
    final workId = 'work_${DateTime.now().millisecondsSinceEpoch}';
    final activeWork = ActiveWorkModel(
      id: workId,
      issueId: issue.id,
      departmentId: issue.assignedDepartmentId,
      departmentName: 'Nagpur Department (${issue.assignedDepartmentId.replaceAll("DEPT_", "")})',
      title: 'Active Repair Work: ${issue.category}',
      description: 'Department crew deployed to address ticket ${issue.trackingId} in ${issue.ward}.',
      latitude: issue.latitude,
      longitude: issue.longitude,
      ward: issue.ward,
      expectedCompletionDate: issue.slaDeadline,
      upvotesCount: 1,
      flaggedStalledCount: 0,
      progressPhotoUrls: [issue.imageUrl],
      createdAt: DateTime.now(),
    );

    final db = _db;
    if (db != null) {
      try {
        await db.collection('activeWork').doc(workId).set(activeWork.toMap());
        return activeWork;
      } catch (_) {}
    }

    _mockActiveWorks.insert(0, activeWork);
    return activeWork;
  }

  @override
  Future<void> upvoteActiveWork(String workId) async {
    final db = _db;
    if (db != null) {
      try {
        await db.collection('activeWork').doc(workId).update({
          'upvotesCount': FieldValue.increment(1),
        });
        return;
      } catch (_) {}
    }

    final index = _mockActiveWorks.indexWhere((w) => w.id == workId);
    if (index != -1) {
      final old = _mockActiveWorks[index];
      _mockActiveWorks[index] = ActiveWorkModel(
        id: old.id,
        issueId: old.issueId,
        departmentId: old.departmentId,
        departmentName: old.departmentName,
        title: old.title,
        description: old.description,
        latitude: old.latitude,
        longitude: old.longitude,
        ward: old.ward,
        expectedCompletionDate: old.expectedCompletionDate,
        upvotesCount: old.upvotesCount + 1,
        flaggedStalledCount: old.flaggedStalledCount,
        progressPhotoUrls: old.progressPhotoUrls,
        createdAt: old.createdAt,
      );
    }
  }

  @override
  Future<void> flagStalledWork(String workId) async {
    final db = _db;
    if (db != null) {
      try {
        await db.collection('activeWork').doc(workId).update({
          'flaggedStalledCount': FieldValue.increment(1),
        });
        return;
      } catch (_) {}
    }

    final index = _mockActiveWorks.indexWhere((w) => w.id == workId);
    if (index != -1) {
      final old = _mockActiveWorks[index];
      _mockActiveWorks[index] = ActiveWorkModel(
        id: old.id,
        issueId: old.issueId,
        departmentId: old.departmentId,
        departmentName: old.departmentName,
        title: old.title,
        description: old.description,
        latitude: old.latitude,
        longitude: old.longitude,
        ward: old.ward,
        expectedCompletionDate: old.expectedCompletionDate,
        upvotesCount: old.upvotesCount,
        flaggedStalledCount: old.flaggedStalledCount + 1,
        progressPhotoUrls: old.progressPhotoUrls,
        createdAt: old.createdAt,
      );
    }
  }
}
