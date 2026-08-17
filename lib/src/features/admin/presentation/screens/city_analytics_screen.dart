import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nagardrishti/src/core/constants/app_colors.dart';
import '../controllers/admin_command_center_controller.dart';

class CityAnalyticsScreen extends ConsumerStatefulWidget {
  const CityAnalyticsScreen({super.key});

  @override
  ConsumerState<CityAnalyticsScreen> createState() => _CityAnalyticsScreenState();
}

class _CityAnalyticsScreenState extends ConsumerState<CityAnalyticsScreen> {
  String _timeRange = 'MONTHLY';

  @override
  Widget build(BuildContext context) {
    final kpiAsync = ref.watch(cityKpiOverviewProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('NMC City-Wide Analytics & Trends', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('Civic complaint velocity, SLA trends & satisfaction index', style: TextStyle(fontSize: 11, color: AppColors.textSecondaryDark)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time Filter Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Analytics Range:', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'DAILY', label: Text('Daily', style: TextStyle(fontSize: 11))),
                    ButtonSegment(value: 'WEEKLY', label: Text('Weekly', style: TextStyle(fontSize: 11))),
                    ButtonSegment(value: 'MONTHLY', label: Text('Monthly', style: TextStyle(fontSize: 11))),
                  ],
                  selected: {_timeRange},
                  onSelectionChanged: (set) => setState(() => _timeRange = set.first),
                ),
              ],
            ),
            const SizedBox(height: 16),

            kpiAsync.when(
              data: (kpi) {
                return Column(
                  children: [
                    _buildAnalyticsCard('Civic Complaint Growth Velocity', 'Total Filed: ${kpi.totalComplaints} (+14.2% vs previous period)', Icons.trending_up, const Color(0xFF38BDF8)),
                    const SizedBox(height: 10),
                    _buildAnalyticsCard('City SLA Target Compliance', '${kpi.overallSlaCompliancePercentage.toStringAsFixed(1)}% Compliance Rate', Icons.verified, const Color(0xFF10B981)),
                    const SizedBox(height: 10),
                    _buildAnalyticsCard('Red Alert Surge Density', '${kpi.redAlertCount} Active Clusters (50m radius threshold)', Icons.warning_rounded, AppColors.redAlert),
                    const SizedBox(height: 10),
                    _buildAnalyticsCard('SOS Emergency Incidents', '${kpi.sosCount} 4-Hour SLA Tickets', Icons.local_fire_department, Colors.orangeAccent),
                    const SizedBox(height: 10),
                    _buildAnalyticsCard('Citizen Satisfaction Score', '4.7 / 5.0 Rating (Based on verified proof-of-fix audits)', Icons.star_rounded, Colors.amber),
                  ],
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

  Widget _buildAnalyticsCard(String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkCardBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
