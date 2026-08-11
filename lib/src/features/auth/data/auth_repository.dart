import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> get authStateChanges;
  AppUser? get currentUser;
  Future<AppUser> signInWithEmailAndPassword(String email, String password);
  Future<AppUser> signInAsDepartmentAdmin(String email, String password, String departmentId);
  Future<AppUser> signInWithMockPhone(String phoneNumber, String otpCode);
  Future<void> signOut();
}

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth? _customAuth;
  final FirebaseFirestore? _customFirestore;

  AppUser? _cachedMockUser;

  FirebaseAuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _customAuth = firebaseAuth,
        _customFirestore = firestore;

  FirebaseAuth? get _auth {
    if (_customAuth != null) return _customAuth;
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
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
  Stream<AppUser?> get authStateChanges {
    final auth = _auth;
    if (auth == null) {
      return Stream.value(_cachedMockUser);
    }
    try {
      return auth.authStateChanges().asyncMap((user) async {
        if (user == null) return _cachedMockUser;
        final db = _db;
        if (db != null) {
          final doc = await db.collection('users').doc(user.uid).get();
          if (doc.exists && doc.data() != null) {
            return AppUser.fromMap(doc.data()!, doc.id);
          }
        }
        return AppUser(
          uid: user.uid,
          email: user.email ?? '',
          phoneNumber: user.phoneNumber ?? '',
          displayName: user.displayName ?? 'Nagpur Resident',
          role: UserRole.citizen,
          createdAt: DateTime.now(),
        );
      });
    } catch (_) {
      return Stream.value(_cachedMockUser);
    }
  }

  @override
  AppUser? get currentUser => _cachedMockUser;

  @override
  Future<AppUser> signInWithEmailAndPassword(String email, String password) async {
    final auth = _auth;
    final db = _db;

    if (auth != null && db != null) {
      try {
        final credential = await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        final user = credential.user!;
        final doc = await db.collection('users').doc(user.uid).get();
        AppUser appUser;
        if (doc.exists && doc.data() != null) {
          appUser = AppUser.fromMap(doc.data()!, doc.id);
        } else {
          appUser = AppUser(
            uid: user.uid,
            email: email,
            phoneNumber: '+91 9876543210',
            displayName: email.split('@').first,
            role: UserRole.citizen,
            createdAt: DateTime.now(),
          );
          await db.collection('users').doc(user.uid).set(appUser.toMap());
        }
        _cachedMockUser = appUser;
        return appUser;
      } catch (_) {}
    }

    // Fallback mock sign in
    final mockUser = AppUser(
      uid: 'mock_user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      phoneNumber: '+91 9876543210',
      displayName: email.split('@').first,
      role: UserRole.citizen,
      reputationPoints: 120,
      badges: ['Pothole Hunter', 'Verified Citizen'],
      createdAt: DateTime.now(),
    );
    _cachedMockUser = mockUser;
    return mockUser;
  }

  @override
  Future<AppUser> signInAsDepartmentAdmin(String email, String password, String departmentId) async {
    final auth = _auth;
    final db = _db;

    if (auth != null && db != null) {
      try {
        final credential = await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        final user = credential.user!;
        final appUser = AppUser(
          uid: user.uid,
          email: email,
          phoneNumber: '+91 9123456789',
          displayName: 'Officer (${departmentId.replaceAll("DEPT_", "")})',
          role: UserRole.deptAdmin,
          departmentId: departmentId,
          createdAt: DateTime.now(),
        );
        await db.collection('users').doc(user.uid).set(appUser.toMap());
        _cachedMockUser = appUser;
        return appUser;
      } catch (_) {}
    }

    // Mock department admin
    final mockAdmin = AppUser(
      uid: 'admin_${departmentId.toLowerCase()}',
      email: email,
      phoneNumber: '+91 9123456789',
      displayName: 'Admin (${departmentId.replaceAll("DEPT_", "")})',
      role: UserRole.deptAdmin,
      departmentId: departmentId,
      createdAt: DateTime.now(),
    );
    _cachedMockUser = mockAdmin;
    return mockAdmin;
  }

  @override
  Future<AppUser> signInWithMockPhone(String phoneNumber, String otpCode) async {
    final mockUser = AppUser(
      uid: 'citizen_phone_${phoneNumber.replaceAll(RegExp(r'\D'), '')}',
      email: '${phoneNumber.replaceAll(RegExp(r'\D'), '')}@nagpur.gov.in',
      phoneNumber: phoneNumber,
      displayName: 'Citizen ${phoneNumber.substring(phoneNumber.length - 4)}',
      role: UserRole.citizen,
      reputationPoints: 45,
      badges: ['Active Citizen'],
      createdAt: DateTime.now(),
    );
    _cachedMockUser = mockUser;
    return mockUser;
  }

  @override
  Future<void> signOut() async {
    final auth = _auth;
    if (auth != null) {
      try {
        await auth.signOut();
      } catch (_) {}
    }
    _cachedMockUser = null;
  }
}
