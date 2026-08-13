import 'package:flutter_test/flutter_test.dart';
import 'package:nagardrishti/src/features/issues/data/duplicate_detection_service.dart';
import 'package:nagardrishti/src/features/issues/domain/issue_model.dart';

void main() {
  group('HaversineDuplicateDetectionService tests', () {
    final service = HaversineDuplicateDetectionService();

    test('Calculates distance between coordinates accurately', () {
      // Dharampeth to Dhantoli (approx 1.5 km)
      final dist = service.calculateDistanceMeters(21.1458, 79.0882, 21.1380, 79.0720);
      expect(dist, greaterThan(1000));
      expect(dist, lessThan(3000));
    });

    test('Identifies duplicate issue within 100m radius with matching category', () {
      final existingIssue = IssueModel(
        id: 'parent_1',
        trackingId: 'NAG-1001',
        title: 'Road Damage',
        description: 'Pothole on street',
        category: 'Pothole & Roads',
        severity: IssueSeverity.medium,
        confidenceScore: 0.9,
        imageUrl: '',
        latitude: 21.1458,
        longitude: 79.0882,
        address: 'Dharampeth, Nagpur',
        ward: 'Ward 2 - Dharampeth',
        status: IssueStatus.reported,
        reportCount: 1,
        createdBy: 'user_1',
        assignedDepartmentId: 'DEPT_ROADS',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        slaDeadline: DateTime.now().add(const Duration(hours: 48)),
      );

      // New issue 30 meters away, same category
      final newIssue = IssueModel(
        id: 'new_1',
        trackingId: 'NAG-1002',
        title: 'Road Hole',
        description: 'Another report of same pothole',
        category: 'Pothole & Roads',
        severity: IssueSeverity.medium,
        confidenceScore: 0.88,
        imageUrl: '',
        latitude: 21.1460, // ~22 meters difference
        longitude: 79.0883,
        address: 'Dharampeth Main St',
        ward: 'Ward 2 - Dharampeth',
        status: IssueStatus.reported,
        reportCount: 1,
        createdBy: 'user_2',
        assignedDepartmentId: 'DEPT_ROADS',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        slaDeadline: DateTime.now().add(const Duration(hours: 48)),
      );

      final match = service.findNearbyDuplicate(newIssue, [existingIssue]);
      expect(match.isDuplicate, isTrue);
      expect(match.parentIssue?.id, 'parent_1');
      expect(match.distanceMeters, lessThan(100));
    });
  });
}
