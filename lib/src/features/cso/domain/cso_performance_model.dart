class CsoZonePerformance {
  final String zoneId;
  final String zoneName;
  final int totalComplaints;
  final int newComplaints;
  final int pendingComplaints;
  final int inProgressComplaints;
  final int resolvedComplaints;
  final int overdueComplaints;
  final int criticalComplaints;
  final int redAlertCount;
  final int approachingSlaCount;
  final int awaitingValidationCount;
  final double averageResolutionTimeHours;
  final double slaComplianceRatePercentage;
  final double citizenValidationScore;
  final int reopenedCount;

  const CsoZonePerformance({
    required this.zoneId,
    required this.zoneName,
    required this.totalComplaints,
    required this.newComplaints,
    required this.pendingComplaints,
    required this.inProgressComplaints,
    required this.resolvedComplaints,
    required this.overdueComplaints,
    required this.criticalComplaints,
    required this.redAlertCount,
    required this.approachingSlaCount,
    required this.awaitingValidationCount,
    required this.averageResolutionTimeHours,
    required this.slaComplianceRatePercentage,
    required this.citizenValidationScore,
    required this.reopenedCount,
  });

  factory CsoZonePerformance.empty(String zoneId, String zoneName) {
    return CsoZonePerformance(
      zoneId: zoneId,
      zoneName: zoneName,
      totalComplaints: 0,
      newComplaints: 0,
      pendingComplaints: 0,
      inProgressComplaints: 0,
      resolvedComplaints: 0,
      overdueComplaints: 0,
      criticalComplaints: 0,
      redAlertCount: 0,
      approachingSlaCount: 0,
      awaitingValidationCount: 0,
      averageResolutionTimeHours: 0.0,
      slaComplianceRatePercentage: 100.0,
      citizenValidationScore: 5.0,
      reopenedCount: 0,
    );
  }
}

class CsoActionLog {
  final String id;
  final String issueId;
  final String trackingId;
  final String officerUid;
  final String officerName;
  final String actionType; // ACCEPT, ASSIGN_SQUAD, IN_PROGRESS, ADD_NOTE, ESCALATE, UPLOAD_EVIDENCE, REQUEST_INSPECTION, REVIEW_PROOF, REQUEST_VALIDATION
  final String details;
  final String? evidenceUrl;
  final DateTime timestamp;

  const CsoActionLog({
    required this.id,
    required this.issueId,
    required this.trackingId,
    required this.officerUid,
    required this.officerName,
    required this.actionType,
    required this.details,
    this.evidenceUrl,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'issueId': issueId,
      'trackingId': trackingId,
      'officerUid': officerUid,
      'officerName': officerName,
      'actionType': actionType,
      'details': details,
      'evidenceUrl': evidenceUrl,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory CsoActionLog.fromMap(Map<String, dynamic> map, String docId) {
    return CsoActionLog(
      id: docId,
      issueId: map['issueId'] as String? ?? '',
      trackingId: map['trackingId'] as String? ?? '',
      officerUid: map['officerUid'] as String? ?? '',
      officerName: map['officerName'] as String? ?? 'CSO Officer',
      actionType: map['actionType'] as String? ?? 'ACTION',
      details: map['details'] as String? ?? '',
      evidenceUrl: map['evidenceUrl'] as String?,
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
