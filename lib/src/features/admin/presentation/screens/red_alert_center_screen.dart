import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nagardrishti/src/core/constants/app_colors.dart';
import 'package:nagardrishti/src/core/constants/app_constants.dart';
import '../controllers/admin_command_center_controller.dart';

class RedAlertCenterScreen extends ConsumerWidget {
  const RedAlertCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final redAlertsAsync = ref.watch(redAlertMasterQueueProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('NMC Red Alert Command Center', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('10+ Duplicate Citizen Reports within 50m radius', style: TextStyle(fontSize: 11, color: AppColors.textSecondaryDark)),
          ],
        ),
      ),
      body: redAlertsAsync.when(
        data: (issues) {
          if (issues.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shield_rounded, color: Color(0xFF10B981), size: 64),
                  SizedBox(height: 12),
                  Text('No Active Red Alerts in NMC City Jurisdiction!', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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

              return Container(
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.redAlert, width: 2),
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
                            color: AppColors.redAlert,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('RED ALERT (${issue.reportCount} CITIZEN REPORTS)', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        const Spacer(),
                        Text('Zone: $zoneName', style: const TextStyle(color: AppColors.nagpurOrange, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Text(issue.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('Category: ${issue.category} • Ward: ${issue.ward}', style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
                    Text('📍 Location: ${issue.address}', style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 11)),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('🏢 Dept: ${issue.assignedDepartmentId.replaceAll("DEPT_", "")}', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                        Text('Severity: ${issue.severity.name.toUpperCase()}', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 11)),
                      ],
                    ),

                    const Divider(color: AppColors.darkCardBorder, height: 20),

                    // Actions
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.end,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => context.push('/issue/${issue.id}'),
                          icon: const Icon(Icons.visibility, size: 14),
                          label: const Text('View Master', style: TextStyle(fontSize: 11)),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            ref.read(adminActionControllerProvider.notifier).executeAdminAction(
                              issueId: issue.id,
                              actionType: 'NOTIFY_CSO_RED_ALERT',
                              details: 'Red Alert Dispatch Sent to Zone $zoneName CSO',
                            );
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('CSO Officer for Zone $zoneName notified')));
                          },
                          icon: const Icon(Icons.notifications_active, size: 14),
                          label: const Text('Notify CSO', style: TextStyle(fontSize: 11)),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            ref.read(adminActionControllerProvider.notifier).executeAdminAction(
                              issueId: issue.id,
                              actionType: 'ESCALATE_COMMISSIONER',
                              details: 'Direct Commissioner High Alert Escalation',
                            );
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('High Alert Escalation sent for ${issue.trackingId}')));
                          },
                          icon: const Icon(Icons.warning, size: 14),
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
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.nagpurOrange)),
        error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: AppColors.redAlert))),
      ),
    );
  }
}
