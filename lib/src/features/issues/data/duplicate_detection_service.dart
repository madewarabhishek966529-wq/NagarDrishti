import 'dart:math';
import '../domain/issue_model.dart';

class DuplicateMatchResult {
  final bool isDuplicate;
  final IssueModel? parentIssue;
  final double distanceMeters;

  const DuplicateMatchResult({
    required this.isDuplicate,
    this.parentIssue,
    this.distanceMeters = 0,
  });
}

abstract class DuplicateDetectionService {
  DuplicateMatchResult findNearbyDuplicate(
    IssueModel newIssue,
    List<IssueModel> existingIssues, {
    double radiusMeters = 100.0,
  });

  double calculateDistanceMeters(double lat1, double lon1, double lat2, double lon2);
}

class HaversineDuplicateDetectionService implements DuplicateDetectionService {
  @override
  DuplicateMatchResult findNearbyDuplicate(
    IssueModel newIssue,
    List<IssueModel> existingIssues, {
    double radiusMeters = 100.0,
  }) {
    for (final issue in existingIssues) {
      // Must be same category and not resolved
      if (issue.category == newIssue.category && issue.status != IssueStatus.resolved) {
        final dist = calculateDistanceMeters(
          newIssue.latitude,
          newIssue.longitude,
          issue.latitude,
          issue.longitude,
        );

        if (dist <= radiusMeters) {
          return DuplicateMatchResult(
            isDuplicate: true,
            parentIssue: issue.parentIssueId != null ? null : issue,
            distanceMeters: dist,
          );
        }
      }
    }

    return const DuplicateMatchResult(isDuplicate: false);
  }

  @override
  double calculateDistanceMeters(double lat1, double lon1, double lat2, double lon2) {
    const double r = 6371000; // Earth radius in meters
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return r * c;
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }
}
