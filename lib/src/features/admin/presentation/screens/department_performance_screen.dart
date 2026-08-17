import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nagardrishti/src/core/constants/app_colors.dart';
import '../controllers/admin_command_center_controller.dart';

class DepartmentPerformanceScreen extends ConsumerWidget {
  const DepartmentPerformanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deptAsync = ref.watch(departmentPerformanceProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('NMC Department Performance Overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('Configured department bottlenecks, resolution & squad metrics', style: TextStyle(fontSize: 11, color: AppColors.textSecondaryDark)),
          ],
        ),
      ),
      body: deptAsync.when(
        data: (depts) {
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: depts.length,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (context, idx) {
              final d = depts[idx];

              return Container(
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.darkCardBorder),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.business_rounded, color: Color(0xFF2563EB), size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(d.departmentName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              Text('ID: ${d.departmentId}', style: const TextStyle(color: AppColors.nagpurOrange, fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${d.slaCompliancePercentage.toStringAsFixed(1)}%', style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 18)),
                            const Text('SLA Target Rate', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 10)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 4,
                      childAspectRatio: 1.4,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      children: [
                        _buildGridCard('Assigned', '${d.assignedComplaints}', Colors.white),
                        _buildGridCard('In Progress', '${d.inProgressComplaints}', Colors.purpleAccent),
                        _buildGridCard('Resolved', '${d.resolvedComplaints}', const Color(0xFF10B981)),
                        _buildGridCard('Overdue', '${d.overdueComplaints}', AppColors.redAlert),
                        _buildGridCard('Avg Time', '${d.averageResolutionTimeHours.toStringAsFixed(1)}h', const Color(0xFF38BDF8)),
                        _buildGridCard('Rejections', '${d.citizenRejectionCount}', Colors.amber),
                        _buildGridCard('Reopened', '${d.reopenedCount}', Colors.deepOrange),
                        _buildGridCard('Squads', '4 Active', Colors.cyan),
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

  Widget _buildGridCard(String label, String val, Color col) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.darkCardBorder),
      ),
      padding: const EdgeInsets.all(6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(val, style: TextStyle(color: col, fontWeight: FontWeight.bold, fontSize: 13)),
          Text(label, style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 9), textAlign: TextAlign.center, maxLines: 1),
        ],
      ),
    );
  }
}
