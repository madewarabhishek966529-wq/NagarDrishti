enum UserRole {
  citizen,
  deptAdmin;

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'deptadmin':
      case 'dept_admin':
      case 'department_admin':
        return UserRole.deptAdmin;
      case 'citizen':
      default:
        return UserRole.citizen;
    }
  }

  String toValue() {
    switch (this) {
      case UserRole.deptAdmin:
        return 'dept_admin';
      case UserRole.citizen:
        return 'citizen';
    }
  }
}

class AppUser {
  final String uid;
  final String email;
  final String phoneNumber;
  final String displayName;
  final UserRole role;
  final String? departmentId;
  final int reputationPoints;
  final List<String> badges;
  final DateTime createdAt;

  const AppUser({
    required this.uid,
    required this.email,
    required this.phoneNumber,
    required this.displayName,
    required this.role,
    this.departmentId,
    this.reputationPoints = 0,
    this.badges = const [],
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'phoneNumber': phoneNumber,
      'displayName': displayName,
      'role': role.toValue(),
      'departmentId': departmentId,
      'reputationPoints': reputationPoints,
      'badges': badges,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map, String docId) {
    return AppUser(
      uid: docId,
      email: map['email'] as String? ?? '',
      phoneNumber: map['phoneNumber'] as String? ?? '',
      displayName: map['displayName'] as String? ?? 'Nagpur Citizen',
      role: UserRole.fromString(map['role'] as String? ?? 'citizen'),
      departmentId: map['departmentId'] as String?,
      reputationPoints: (map['reputationPoints'] as num?)?.toInt() ?? 0,
      badges: (map['badges'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  AppUser copyWith({
    String? uid,
    String? email,
    String? phoneNumber,
    String? displayName,
    UserRole? role,
    String? departmentId,
    int? reputationPoints,
    List<String>? badges,
    DateTime? createdAt,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      departmentId: departmentId ?? this.departmentId,
      reputationPoints: reputationPoints ?? this.reputationPoints,
      badges: badges ?? this.badges,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
