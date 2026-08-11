class ActiveWorkModel {
  final String id;
  final String issueId;
  final String departmentId;
  final String departmentName;
  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final String ward;
  final DateTime expectedCompletionDate;
  final int upvotesCount;
  final int flaggedStalledCount;
  final List<String> progressPhotoUrls;
  final DateTime createdAt;

  const ActiveWorkModel({
    required this.id,
    required this.issueId,
    required this.departmentId,
    required this.departmentName,
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.ward,
    required this.expectedCompletionDate,
    this.upvotesCount = 0,
    this.flaggedStalledCount = 0,
    this.progressPhotoUrls = const [],
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'issueId': issueId,
      'departmentId': departmentId,
      'departmentName': departmentName,
      'title': title,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'ward': ward,
      'expectedCompletionDate': expectedCompletionDate.toIso8601String(),
      'upvotesCount': upvotesCount,
      'flaggedStalledCount': flaggedStalledCount,
      'progressPhotoUrls': progressPhotoUrls,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ActiveWorkModel.fromMap(Map<String, dynamic> map, String docId) {
    return ActiveWorkModel(
      id: docId,
      issueId: map['issueId'] as String? ?? '',
      departmentId: map['departmentId'] as String? ?? '',
      departmentName: map['departmentName'] as String? ?? 'Nagpur Municipal Corp',
      title: map['title'] as String? ?? 'Work in Progress',
      description: map['description'] as String? ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 21.1458,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 79.0882,
      ward: map['ward'] as String? ?? 'Ward 1 - Laxmi Nagar',
      expectedCompletionDate: map['expectedCompletionDate'] != null
          ? DateTime.tryParse(map['expectedCompletionDate'].toString()) ??
              DateTime.now().add(const Duration(days: 3))
          : DateTime.now().add(const Duration(days: 3)),
      upvotesCount: (map['upvotesCount'] as num?)?.toInt() ?? 0,
      flaggedStalledCount: (map['flaggedStalledCount'] as num?)?.toInt() ?? 0,
      progressPhotoUrls:
          (map['progressPhotoUrls'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
