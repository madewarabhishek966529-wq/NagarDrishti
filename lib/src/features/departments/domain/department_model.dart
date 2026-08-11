class DepartmentModel {
  final String id;
  final String name;
  final String code;
  final String icon;
  final String contactEmail;
  final int activeTicketsCount;

  const DepartmentModel({
    required this.id,
    required this.name,
    required this.code,
    required this.icon,
    required this.contactEmail,
    this.activeTicketsCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'icon': icon,
      'contactEmail': contactEmail,
      'activeTicketsCount': activeTicketsCount,
    };
  }

  factory DepartmentModel.fromMap(Map<String, dynamic> map, String docId) {
    return DepartmentModel(
      id: docId,
      name: map['name'] as String? ?? '',
      code: map['code'] as String? ?? '',
      icon: map['icon'] as String? ?? 'business',
      contactEmail: map['contactEmail'] as String? ?? '',
      activeTicketsCount: (map['activeTicketsCount'] as num?)?.toInt() ?? 0,
    );
  }
}
