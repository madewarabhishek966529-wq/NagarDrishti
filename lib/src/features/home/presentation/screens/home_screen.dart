import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/domain/app_user.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final isDeptAdmin = user?.role == UserRole.deptAdmin;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.nagpurOrange.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.location_city, color: AppColors.nagpurOrange, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  AppConstants.appName,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
                Text(
                  isDeptAdmin ? 'Dept Admin: ${user?.departmentId ?? "Portal"}' : 'Smart Nagpur Citizen Portal',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Weather Predictive Alert Banner (Phase 7 preview)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.thunderstorm, color: Colors.lightBlueAccent, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          '⚠️ Heavy Rain Warning — Ward 2 Dharampeth',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Over 45mm rain expected in 24h. Waterlogging SLA priority auto-escalated.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // User Welcome & Stats Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: AppColors.nagpurOrange,
                      child: Text(
                        (user?.displayName.isNotEmpty == true)
                            ? user!.displayName[0].toUpperCase()
                            : 'N',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Namaste, ${user?.displayName ?? "Citizen"}!',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isDeptAdmin
                                ? 'Managing Department: ${user?.departmentId}'
                                : 'Reputation Score: ${user?.reputationPoints ?? 0} Points',
                            style: const TextStyle(fontSize: 13, color: AppColors.nagpurOrange),
                          ),
                        ],
                      ),
                    ),
                    Chip(
                      backgroundColor: isDeptAdmin
                          ? const Color(0xFF1E40AF)
                          : AppColors.nagpurOrange.withValues(alpha: 0.2),
                      side: BorderSide.none,
                      label: Text(
                        isDeptAdmin ? 'ADMIN' : 'CITIZEN',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDeptAdmin ? Colors.white : AppColors.nagpurOrange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // KPI Dashboard Row
            const Text(
              'Nagpur Live Overview',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildKpiCard('Total Reported', '1,420', Icons.report_problem, AppColors.nagpurOrange),
                const SizedBox(width: 12),
                _buildKpiCard('Red Alerts', '8 Active', Icons.warning_amber_rounded, AppColors.redAlert),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildKpiCard('In Progress', '184', Icons.engineering, AppColors.inProgressStatus),
                const SizedBox(width: 12),
                _buildKpiCard('Resolved (7d)', '1,228', Icons.verified, AppColors.resolvedStatus),
              ],
            ),

            const SizedBox(height: 24),
            // Recent Critical Issues List Preview
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Critical Red Alert Tickets',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('See All', style: TextStyle(color: AppColors.nagpurOrange)),
                ),
              ],
            ),
            const SizedBox(height: 8),

            _buildIssueSampleTile(
              trackingId: 'NAG-8942',
              title: 'Major Sewer Water Leakage on Wardha Road',
              ward: 'Ward 4 - Dhantoli',
              reportCount: 14,
              isRedAlert: true,
              status: 'Reported',
              timeAgo: '15 mins ago',
            ),
            const SizedBox(height: 10),
            _buildIssueSampleTile(
              trackingId: 'NAG-7710',
              title: 'Dangerous Deep Pothole near Square',
              ward: 'Ward 2 - Dharampeth',
              reportCount: 11,
              isRedAlert: true,
              status: 'In Progress',
              timeAgo: '1 hour ago',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: color, size: 22),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIssueSampleTile({
    required String trackingId,
    required String title,
    required String ward,
    required int reportCount,
    required bool isRedAlert,
    required String status,
    required String timeAgo,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isRedAlert) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.redAlert,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.flash_on, size: 12, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          'RED ALERT ($reportCount Reports)',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  trackingId,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondaryDark),
                ),
                const Spacer(),
                Text(
                  timeAgo,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondaryDark),
                const SizedBox(width: 4),
                Text(
                  ward,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: status == 'In Progress'
                        ? AppColors.inProgressStatus.withValues(alpha: 0.2)
                        : AppColors.nagpurOrange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: status == 'In Progress' ? AppColors.inProgressStatus : AppColors.nagpurOrange,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
