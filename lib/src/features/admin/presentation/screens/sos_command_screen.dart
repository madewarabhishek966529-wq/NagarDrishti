import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nagardrishti/src/core/constants/app_colors.dart';
import 'package:nagardrishti/src/core/constants/app_constants.dart';
import '../controllers/admin_command_center_controller.dart';

class SosCommandScreen extends ConsumerWidget {
  const SosCommandScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sosQueueAsync = ref.watch(sosEmergencyQueueProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🚨 SOS 4-Hour Emergency Hub', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('Strict 4-Hour Response SLA for Life & Safety Hazards', style: TextStyle(fontSize: 11, color: AppColors.textSecondaryDark)),
          ],
        ),
      ),
      body: sosQueueAsync.when(
        data: (issues) {
          if (issues.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified_user_rounded, color: Color(0xFF10B981), size: 64),
                  SizedBox(height: 12),
                  Text('No SOS Emergency Incidents Currently Open!', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
              final zoneId = AppConstants.wardToZoneIdMap[issue.ward] ?? 'zone_04';
              final zoneName = AppConstants.zoneIdToNameMap[zoneId] ?? 'Dhantoli';

              final hoursLeft = issue.slaDeadline.difference(DateTime.now()).inHours;
              final minsLeft = issue.slaDeadline.difference(DateTime.now()).inMinutes % 60;
              final isOverdue = DateTime.now().isAfter(issue.slaDeadline);

              return Container(
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.redAccent, width: 2),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: Colors.white, size: 14),
                              SizedBox(width: 4),
                              Text('🚨 SOS EMERGENCY', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isOverdue ? AppColors.redAlert.withValues(alpha: 0.2) : Colors.amber.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isOverdue ? AppColors.redAlert : Colors.amber),
                          ),
                          child: Text(
                            isOverdue ? '⚠️ SLA BREACHED' : '⏱️ ${hoursLeft}h ${minsLeft}m remaining',
                            style: TextStyle(color: isOverdue ? AppColors.redAlert : Colors.amber, fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Text(issue.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('Category: ${issue.category} • Zone: $zoneName (${issue.ward})', style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
                    Text('📍 Location: ${issue.address}', style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 11)),
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
                              actionType: 'DISPATCH_EMERGENCY_TEAM',
                              details: 'Emergency Field Taskforce Dispatched by Command Center',
                            );
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Emergency Taskforce dispatched for ${issue.trackingId}')));
                          },
                          icon: const Icon(Icons.flash_on, size: 14),
                          label: const Text('Dispatch Taskforce', style: TextStyle(fontSize: 11)),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
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
