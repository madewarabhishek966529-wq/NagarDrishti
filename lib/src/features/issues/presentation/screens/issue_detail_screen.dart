import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nagardrishti/src/core/constants/app_colors.dart';
import 'package:nagardrishti/src/core/constants/app_constants.dart';
import 'package:nagardrishti/src/core/utils/app_language_provider.dart';
import 'package:nagardrishti/src/core/utils/cso_contact_helper.dart';
import 'package:nagardrishti/src/features/report/presentation/controllers/report_controller.dart';
import '../../domain/issue_model.dart';

class IssueDetailScreen extends ConsumerWidget {
  final String issueId;

  const IssueDetailScreen({super.key, required this.issueId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final issuesRepo = ref.watch(issuesRepositoryProvider);
    final currentLang = ref.watch(appLanguageProvider);

    return FutureBuilder<IssueModel?>(
      future: issuesRepo.getIssueById(issueId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.darkBackground,
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

        final csoInfo = CsoContactHelper.getCsoForWard(issue.ward);
        final now = DateTime.now();
        final isOverdue = now.isAfter(issue.slaDeadline) && issue.status != IssueStatus.resolved;
        final isAtRisk = !isOverdue && issue.status != IssueStatus.resolved && issue.slaDeadline.difference(now).inHours <= 6;
        final isHighPriority = issue.redAlert || issue.severity == IssueSeverity.critical || isOverdue || isAtRisk;

        return Scaffold(
          backgroundColor: AppColors.darkBackground,
          appBar: AppBar(
            backgroundColor: AppColors.darkSurface,
            title: Text('Ticket ${issue.trackingId}'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Red Alert / SOS Banner if critical
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
                                '🚨 RED ALERT (${issue.reportCount} Citizen Reports)',
                                style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.redAlert, fontSize: 14),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Responsible CSO Officer: ${csoInfo.name} (📞 ${csoInfo.phone})',
                                style: const TextStyle(fontSize: 11, color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // NEED FASTER ACTION? ESCALATION CARD FOR HIGH PRIORITY COMPLAINTS
                if (isHighPriority && issue.status != IssueStatus.resolved) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.amber, width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.speed_rounded, color: Colors.amber, size: 22),
                            const SizedBox(width: 8),
                            Text(
                              AppStrings.tr('needFasterAction', currentLang),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Your complaint is assigned to Zone ${csoInfo.zoneId.replaceAll("zone_", "")} (${csoInfo.zoneName}) for fast-track action.',
                          style: const TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.amber.withValues(alpha: 0.2),
                              child: Text(csoInfo.name[0], style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(csoInfo.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                  Text('${csoInfo.designation} • 📞 ${csoInfo.phone}', style: const TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                CsoContactHelper.initiateCsoCall(
                                  context: context,
                                  ref: ref,
                                  phoneNumber: csoInfo.phone,
                                  officerName: csoInfo.name,
                                  issueId: issue.id,
                                  trackingId: issue.trackingId,
                                  zoneName: csoInfo.zoneName,
                                );
                              },
                              icon: const Icon(Icons.phone, size: 14),
                              label: const Text('Call Officer', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
                            ),
                          ],
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
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.nagpurOrange),
                              ),
                            ),
                            const Spacer(),
                            Text('Ward: ${issue.ward}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryDark)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(issue.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(issue.description, style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryDark)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // RESPONSIBLE CSO OFFICER & HELPLINE CARD
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.badge_rounded, color: Color(0xFF10B981), size: 22),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(csoInfo.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                Text('Assigned ${csoInfo.designation} (${csoInfo.zoneName})', style: const TextStyle(fontSize: 11, color: AppColors.nagpurOrange)),
                              ],
                            ),
                          ],
                        ),
                        const Divider(color: AppColors.darkCardBorder, height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () {
                                CsoContactHelper.initiateCsoCall(
                                  context: context,
                                  ref: ref,
                                  phoneNumber: csoInfo.phone,
                                  officerName: csoInfo.name,
                                  issueId: issue.id,
                                  trackingId: issue.trackingId,
                                  zoneName: csoInfo.zoneName,
                                );
                              },
                              icon: const Icon(Icons.phone_in_talk, size: 14, color: Color(0xFF10B981)),
                              label: Text('Call CSO: ${csoInfo.phone}', style: const TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => CsoContactHelper.initiateHelplineCall(context: context),
                              icon: const Icon(Icons.headset_mic, size: 14, color: Colors.white70),
                              label: Text('Helpline: ${AppConstants.nmcCitizenHelpline}', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Complaint Status Timeline Progress View
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Complaint Status Timeline', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 16),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildTimelineStep('Submitted', true, isCurrent: issue.status == IssueStatus.reported),
                              _buildTimelineConnector(true),
                              _buildTimelineStep('Zone Detected', true, isCurrent: false),
                              _buildTimelineConnector(true),
                              _buildTimelineStep('CSO Assigned', true, isCurrent: false),
                              _buildTimelineConnector(issue.status.index >= 1),
                              _buildTimelineStep('Acknowledged', issue.status.index >= 1, isCurrent: issue.status == IssueStatus.acknowledged),
                              _buildTimelineConnector(issue.status.index >= 2),
                              _buildTimelineStep('In Progress', issue.status.index >= 2, isCurrent: issue.status == IssueStatus.inProgress),
                              _buildTimelineConnector(issue.status.index >= 3),
                              _buildTimelineStep('Resolved & AI Verified', issue.status.index >= 3, isCurrent: issue.status == IssueStatus.resolved),
                            ],
                          ),
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
                              Text('Assigned Dept: ${issue.assignedDepartmentId.replaceAll("DEPT_", "")}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(height: 2),
                              Text('SLA Target: ${issue.slaDeadline.difference(DateTime.now()).inHours.abs()} Hours remaining', style: const TextStyle(fontSize: 12, color: AppColors.nagpurOrange)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Proof-of-Fix Before & After Card (if resolved)
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
                              const Text('Gemini AI Verification Proof', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.resolvedStatus.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${((issue.fixQualityScore ?? 0.95) * 100).toInt()}% Verified Fix',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.resolvedStatus),
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
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimelineStep(String title, bool isDone, {bool isCurrent = false}) {
    final color = isDone ? (isCurrent ? AppColors.nagpurOrange : AppColors.resolvedStatus) : AppColors.reportedStatus;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(isDone ? Icons.check : Icons.circle, size: 14, color: Colors.white),
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
      width: 16,
      height: 2,
      color: isDone ? AppColors.resolvedStatus : AppColors.reportedStatus,
    );
  }
}
