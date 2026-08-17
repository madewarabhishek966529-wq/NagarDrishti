import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nagardrishti/src/core/constants/app_colors.dart';
import '../controllers/admin_command_center_controller.dart';
import '../../domain/admin_command_center_models.dart';

class TenZonePerformanceScreen extends ConsumerStatefulWidget {
  const TenZonePerformanceScreen({super.key});

  @override
  ConsumerState<TenZonePerformanceScreen> createState() => _TenZonePerformanceScreenState();
}

class _TenZonePerformanceScreenState extends ConsumerState<TenZonePerformanceScreen> {
  String _sortBy = 'WORST_SLA';

  @override
  Widget build(BuildContext context) {
    final zonesAsync = ref.watch(tenZonePerformanceProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('10 NMC Zone Performance Grid', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('City-wide zonal health, SLA compliance & CSO oversight', style: TextStyle(fontSize: 11, color: AppColors.textSecondaryDark)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Sorting Dropdown Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.darkSurface,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Sort Zones By:', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.darkCard,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.darkCardBorder),
                  ),
                  child: DropdownButton<String>(
                    value: _sortBy,
                    dropdownColor: AppColors.darkSurface,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'WORST_SLA', child: Text('Lowest SLA %', style: TextStyle(color: Colors.white, fontSize: 12))),
                      DropdownMenuItem(value: 'MOST_COMPLAINTS', child: Text('Most Complaints', style: TextStyle(color: Colors.white, fontSize: 12))),
                      DropdownMenuItem(value: 'MOST_CRITICAL', child: Text('Most Critical Hazards', style: TextStyle(color: Colors.white, fontSize: 12))),
                      DropdownMenuItem(value: 'MOST_OVERDUE', child: Text('Most Overdue', style: TextStyle(color: Colors.white, fontSize: 12))),
                      DropdownMenuItem(value: 'SLOWEST_RES', child: Text('Slowest Resolution', style: TextStyle(color: Colors.white, fontSize: 12))),
                      DropdownMenuItem(value: 'HIGHEST_REJECTION', child: Text('Highest Citizen Rejection', style: TextStyle(color: Colors.white, fontSize: 12))),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _sortBy = val);
                    },
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: zonesAsync.when(
              data: (zones) {
                final sortedZones = List<ZonePerformanceDetail>.from(zones);
                if (_sortBy == 'WORST_SLA') sortedZones.sort((a, b) => a.slaCompliancePercentage.compareTo(b.slaCompliancePercentage));
                if (_sortBy == 'MOST_COMPLAINTS') sortedZones.sort((a, b) => b.complaintCount.compareTo(a.complaintCount));
                if (_sortBy == 'MOST_CRITICAL') sortedZones.sort((a, b) => b.criticalCount.compareTo(a.criticalCount));
                if (_sortBy == 'MOST_OVERDUE') sortedZones.sort((a, b) => b.overdueCount.compareTo(a.overdueCount));
                if (_sortBy == 'SLOWEST_RES') sortedZones.sort((a, b) => b.averageResolutionTimeHours.compareTo(a.averageResolutionTimeHours));
                if (_sortBy == 'HIGHEST_REJECTION') sortedZones.sort((a, b) => b.citizenRejectionRate.compareTo(a.citizenRejectionRate));

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: sortedZones.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, idx) {
                    final zone = sortedZones[idx];
                    final healthColor = Color(zone.zoneHealth.colorHex);

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
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: healthColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: healthColor),
                                ),
                                child: Text('GRADE ${zone.zoneHealth.label}', style: TextStyle(color: healthColor, fontWeight: FontWeight.bold, fontSize: 11)),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('NMC Zone ${zone.zoneId.replaceAll("zone_", "")} — ${zone.zoneName}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                                    Text('CSO: ${zone.assignedCsoName} (${zone.assignedCsoPhone})', style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 11)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('${zone.slaCompliancePercentage.toStringAsFixed(1)}%', style: TextStyle(color: healthColor, fontWeight: FontWeight.bold, fontSize: 16)),
                                  const Text('SLA Compliance', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 9)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Metrics Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildMetricItem('Total', '${zone.complaintCount}', Colors.white),
                              _buildMetricItem('Critical', '${zone.criticalCount}', Colors.redAccent),
                              _buildMetricItem('Red Alerts', '${zone.redAlertCount}', AppColors.redAlert),
                              _buildMetricItem('Overdue', '${zone.overdueCount}', Colors.orangeAccent),
                              _buildMetricItem('Avg Res', '${zone.averageResolutionTimeHours.toStringAsFixed(1)}h', const Color(0xFF38BDF8)),
                              _buildMetricItem('Rejection', '${zone.citizenRejectionRate.toStringAsFixed(1)}%', Colors.amber),
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
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String val, Color col) {
    return Column(
      children: [
        Text(val, style: TextStyle(color: col, fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 10)),
      ],
    );
  }
}
