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

  // SLA Hours per Category
  static const Map<String, int> categorySlaHours = {
    'Streetlight & Electrical': 24,
    'Drainage & Waterlogging': 48,
    'Water Supply Leakage': 24,
    'Garbage & Waste': 48,
    'Pothole & Roads': 168, // 7 days
    'Encroachment & Traffic': 72,
    'Tree Fall & Greenery': 48,
  };
}
