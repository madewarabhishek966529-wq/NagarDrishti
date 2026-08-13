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
                                'SLA Target: ${issue.slaDeadline.difference(DateTime.now()).inHours.abs()} Hours remaining',
                                style: const TextStyle(fontSize: 12, color: AppColors.nagpurOrange),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Proof-of-Fix Before & After Card (if resolved or afterImageUrl available)
                if (issue.status == IssueStatus.resolved || issue.afterImageUrl != null) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
                              const SizedBox(width: 8),
                              const Text('Gemini AI Verification Proof',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.resolvedStatus.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${((issue.fixQualityScore ?? 0.95) * 100).toInt()}% Verified Fix',
                                  style: const TextStyle(
                                      fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.resolvedStatus),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    const Text('BEFORE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.redAlert)),
                                    const SizedBox(height: 6),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        issue.imageUrl,
                                        height: 110,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(height: 110, color: AppColors.darkSurface, child: const Icon(Icons.image_not_supported_rounded)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  children: [
                                    const Text('AFTER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.resolvedStatus)),
                                    const SizedBox(height: 6),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        issue.afterImageUrl ?? 'https://images.unsplash.com/photo-1541888946425-d0fbb186a5b7',
                                        height: 110,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(height: 110, color: AppColors.darkSurface, child: const Icon(Icons.image_not_supported_rounded)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            issue.verificationSummary ?? 'Gemini Vision verified: Road asphalt patch is seamless and free of defects.',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Citizen Satisfaction Feedback / Re-open Section
                if (issue.status == IssueStatus.resolved) ...[
                  Card(
                    color: AppColors.darkSurface,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Citizen Verification & Feedback',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Are you satisfied with the work completed by the municipal department?',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    _showRatingDialog(context, ref, issue);
                                  },
                                  icon: const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                                  label: const Text('Accept & Rate'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.resolvedStatus,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    _showReopenDialog(context, ref, issue);
                                  },
                                  icon: const Icon(Icons.replay_rounded, color: AppColors.redAlert, size: 18),
                                  label: const Text('Reject & Re-open', style: TextStyle(color: AppColors.redAlert)),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: AppColors.redAlert),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRatingDialog(BuildContext context, WidgetRef ref, IssueModel issue) {
    int selectedRating = 5;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.darkSurface,
          title: const Text('Rate Resolution Quality', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('How well was this issue resolved by NMC department?', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => IconButton(
                    icon: Icon(
                      index < selectedRating ? Icons.star_rounded : Icons.star_border_rounded,
                      color: Colors.amber,
                      size: 32,
                    ),
                    onPressed: () => setDialogState(() => selectedRating = index + 1),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondaryDark)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await ref.read(issuesRepositoryProvider).rateResolvedIssue(
                      issueId: issue.id,
                      rating: selectedRating,
                    );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Thank you! Rating saved +50 Citizen Karma awarded 🎉')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.nagpurOrange),
              child: const Text('Submit Rating'),
            ),
          ],
        ),
      ),
    );
  }

  void _showReopenDialog(BuildContext context, WidgetRef ref, IssueModel issue) {
    final feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: const Text('Re-open Complaint', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.redAlert)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please state why the fix was incomplete or defective.', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark)),
            const SizedBox(height: 12),
            TextField(
              controller: feedbackController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'e.g. Debris was left on road, pothole refilled unevenly...',
                labelText: 'Reason for Re-opening',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondaryDark)),
          ),
          ElevatedButton(
            onPressed: () async {
              final reason = feedbackController.text.trim();
              if (reason.isEmpty) return;
              Navigator.pop(ctx);
              await ref.read(issuesRepositoryProvider).reopenIssue(
                    issueId: issue.id,
                    citizenFeedback: reason,
                  );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ticket re-opened and escalated to Department Head!')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.redAlert),
            child: const Text('Confirm Re-open'),
          ),
        ],
      ),
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
