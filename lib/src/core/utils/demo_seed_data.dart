import '../../features/issues/domain/issue_model.dart';
import '../../features/active_work/domain/active_work_model.dart';
import '../../features/weather/domain/weather_cache_model.dart';

class DemoSeedData {
  static List<IssueModel> getInitialIssues() {
    final now = DateTime.now();

    return [
      IssueModel(
        id: 'doc_red_alert_1',
        trackingId: 'NAG-8942',
        title: 'Major Sewer Water Leakage on Wardha Road',
        description: 'Dangerous sewage water overflowing onto main traffic road near Dharampeth Square.',
        category: 'Drainage & Waterlogging',
        severity: IssueSeverity.critical,
        confidenceScore: 0.96,
        imageUrl: 'https://images.unsplash.com/photo-1515162816999-a0c47dc192f7',
        latitude: 21.1458,
        longitude: 79.0882,
        address: 'Wardha Road, Dharampeth, Nagpur',
        ward: 'Ward 2 - Dharampeth',
        status: IssueStatus.reported,
        redAlert: true,
        reportCount: 14,
        createdBy: 'citizen_101',
        assignedDepartmentId: 'DEPT_WATER',
        createdAt: now.subtract(const Duration(minutes: 25)),
        updatedAt: now.subtract(const Duration(minutes: 5)),
        slaDeadline: now.add(const Duration(hours: 48)),
      ),
      IssueModel(
        id: 'doc_red_alert_2',
        trackingId: 'NAG-7710',
        title: 'Dangerous Deep Pothole near Dhantoli Square',
        description: 'Multiple vehicles damaged due to deep asphalt crater on active lane.',
        category: 'Pothole & Roads',
        severity: IssueSeverity.critical,
        confidenceScore: 0.94,
        imageUrl: 'https://images.unsplash.com/photo-1584467735871-8e85353a8413',
        latitude: 21.1380,
        longitude: 79.0720,
        address: 'Dhantoli Square, Nagpur',
        ward: 'Ward 4 - Dhantoli',
        status: IssueStatus.inProgress,
        redAlert: true,
        reportCount: 11,
        createdBy: 'citizen_102',
        assignedDepartmentId: 'DEPT_ROADS',
        createdAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now.subtract(const Duration(minutes: 20)),
        slaDeadline: now.add(const Duration(hours: 120)),
      ),
      IssueModel(
        id: 'doc_resolved_1',
        trackingId: 'NAG-6520',
        title: 'Broken Streetlight Poles Restored',
        description: 'Streetlight array replaced and re-electrified along Laxmi Nagar main avenue.',
        category: 'Streetlight & Electrical',
        severity: IssueSeverity.medium,
        confidenceScore: 0.92,
        imageUrl: 'https://images.unsplash.com/photo-1509114397022-ed747cca3f65',
        afterImageUrl: 'https://images.unsplash.com/photo-1513694203232-719a280e022f',
        latitude: 21.1250,
        longitude: 79.0650,
        address: 'Laxmi Nagar Main Avenue, Nagpur',
        ward: 'Ward 1 - Laxmi Nagar',
        status: IssueStatus.resolved,
        redAlert: false,
        reportCount: 4,
        createdBy: 'citizen_103',
        assignedDepartmentId: 'DEPT_ELEC',
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(hours: 3)),
        slaDeadline: now.subtract(const Duration(hours: 1)),
      ),
      IssueModel(
        id: 'doc_resolved_2',
        trackingId: 'NAG-5412',
        title: 'Garbage Dump Cleared & Sanitized',
        description: 'Solid waste accumulation removed near Hanuman Nagar ground.',
        category: 'Garbage & Waste',
        severity: IssueSeverity.high,
        confidenceScore: 0.95,
        imageUrl: 'https://images.unsplash.com/photo-1532996122724-e3c354a0b15b',
        afterImageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e',
        latitude: 21.1310,
        longitude: 79.0910,
        address: 'Hanuman Nagar Ground, Nagpur',
        ward: 'Ward 3 - Hanuman Nagar',
        status: IssueStatus.resolved,
        redAlert: false,
        reportCount: 6,
        createdBy: 'citizen_104',
        assignedDepartmentId: 'DEPT_SANITATION',
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(hours: 8)),
        slaDeadline: now.subtract(const Duration(hours: 6)),
      ),
    ];
  }

  static List<ActiveWorkModel> getInitialActiveWorks() {
    final now = DateTime.now();

    return [
      ActiveWorkModel(
        id: 'work_1',
        issueId: 'doc_red_alert_2',
        departmentId: 'DEPT_ROADS',
        departmentName: 'Nagpur Municipal Corp - Road Division',
        title: 'Asphalt Patching & Resurfacing Work',
        description: 'Crews operating heavy road rollers to seal pothole array at Dhantoli Square.',
        latitude: 21.1380,
        longitude: 79.0720,
        ward: 'Ward 4 - Dhantoli',
        expectedCompletionDate: now.add(const Duration(days: 2)),
        upvotesCount: 38,
        flaggedStalledCount: 1,
        progressPhotoUrls: [
          'https://images.unsplash.com/photo-1584467735871-8e85353a8413',
        ],
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      ActiveWorkModel(
        id: 'work_2',
        issueId: 'doc_red_alert_1',
        departmentId: 'DEPT_WATER',
        departmentName: 'Nagpur Jal Seva & Drainage Dept',
        title: 'Stormwater Drain Unclogging Operation',
        description: 'Drainage suction pumps deployed to clear blocked main sewer pipes.',
        latitude: 21.1458,
        longitude: 79.0882,
        ward: 'Ward 2 - Dharampeth',
        expectedCompletionDate: now.add(const Duration(days: 1)),
        upvotesCount: 52,
        flaggedStalledCount: 0,
        progressPhotoUrls: [
          'https://images.unsplash.com/photo-1515162816999-a0c47dc192f7',
        ],
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
    ];
  }

  static List<WeatherCacheModel> getInitialWeatherCache() {
    final now = DateTime.now();

    return [
      WeatherCacheModel(
        wardId: 'Ward 2 - Dharampeth',
        condition: 'Heavy Rain Forecast',
        tempCelsius: 28.0,
        humidityPercentage: 88.0,
        rainfallMm: 52.0,
        heavyRainAlert: true,
        forecastSummary: 'Severe downpour expected over next 24 hours. Drainage SLA targets auto-escalated.',
        updatedAt: now,
      ),
      WeatherCacheModel(
        wardId: 'Ward 4 - Dhantoli',
        condition: 'Moderate Rain',
        tempCelsius: 29.5,
        humidityPercentage: 78.0,
        rainfallMm: 22.0,
        heavyRainAlert: false,
        forecastSummary: 'Intermittent light to moderate rain showers expected.',
        updatedAt: now,
      ),
    ];
  }
}
