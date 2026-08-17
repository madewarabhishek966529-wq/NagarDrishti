import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nagardrishti/src/core/constants/app_colors.dart';
import 'package:nagardrishti/src/features/cso/presentation/controllers/cso_controller.dart';
import 'package:nagardrishti/src/features/issues/domain/issue_model.dart';
import 'package:nagardrishti/src/features/report/presentation/controllers/report_controller.dart';
import '../controllers/admin_command_center_controller.dart';

class AdminMajorProblemsScreen extends ConsumerWidget {
  const AdminMajorProblemsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final issuesRepo = ref.watch(issuesRepositoryProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('NMC Major Problems Command Center', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('Algorithmic urgency ranking based on report density & hazard score', style: TextStyle(fontSize: 11, color: AppColors.textSecondaryDark)),
          ],
        ),
      ),
      body: FutureBuilder<List<IssueModel>>(
        future: issuesRepo.fetchIssues(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.nagpurOrange));
          }

          final issues = snapshot.data ?? [];
          final ranked = <RankedMajorProblem>[];
          final now = DateTime.now();

          for (final issue in issues) {
            if (issue.status == IssueStatus.resolved) continue;

            double score = 0;
            String reason = 'City Civic Priority';

            if (issue.redAlert) {
              score += 120;
              reason = '🔥 RED ALERT: High Duplicate Density (${issue.reportCount} Reports)';
            } else if (issue.severity == IssueSeverity.critical) {
              score += 90;
              reason = '⚡ Critical Hazard Safety Risk';
            }

            score += (issue.reportCount * 12);

            if (now.isAfter(issue.slaDeadline)) {
              score += 75;
              reason = '⚠️ SLA BREACHED: Overdue Resolution';
            } else if (issue.slaDeadline.difference(now).inHours <= 6) {
              score += 45;
              if (!issue.redAlert) reason = '⏱️ SLA AT RISK: Deadline in ${issue.slaDeadline.difference(now).inHours}h';
            }

            if (issue.reopenCount > 0) {
              score += (issue.reopenCount * 40);
              reason = '🔁 Citizen Re-opened Defect (Count: ${issue.reopenCount})';
            }

            ranked.add(RankedMajorProblem(
              issue: issue,
              urgencyScore: score,
              primaryReason: reason,
            ));
          }

          ranked.sort((a, b) => b.urgencyScore.compareTo(a.urgencyScore));

          if (ranked.isEmpty) {
            return const Center(
              child: Text('No Major Critical Problems Pending City-wide!', style: TextStyle(color: Colors.white, fontSize: 16)),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: ranked.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, idx) {
              final r = ranked[idx];
              final issue = r.issue;
              final rankNum = idx + 1;

              return Container(
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: issue.redAlert ? AppColors.redAlert : (rankNum <= 3 ? AppColors.nagpurOrange : AppColors.darkCardBorder),
                    width: issue.redAlert ? 2 : 1,
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: rankNum == 1 ? AppColors.redAlert : (rankNum <= 3 ? AppColors.nagpurOrange : AppColors.darkCard),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text('#$rankNum', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(issue.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                              Text('${issue.category} • ${issue.ward}', style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 11)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber),
                          ),
                          child: Text('Score: ${r.urgencyScore.toInt()}', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 11)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.darkBackground,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.darkCardBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, color: AppColors.nagpurOrange, size: 16),
                          const SizedBox(width: 8),
                          Expanded(child: Text(r.primaryReason, style: const TextStyle(color: Colors.white70, fontSize: 12))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('👥 ${issue.reportCount} citizen reports', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                        Text('🏢 Dept: ${issue.assignedDepartmentId.replaceAll("DEPT_", "")}', style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 11)),
                      ],
                    ),
                    const Divider(color: AppColors.darkCardBorder, height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => context.push('/issue/${issue.id}'),
                          child: const Text('View Ticket', style: TextStyle(fontSize: 11)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            ref.read(adminActionControllerProvider.notifier).executeAdminAction(
                              issueId: issue.id,
                              actionType: 'ESCALATE_EMERGENCY',
                              details: 'Escalated from Major Problems Command Hub',
                            );
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Escalation issued for ${issue.trackingId}')));
                          },
                          icon: const Icon(Icons.campaign, size: 14),
                          label: const Text('Direct City Escalation', style: TextStyle(fontSize: 11)),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.redAlert, foregroundColor: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
