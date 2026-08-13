import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.orangeGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.location_city_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  AppConstants.appName,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                ),
                Text(
                  isDeptAdmin ? 'Officer Portal • ${user?.departmentId ?? ""}' : 'Smart City Citizen Hub',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined, color: AppColors.nagpurOrange),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Predictive Rain Warning Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF0F172A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.4), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.thunderstorm_rounded, color: Colors.lightBlueAccent, size: 30),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          '⚡ Rain Warning — Ward 2 Dharampeth',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '45mm rainfall forecast in 24h. Waterlogging SLA automatically escalated.',
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

            // User Citizen Card
            Card(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.darkCardBorder),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: isDeptAdmin ? const Color(0xFF2563EB) : AppColors.nagpurOrange,
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
                                ? 'Department: ${user?.departmentId}'
                                : 'Reputation Score: ${user?.reputationPoints ?? 120} Points',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.nagpurOrange),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDeptAdmin ? const Color(0xFF1E40AF) : AppColors.nagpurOrange.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
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

            // Quick Shortcut Actions
            const Text(
              'Quick Services',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildQuickActionTile(
                  context: context,
                  title: 'AI Report',
                  icon: Icons.camera_alt_rounded,
                  color: AppColors.nagpurOrange,
                  onTap: () => context.push('/'),
                ),
                const SizedBox(width: 12),
                _buildQuickActionTile(
                  context: context,
                  title: 'Active Work',
                  icon: Icons.engineering_rounded,
                  color: AppColors.inProgressStatus,
                  onTap: () => context.push('/active-work'),
                ),
                const SizedBox(width: 12),
                _buildQuickActionTile(
                  context: context,
                  title: 'Resolutions',
                  icon: Icons.verified_rounded,
                  color: AppColors.resolvedStatus,
                  onTap: () => context.push('/public-feed'),
                ),
                if (isDeptAdmin) ...[
                  const SizedBox(width: 12),
                  _buildQuickActionTile(
                    context: context,
                    title: 'Admin Desk',
                    icon: Icons.dashboard_rounded,
                    color: const Color(0xFF3B82F6),
                    onTap: () => context.push('/admin'),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),

            // KPI Dashboard Row
            const Text(
              'Nagpur Live Overview',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildKpiCard('Total Reports', '1,420', Icons.report_problem_rounded, AppColors.nagpurOrange),
                const SizedBox(width: 12),
                _buildKpiCard('Red Alerts', '8 Active', Icons.warning_amber_rounded, AppColors.redAlert),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildKpiCard('In Progress', '184', Icons.engineering_rounded, AppColors.inProgressStatus),
                const SizedBox(width: 12),
                _buildKpiCard('Resolved (7d)', '1,228', Icons.verified_rounded, AppColors.resolvedStatus),
              ],
            ),

            const SizedBox(height: 24),
            // Recent Critical Issues Preview
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Critical Escalations',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('See All', style: TextStyle(color: AppColors.nagpurOrange, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),

            _buildIssueSampleTile(
              context: context,
              issueId: 'doc_red_alert_1',
              trackingId: 'NAG-8942',
              title: 'Major Sewer Water Leakage on Wardha Road',
              ward: 'Ward 4 - Dhantoli',
              reportCount: 14,
              isRedAlert: true,
              status: 'Reported',
              timeAgo: '15 mins ago',
            ),
            const SizedBox(height: 12),
            _buildIssueSampleTile(
              context: context,
              issueId: 'doc_red_alert_2',
              trackingId: 'NAG-7710',
              title: 'Dangerous Deep Pothole near Dharampeth Square',
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

  Widget _buildQuickActionTile({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKpiCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.darkCardBorder),
          ),
          padding: const EdgeInsets.all(14),
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
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIssueSampleTile({
    required BuildContext context,
    required String issueId,
    required String trackingId,
    required String title,
    required String ward,
    required int reportCount,
    required bool isRedAlert,
    required String status,
    required String timeAgo,
  }) {
    return Card(
      child: InkWell(
        onTap: () {
          context.push('/issue/$issueId');
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isRedAlert ? AppColors.redAlert.withValues(alpha: 0.5) : AppColors.darkCardBorder,
              width: isRedAlert ? 1.5 : 1,
            ),
          ),
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
                        gradient: AppColors.redAlertGradient,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.flash_on, size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            'RED ALERT ($reportCount)',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    trackingId,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.nagpurOrange),
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
              const SizedBox(height: 8),
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: status == 'In Progress'
                          ? AppColors.inProgressStatus.withValues(alpha: 0.2)
                          : AppColors.nagpurOrange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
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
      ),
    );
  }
}
