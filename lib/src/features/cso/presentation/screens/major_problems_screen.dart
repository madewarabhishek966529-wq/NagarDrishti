import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nagardrishti/src/core/constants/app_colors.dart';
import 'package:nagardrishti/src/features/auth/presentation/controllers/auth_controller.dart';
import '../controllers/cso_controller.dart';
import '../widgets/cso_action_dialog.dart';

class MajorProblemsScreen extends ConsumerWidget {
  const MajorProblemsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final zoneId = user?.zoneId ?? 'zone_04';
    final zoneName = user?.zoneName ?? 'Dhantoli';

    final majorAsync = ref.watch(majorProblemsProvider(zoneId));

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Major Problems Priority Rank', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('Zone 04 — $zoneName', style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark)),
          ],
        ),
      ),
      body: majorAsync.when(
        data: (rankedList) {
          if (rankedList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.verified, color: Color(0xFF10B981), size: 64),
                  const SizedBox(height: 16),
                  const Text('No Major Critical Problems in Zone 04!', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('All zone complaints are within normal SLA parameters.', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: rankedList.length,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (context, idx) {
              final ranked = rankedList[idx];
              final issue = ranked.issue;
              final rankNumber = idx + 1;

              final hoursLeft = issue.slaDeadline.difference(DateTime.now()).inHours;
              final isOverdue = hoursLeft < 0;

              return Container(
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: issue.redAlert ? AppColors.redAlert : (isOverdue ? Colors.orangeAccent : AppColors.darkCardBorder),
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
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: rankNumber == 1 ? AppColors.redAlert : AppColors.darkCard,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '#$rankNumber',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (issue.redAlert) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.redAlert,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text('RED ALERT', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                                    ),
                                    const SizedBox(width: 6),
                                  ],
                                  Text(
                                    issue.category,
                                    style: const TextStyle(color: AppColors.nagpurOrange, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                issue.title,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
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
                          child: Text(
                            'Score: ${ranked.urgencyScore.toInt()}',
                            style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Primary Reason Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.darkBackground,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.darkCardBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: AppColors.nagpurOrange, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              ranked.primaryReason,
                              style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('📍 Location: ${issue.address}', style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 11)),
                        Text('👥 ${issue.reportCount} citizen reports', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isOverdue
                          ? '⚠️ SLA BREACHED by ${hoursLeft.abs()} hours'
                          : '⏱️ SLA Deadline: ${hoursLeft}h remaining',
                      style: TextStyle(
                        color: isOverdue ? AppColors.redAlert : Colors.amber,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),

                    const Divider(color: AppColors.darkCardBorder, height: 20),

                    // Quick Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => context.push('/issue/${issue.id}'),
                          icon: const Icon(Icons.visibility, size: 14),
                          label: const Text('View', style: TextStyle(fontSize: 11)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => CsoActionDialog(issue: issue, zoneId: zoneId, initialAction: 'ASSIGN_SQUAD'),
                            );
                          },
                          icon: const Icon(Icons.person_add, size: 14),
                          label: const Text('Assign Squad', style: TextStyle(fontSize: 11)),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => CsoActionDialog(issue: issue, zoneId: zoneId, initialAction: 'ESCALATE'),
                            );
                          },
                          icon: const Icon(Icons.campaign, size: 14),
                          label: const Text('Escalate', style: TextStyle(fontSize: 11)),
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: AppColors.redAlert))),
      ),
    );
  }
}
