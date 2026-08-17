import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nagardrishti/src/core/constants/app_colors.dart';
import 'package:nagardrishti/src/core/constants/app_constants.dart';
import '../controllers/admin_command_center_controller.dart';

class SlaCommandCenterScreen extends ConsumerWidget {
  const SlaCommandCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deptAsync = ref.watch(departmentPerformanceProvider);
    final kpiAsync = ref.watch(cityKpiOverviewProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('NMC SLA Command Center', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('SLA status monitoring & department compliance audit', style: TextStyle(fontSize: 11, color: AppColors.textSecondaryDark)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Breakdown Grid
            const Text('City SLA Health Parameters', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            kpiAsync.when(
              data: (kpi) {
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 2.1,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: [
                    _buildSlaHealthCard('SAFE', '${kpi.totalComplaints - kpi.atRiskComplaints - kpi.overdueComplaints - kpi.criticalComplaints}', 'Within standard target', const Color(0xFF10B981)),
                    _buildSlaHealthCard('AT RISK', '${kpi.atRiskComplaints}', '< 6 Hours remaining', Colors.amber),
                    _buildSlaHealthCard('OVERDUE', '${kpi.overdueComplaints}', 'Deadline breached', AppColors.redAlert),
                    _buildSlaHealthCard('CRITICAL', '${kpi.criticalComplaints}', 'Severe hazard risk', Colors.redAccent),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.nagpurOrange)),
              error: (err, _) => Text('Error: $err', style: const TextStyle(color: AppColors.redAlert)),
            ),

            const SizedBox(height: 24),

            // Department SLA Performance Table
            const Text('Department SLA Breakdown & Targets', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            deptAsync.when(
              data: (depts) {
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: depts.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, idx) {
                    final d = depts[idx];
                    final targetHours = AppConstants.categorySlaHours[d.departmentName] ?? 48;

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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(d.departmentName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                              Text('Target: ${targetHours}h SLA', style: const TextStyle(color: AppColors.nagpurOrange, fontWeight: FontWeight.bold, fontSize: 11)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildDeptStat('Assigned', '${d.assignedComplaints}', Colors.white),
                              _buildDeptStat('In Progress', '${d.inProgressComplaints}', Colors.purpleAccent),
                              _buildDeptStat('Overdue', '${d.overdueComplaints}', AppColors.redAlert),
                              _buildDeptStat('SLA %', '${d.slaCompliancePercentage.toStringAsFixed(1)}%', const Color(0xFF10B981)),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.nagpurOrange)),
              error: (err, _) => Text('Error: $err', style: const TextStyle(color: AppColors.redAlert)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlaHealthCard(String title, String val, String subtitle, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(width: 4, height: 40, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(val, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
              Text(subtitle, style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 9)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeptStat(String label, String val, Color col) {
    return Column(
      children: [
        Text(val, style: TextStyle(color: col, fontWeight: FontWeight.bold, fontSize: 13)),
        Text(label, style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 10)),
      ],
    );
  }
}
