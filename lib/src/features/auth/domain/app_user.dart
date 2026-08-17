enum UserRole {
  citizen,
  csoZonalOfficer,
  deptAdmin;

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'cso_zonal_officer':
      case 'cso':
      case 'zonal_officer':
      case 'csozonalofficer':
        return UserRole.csoZonalOfficer;
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
      case UserRole.csoZonalOfficer:
        return 'cso_zonal_officer';
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
  final String? zoneId;
  final String? zoneName;
  final bool active;
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
    this.zoneId,
    this.zoneName,
    this.active = true,
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
      'zoneId': zoneId,
      'zoneName': zoneName,
      'active': active,
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
      displayName: map['displayName'] as String? ?? 'Nagpur Resident',
      role: UserRole.fromString(map['role'] as String? ?? 'citizen'),
      departmentId: map['departmentId'] as String?,
      zoneId: map['zoneId'] as String?,
      zoneName: map['zoneName'] as String?,
      active: map['active'] as bool? ?? true,
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
    String? zoneId,
    String? zoneName,
    bool? active,
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
      zoneId: zoneId ?? this.zoneId,
      zoneName: zoneName ?? this.zoneName,
      active: active ?? this.active,
      reputationPoints: reputationPoints ?? this.reputationPoints,
      badges: badges ?? this.badges,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

