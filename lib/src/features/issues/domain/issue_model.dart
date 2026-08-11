enum IssueStatus {
  reported,
  acknowledged,
  inProgress,
  resolved;

  static IssueStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'acknowledged':
        return IssueStatus.acknowledged;
      case 'inprogress':
      case 'in_progress':
      case 'in progress':
        return IssueStatus.inProgress;
      case 'resolved':
        return IssueStatus.resolved;
      case 'reported':
      default:
        return IssueStatus.reported;
    }
  }

  String toValue() {
    switch (this) {
      case IssueStatus.reported:
        return 'Reported';
      case IssueStatus.acknowledged:
        return 'Acknowledged';
      case IssueStatus.inProgress:
        return 'In Progress';
      case IssueStatus.resolved:
        return 'Resolved';
    }
  }
}

enum IssueSeverity {
  low,
  medium,
  high,
  critical;

  static IssueSeverity fromString(String severity) {
    switch (severity.toLowerCase()) {
      case 'medium':
        return IssueSeverity.medium;
      case 'high':
        return IssueSeverity.high;
      case 'critical':
        return IssueSeverity.critical;
      case 'low':
      default:
        return IssueSeverity.low;
    }
  }

  String toValue() {
    return name;
  }
}

class IssueModel {
  final String id;
  final String trackingId;
  final String title;
  final String description;
  final String category;
  final String subCategory;
  final IssueSeverity severity;
  final double confidenceScore;
  final String imageUrl;
  final String? afterImageUrl;
  final double latitude;
  final double longitude;
  final String address;
  final String ward;
  final IssueStatus status;
  final bool redAlert;
  final int reportCount;
  final String? parentIssueId;
  final String createdBy;
  final String assignedDepartmentId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime slaDeadline;

  const IssueModel({
    required this.id,
    required this.trackingId,
    required this.title,
    required this.description,
    required this.category,
    this.subCategory = '',
    required this.severity,
    required this.confidenceScore,
    required this.imageUrl,
    this.afterImageUrl,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.ward,
    required this.status,
    this.redAlert = false,
    this.reportCount = 1,
    this.parentIssueId,
    required this.createdBy,
    required this.assignedDepartmentId,
    required this.createdAt,
    required this.updatedAt,
    required this.slaDeadline,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trackingId': trackingId,
      'title': title,
      'description': description,
      'category': category,
      'subCategory': subCategory,
      'severity': severity.toValue(),
      'confidenceScore': confidenceScore,
      'imageUrl': imageUrl,
      'afterImageUrl': afterImageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'ward': ward,
      'status': status.toValue(),
      'redAlert': redAlert,
      'reportCount': reportCount,
      'parentIssueId': parentIssueId,
      'createdBy': createdBy,
      'assignedDepartmentId': assignedDepartmentId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'slaDeadline': slaDeadline.toIso8601String(),
    };
  }

  factory IssueModel.fromMap(Map<String, dynamic> map, String docId) {
    return IssueModel(
      id: docId,
      trackingId: map['trackingId'] as String? ?? docId.substring(0, 8).toUpperCase(),
      title: map['title'] as String? ?? 'Civic Issue',
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? 'Pothole & Roads',
      subCategory: map['subCategory'] as String? ?? '',
      severity: IssueSeverity.fromString(map['severity'] as String? ?? 'medium'),
      confidenceScore: (map['confidenceScore'] as num?)?.toDouble() ?? 0.85,
      imageUrl: map['imageUrl'] as String? ?? '',
      afterImageUrl: map['afterImageUrl'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble() ?? 21.1458,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 79.0882,
      address: map['address'] as String? ?? 'Nagpur, Maharashtra',
      ward: map['ward'] as String? ?? 'Ward 1 - Laxmi Nagar',
      status: IssueStatus.fromString(map['status'] as String? ?? 'Reported'),
      redAlert: map['redAlert'] as bool? ?? false,
      reportCount: (map['reportCount'] as num?)?.toInt() ?? 1,
      parentIssueId: map['parentIssueId'] as String?,
      createdBy: map['createdBy'] as String? ?? '',
      assignedDepartmentId: map['assignedDepartmentId'] as String? ?? 'DEPT_ROADS',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      slaDeadline: map['slaDeadline'] != null
          ? DateTime.tryParse(map['slaDeadline'].toString()) ??
              DateTime.now().add(const Duration(hours: 48))
          : DateTime.now().add(const Duration(hours: 48)),
    );
  }
}
