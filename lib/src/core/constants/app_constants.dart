enum SlaHealthStatus {
  safe,
  atRisk,
  overdue,
  critical;

  String get label {
    switch (this) {
      case SlaHealthStatus.safe:
        return 'SAFE';
      case SlaHealthStatus.atRisk:
        return 'AT RISK';
      case SlaHealthStatus.overdue:
        return 'OVERDUE';
      case SlaHealthStatus.critical:
        return 'CRITICAL';
    }
  }
}

class AppConstants {
  static const String appName = 'Vikasit Nagpur';
  static const String appSubtitle = 'AI Civic Issue Reporter & Smart Governance';

  // Nagpur Wards
  static const List<String> nagpurWards = [
    'Ward 1 - Laxmi Nagar',
    'Ward 2 - Dharampeth',
    'Ward 3 - Hanuman Nagar',
    'Ward 4 - Dhantoli',
    'Ward 5 - Nehru Nagar',
    'Ward 6 - Gandhibagh',
    'Ward 7 - Sataranjipura',
    'Ward 8 - Lakadganj',
    'Ward 9 - Ashi Nagar',
    'Ward 10 - Mangalwari',
  ];

  // NMC Zones Mapping (Zone ID -> Zone Name & Wards)
  static const Map<String, String> zoneIdToNameMap = {
    'zone_01': 'Laxmi Nagar',
    'zone_02': 'Dharampeth',
    'zone_03': 'Hanuman Nagar',
    'zone_04': 'Dhantoli',
    'zone_05': 'Nehru Nagar',
    'zone_06': 'Gandhibagh',
    'zone_07': 'Sataranjipura',
    'zone_08': 'Lakadganj',
    'zone_09': 'Ashi Nagar',
    'zone_10': 'Mangalwari',
  };

  static const String nmcCitizenHelpline = '1800-120-8040';

  // Zone CSO Zonal Officers Mapping
  static const Map<String, Map<String, String>> zoneCsoOfficersMap = {
    'zone_01': {'name': 'Sanjay Kulkarni', 'phone': '9823350101', 'designation': 'Zonal Officer / CSO'},
    'zone_02': {'name': 'Anil Deshmukh', 'phone': '9823350102', 'designation': 'Zonal Officer / CSO'},
    'zone_03': {'name': 'Pravin Mahajan', 'phone': '9823350103', 'designation': 'Zonal Officer / CSO'},
    'zone_04': {'name': 'Rajesh Gaidhani', 'phone': '9823350242', 'designation': 'Zonal Officer / CSO'},
    'zone_05': {'name': 'Vikas Patil', 'phone': '9823350105', 'designation': 'Zonal Officer / CSO'},
    'zone_06': {'name': 'Suresh Raut', 'phone': '9823350106', 'designation': 'Zonal Officer / CSO'},
    'zone_07': {'name': 'Manoj Shinde', 'phone': '9823350107', 'designation': 'Zonal Officer / CSO'},
    'zone_08': {'name': 'Ashok Wankhede', 'phone': '9823350108', 'designation': 'Zonal Officer / CSO'},
    'zone_09': {'name': 'Pradeep Meshram', 'phone': '9823350109', 'designation': 'Zonal Officer / CSO'},
    'zone_10': {'name': 'Nitendra Gawande', 'phone': '9823350110', 'designation': 'Zonal Officer / CSO'},
  };

  static const Map<String, String> wardToZoneIdMap = {
    'Ward 1 - Laxmi Nagar': 'zone_01',
    'Ward 2 - Dharampeth': 'zone_02',
    'Ward 3 - Hanuman Nagar': 'zone_03',
    'Ward 4 - Dhantoli': 'zone_04',
    'Ward 5 - Nehru Nagar': 'zone_05',
    'Ward 6 - Gandhibagh': 'zone_06',
    'Ward 7 - Sataranjipura': 'zone_07',
    'Ward 8 - Lakadganj': 'zone_08',
    'Ward 9 - Ashi Nagar': 'zone_09',
    'Ward 10 - Mangalwari': 'zone_10',
  };

  // Issue Categories & Departments Mapping
  static const Map<String, String> categoryToDepartmentMap = {
    'Pothole & Roads': 'DEPT_ROADS',
    'Drainage & Waterlogging': 'DEPT_WATER',
    'Streetlight & Electrical': 'DEPT_ELEC',
    'Garbage & Waste': 'DEPT_SANITATION',
    'Water Supply Leakage': 'DEPT_WATER',
    'Encroachment & Traffic': 'DEPT_TRAFFIC',
    'Tree Fall & Greenery': 'DEPT_GARDEN',
  };

  // SLA Hours per Category (SOS target = 4 hrs)
  static const Map<String, int> categorySlaHours = {
    'Streetlight & Electrical': 24,
    'Drainage & Waterlogging': 48,
    'Water Supply Leakage': 24,
    'Garbage & Waste': 48,
    'Pothole & Roads': 168, // 7 days
    'Encroachment & Traffic': 72,
    'Tree Fall & Greenery': 48,
    'SOS': 4,
  };

  static SlaHealthStatus calculateSlaStatus({
    required DateTime slaDeadline,
    required bool isResolved,
    required bool isRedAlert,
    required bool isCritical,
  }) {
    if (isResolved) return SlaHealthStatus.safe;
    if (isRedAlert || isCritical) return SlaHealthStatus.critical;
    final now = DateTime.now();
    if (now.isAfter(slaDeadline)) return SlaHealthStatus.overdue;
    final hoursRemaining = slaDeadline.difference(now).inHours;
    if (hoursRemaining <= 6) return SlaHealthStatus.atRisk;
    return SlaHealthStatus.safe;
  }
}

