import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nagardrishti/src/features/report/presentation/controllers/report_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/issue_model.dart';

class IssueDetailScreen extends ConsumerWidget {
  final String issueId;

  const IssueDetailScreen({super.key, required this.issueId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final issuesRepo = ref.watch(issuesRepositoryProvider);

    return FutureBuilder<IssueModel?>(
      future: issuesRepo.getIssueById(issueId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: AppColors.nagpurOrange)),
          );
        }

        final issue = snapshot.data ??
            IssueModel(
              id: issueId,
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
              createdBy: 'user_101',
              assignedDepartmentId: 'DEPT_WATER',
              createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
              updatedAt: DateTime.now().subtract(const Duration(minutes: 5)),
              slaDeadline: DateTime.now().add(const Duration(hours: 48)),
            );

        return Scaffold(
          appBar: AppBar(
            title: Text('Ticket ${issue.trackingId}'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Red Alert Escalation Banner if critical
                if (issue.redAlert) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.redAlert.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.redAlert, width: 2),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.redAlert,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.flash_on, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '🚨 CRITICAL RED ALERT (${issue.reportCount} Reports)',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.redAlert,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Auto-escalated to Department Officers via FCM Push Alert.',
                                style: TextStyle(fontSize: 11, color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Issue Title & Description Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Chip(
                              backgroundColor: AppColors.nagpurOrange.withValues(alpha: 0.2),
                              side: BorderSide.none,
                              label: Text(
                                issue.category,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.nagpurOrange,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Ward: ${issue.ward}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          issue.title,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          issue.description,
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryDark),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Status Timeline Progress View
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Complaint Status Timeline',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildTimelineStep('Reported', true, isCurrent: issue.status == IssueStatus.reported),
                            _buildTimelineConnector(issue.status != IssueStatus.reported),
                            _buildTimelineStep('Acknowledged', issue.status.index >= 1, isCurrent: issue.status == IssueStatus.acknowledged),
                            _buildTimelineConnector(issue.status.index >= 2),
                            _buildTimelineStep('In Progress', issue.status.index >= 2, isCurrent: issue.status == IssueStatus.inProgress),
                            _buildTimelineConnector(issue.status.index >= 3),
                            _buildTimelineStep('Resolved', issue.status.index >= 3, isCurrent: issue.status == IssueStatus.resolved),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Assigned Department & SLA Countdown
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.nagpurOrange.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.timer_outlined, color: AppColors.nagpurOrange),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Assigned: ${issue.assignedDepartmentId}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'SLA Target: ${issue.slaDeadline.difference(DateTime.now()).inHours} Hours remaining',
                                style: const TextStyle(fontSize: 12, color: AppColors.nagpurOrange),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimelineStep(String title, bool isDone, {bool isCurrent = false}) {
    final color = isDone
        ? (isCurrent ? AppColors.nagpurOrange : AppColors.resolvedStatus)
        : AppColors.reportedStatus;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDone ? Icons.check : Icons.circle,
              size: 14,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              color: isDone ? Colors.white : AppColors.textSecondaryDark,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineConnector(bool isDone) {
    return Container(
      width: 20,
      height: 2,
      color: isDone ? AppColors.resolvedStatus : AppColors.reportedStatus,
    );
  }
}
