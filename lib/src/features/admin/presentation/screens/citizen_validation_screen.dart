import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nagardrishti/src/core/constants/app_colors.dart';
import '../controllers/admin_command_center_controller.dart';

class CitizenValidationScreen extends ConsumerWidget {
  const CitizenValidationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final validationAsync = ref.watch(citizenValidationQueueProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Citizen Validation & Rejection Queue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('No silent closure — Citizen rejections trigger reopen & CSO alerts', style: TextStyle(fontSize: 11, color: AppColors.textSecondaryDark)),
          ],
        ),
      ),
      body: validationAsync.when(
        data: (issues) {
          if (issues.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.thumb_up_alt_rounded, color: Color(0xFF10B981), size: 64),
                  SizedBox(height: 12),
                  Text('All Resolved Repairs Accepted by Citizens!', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: issues.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, idx) {
              final issue = issues[idx];
              final isReopened = issue.reopenCount > 0;

              return Container(
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isReopened ? AppColors.redAlert : Colors.amber),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: (isReopened ? AppColors.redAlert : Colors.amber).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: isReopened ? AppColors.redAlert : Colors.amber),
                          ),
                          child: Text(
                            isReopened ? 'REOPENED (CITIZEN REJECTED)' : 'AWAITING CITIZEN VALIDATION',
                            style: TextStyle(color: isReopened ? AppColors.redAlert : Colors.amber, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Spacer(),
                        Text(issue.trackingId, style: const TextStyle(color: AppColors.nagpurOrange, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Text(issue.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text('Category: ${issue.category} • Ward: ${issue.ward}', style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 11)),
                    if (issue.citizenFeedback != null && issue.citizenFeedback!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.darkCard,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('💬 Feedback: "${issue.citizenFeedback}"', style: const TextStyle(color: Colors.white70, fontSize: 12, fontStyle: FontStyle.italic)),
                      ),
                    ],
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
                              actionType: 'REOPEN_CITIZEN_REJECT',
                              details: 'Re-opened by Admin Command Center due to citizen rejection',
                            );
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ticket ${issue.trackingId} re-opened and CSO notified')));
                          },
                          icon: const Icon(Icons.refresh, size: 14),
                          label: const Text('Re-open & Escalated CSO', style: TextStyle(fontSize: 11)),
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
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.nagpurOrange)),
        error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: AppColors.redAlert))),
      ),
    );
  }
}
