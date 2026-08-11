import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/issue_model.dart';

abstract class IssuesRepository {
  Future<IssueModel> createIssue(IssueModel issue);
  Future<List<IssueModel>> fetchIssues();
  Future<List<IssueModel>> fetchIssuesByWard(String ward);
}

class FirestoreIssuesRepository implements IssuesRepository {
  final FirebaseFirestore? _customFirestore;
  final List<IssueModel> _mockIssues = [];

  FirestoreIssuesRepository({FirebaseFirestore? firestore})
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
  Future<List<IssueModel>> fetchIssuesByWard(String ward) async {
    final db = _db;
    if (db != null) {
      try {
        final snapshot = await db
            .collection('issues')
            .where('ward', isEqualTo: ward)
            .orderBy('createdAt', descending: true)
            .get();
        return snapshot.docs.map((doc) => IssueModel.fromMap(doc.data(), doc.id)).toList();
      } catch (_) {}
    }
    return _mockIssues.where((i) => i.ward == ward).toList();
  }
}
