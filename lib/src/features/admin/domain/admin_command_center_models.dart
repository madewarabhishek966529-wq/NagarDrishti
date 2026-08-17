class CityKpiOverview {
  final int totalComplaints;
  final int criticalComplaints;
  final int redAlertCount;
  final int sosCount;
  final int overdueComplaints;
  final int atRiskComplaints;
  final int inProgressComplaints;
  final int resolvedComplaints;
  final double overallSlaCompliancePercentage;
  final double totalEstimatedBudgetSpent;

  const CityKpiOverview({
    required this.totalComplaints,
    required this.criticalComplaints,
    required this.redAlertCount,
    required this.sosCount,
    required this.overdueComplaints,
    required this.atRiskComplaints,
    required this.inProgressComplaints,
    required this.resolvedComplaints,
    required this.overallSlaCompliancePercentage,
    required this.totalEstimatedBudgetSpent,
  });
}

enum ZoneHealthGrade {
  excellent('A+', 0xFF10B981),
  good('B', 0xFF3B82F6),
  fair('C', 0xFFF59E0B),
  poor('D', 0xFFF97316),
  critical('F', 0xFFEF4444);

  final String label;
  final int colorHex;
  const ZoneHealthGrade(this.label, this.colorHex);
}

class ZonePerformanceDetail {
  final String zoneId;
  final String zoneName;
  final int complaintCount;
  final int criticalCount;
  final int redAlertCount;
  final int overdueCount;
  final double slaCompliancePercentage;
  final double averageResolutionTimeHours;
  final double citizenValidationScore;
  final double citizenRejectionRate;
  final ZoneHealthGrade zoneHealth;
  final String assignedCsoName;
  final String assignedCsoPhone;

  const ZonePerformanceDetail({
    required this.zoneId,
    required this.zoneName,
    required this.complaintCount,
    required this.criticalCount,
    required this.redAlertCount,
    required this.overdueCount,
    required this.slaCompliancePercentage,
    required this.averageResolutionTimeHours,
    required this.citizenValidationScore,
    required this.citizenRejectionRate,
    required this.zoneHealth,
    required this.assignedCsoName,
    required this.assignedCsoPhone,
  });
}

class DepartmentPerformanceDetail {
  final String departmentId;
  final String departmentName;
  final int assignedComplaints;
  final int inProgressComplaints;
  final int resolvedComplaints;
  final int overdueComplaints;
  final double slaCompliancePercentage;
  final double averageResolutionTimeHours;
  final int citizenRejectionCount;
  final int reopenedCount;

  const DepartmentPerformanceDetail({
    required this.departmentId,
    required this.departmentName,
    required this.assignedComplaints,
    required this.inProgressComplaints,
    required this.resolvedComplaints,
    required this.overdueComplaints,
    required this.slaCompliancePercentage,
    required this.averageResolutionTimeHours,
    required this.citizenRejectionCount,
    required this.reopenedCount,
  });
}

class CsoOfficerDetail {
  final String uid;
  final String name;
  final String phone;
  final String email;
  final String zoneId;
  final String zoneName;
  final bool active;
  final int assignedComplaints;
  final int criticalComplaints;
  final int resolvedComplaints;
  final int overdueComplaints;
  final double slaCompliancePercentage;
  final double averageResolutionTimeHours;

  const CsoOfficerDetail({
    required this.uid,
    required this.name,
    required this.phone,
    required this.email,
    required this.zoneId,
    required this.zoneName,
    required this.active,
    required this.assignedComplaints,
    required this.criticalComplaints,
    required this.resolvedComplaints,
    required this.overdueComplaints,
    required this.slaCompliancePercentage,
    required this.averageResolutionTimeHours,
  });
}

class FinancialAnalyticsModel {
  final double estimatedTotalRepairCost;
  final double allocatedBudget;
  final double actualExpenditure;
  final double remainingBudget;
  final Map<String, double> zoneWiseExpenditure;
  final Map<String, double> departmentWiseExpenditure;
  final Map<String, double> contractorWiseExpenditure;

  const FinancialAnalyticsModel({
    required this.estimatedTotalRepairCost,
    required this.allocatedBudget,
    required this.actualExpenditure,
    required this.remainingBudget,
    required this.zoneWiseExpenditure,
    required this.departmentWiseExpenditure,
    required this.contractorWiseExpenditure,
  });
}

class CityAuditLog {
  final String id;
  final String userUid;
  final String userName;
  final String role;
  final String action;
  final String issueId;
  final String trackingId;
  final String oldValue;
  final String newValue;
  final DateTime timestamp;

  const CityAuditLog({
    required this.id,
    required this.userUid,
    required this.userName,
    required this.role,
    required this.action,
    required this.issueId,
    required this.trackingId,
    required this.oldValue,
    required this.newValue,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userUid': userUid,
      'userName': userName,
      'role': role,
      'action': action,
      'issueId': issueId,
      'trackingId': trackingId,
      'oldValue': oldValue,
      'newValue': newValue,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory CityAuditLog.fromMap(Map<String, dynamic> map, String docId) {
    return CityAuditLog(
      id: docId,
      userUid: map['userUid'] as String? ?? 'system',
      userName: map['userName'] as String? ?? 'NMC Admin Authority',
      role: map['role'] as String? ?? 'DEPT_ADMIN',
      action: map['action'] as String? ?? 'UPDATE',
      issueId: map['issueId'] as String? ?? '',
      trackingId: map['trackingId'] as String? ?? 'N/A',
      oldValue: map['oldValue'] as String? ?? '',
      newValue: map['newValue'] as String? ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
