import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nagardrishti/src/core/constants/app_colors.dart';
import '../controllers/admin_command_center_controller.dart';

class AuditLogsScreen extends ConsumerWidget {
  const AuditLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(cityAuditLogsProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Immutable Audit Trail Log', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('Tamper-proof administrative & zonal action log history', style: TextStyle(fontSize: 11, color: AppColors.textSecondaryDark)),
          ],
        ),
      ),
      body: logsAsync.when(
        data: (logs) {
          if (logs.isEmpty) {
            return const Center(child: Text('No audit log entries recorded.', style: TextStyle(color: Colors.white)));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: logs.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, idx) {
              final log = logs[idx];

              return Container(
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.darkCardBorder),
                ),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(log.action.replaceAll('_', ' '), style: const TextStyle(color: Color(0xFF2563EB), fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        Text('Ticket: ${log.trackingId}', style: const TextStyle(color: AppColors.nagpurOrange, fontWeight: FontWeight.bold, fontSize: 12)),
                        const Spacer(),
                        Text(DateFormat('hh:mm a, dd MMM').format(log.timestamp), style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 10)),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Text('User: ${log.userName} (${log.role})', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text('Old State: ${log.oldValue}', style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 11)),
                    Text('New State: ${log.newValue}', style: const TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.w600)),
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
