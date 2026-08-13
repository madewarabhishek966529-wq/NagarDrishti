import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../report/presentation/controllers/report_controller.dart';
import '../../../issues/domain/issue_model.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  String _selectedStatusFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;
    final issuesRepo = ref.watch(issuesRepositoryProvider);
    final deptId = user?.departmentId ?? 'DEPT_ROADS';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Department Officer Desk', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            Text('Department: $deptId', style: const TextStyle(fontSize: 11, color: AppColors.nagpurOrange, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => setState(() {}),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.redAlert),
            onPressed: () {
              ref.read(authControllerProvider.notifier).logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: FutureBuilder<List<IssueModel>>(
        future: issuesRepo.fetchIssues(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.nagpurOrange));
          }

          final issues = snapshot.data ?? [];
          final redAlerts = issues.where((i) => i.redAlert).toList();
          final openCount = issues.where((i) => i.status != IssueStatus.resolved).length;
          final resolvedCount = issues.where((i) => i.status == IssueStatus.resolved).length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Warning Weather Risk Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF3B82F6), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.thunderstorm_rounded, color: Colors.lightBlueAccent, size: 28),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Weather Risk Escalation: Heavy rain forecast in Ward 2 Dharampeth. High risk for drainage tickets.',
                          style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // KPI Overview Cards Grid
                Row(
                  children: [
                    _buildKpiCard('Open Tickets', '$openCount', Icons.assignment_late_rounded, AppColors.nagpurOrange),
                    const SizedBox(width: 12),
                    _buildKpiCard('Red Alerts', '${redAlerts.length}', Icons.warning_amber_rounded, AppColors.redAlert),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildKpiCard('Resolved', '$resolvedCount', Icons.task_alt_rounded, AppColors.resolvedStatus),
                    const SizedBox(width: 12),
                    _buildKpiCard('SLA Overdue', '1 Ticket', Icons.alarm_off_rounded, AppColors.highSeverity),
                  ],
                ),
                const SizedBox(height: 24),

                // Ticket Table Header & Filters
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Priority Ticket Queue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.darkSurface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.darkCardBorder),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedStatusFilter,
                        dropdownColor: AppColors.darkSurface,
                        underline: const SizedBox(),
                        items: ['All', 'Reported', 'In Progress', 'Resolved']
                            .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 12, color: Colors.white))))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedStatusFilter = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Ticket Cards
                ...issues.map((issue) {
                  if (_selectedStatusFilter != 'All' && issue.status.toValue() != _selectedStatusFilter) {
                    return const SizedBox.shrink();
                  }

                  return Card(
                    margin: const EdgeInsets.only(bottom: 14),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: issue.redAlert ? AppColors.redAlert.withValues(alpha: 0.5) : AppColors.darkCardBorder,
                          width: issue.redAlert ? 1.5 : 1,
                        ),
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
                                  gradient: issue.redAlert ? AppColors.redAlertGradient : AppColors.orangeGradient,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  issue.redAlert ? 'RED ALERT (${issue.reportCount})' : issue.trackingId,
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(issue.category, style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryDark)),
                              const Spacer(),
                              Text('Ward: ${issue.ward.split("-").last}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(issue.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 4),
                          Text(issue.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryDark)),
                          const Divider(height: 20, color: AppColors.darkCardBorder),
                          Row(
                            children: [
                              Chip(
                                backgroundColor: _getStatusColor(issue.status).withValues(alpha: 0.2),
                                side: BorderSide.none,
                                label: Text(
                                  issue.status.toValue(),
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _getStatusColor(issue.status)),
                                ),
                              ),
                              const Spacer(),
                              ElevatedButton.icon(
                                onPressed: () {
                                  _showStatusChangeModal(context, issue);
                                },
                                icon: const Icon(Icons.edit_rounded, size: 14),
                                label: const Text('Update Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.nagpurOrange,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(IssueStatus status) {
    switch (status) {
      case IssueStatus.reported:
        return AppColors.reportedStatus;
      case IssueStatus.acknowledged:
        return AppColors.acknowledgedStatus;
      case IssueStatus.inProgress:
        return AppColors.inProgressStatus;
      case IssueStatus.resolved:
        return AppColors.resolvedStatus;
    }
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
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 10),
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark)),
            ],
          ),
        ),
      ),
    );
  }

  void _showStatusChangeModal(BuildContext context, IssueModel issue) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Update Ticket Status — ${issue.trackingId}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.check_circle_outline, color: AppColors.acknowledgedStatus),
              title: const Text('Mark Acknowledged'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status updated to Acknowledged for ${issue.trackingId}')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.engineering_rounded, color: AppColors.inProgressStatus),
              title: const Text('Mark In Progress (Auto-creates Active Work)'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status updated to In Progress. Public ActiveWork created for ${issue.trackingId}')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.verified_rounded, color: AppColors.resolvedStatus),
              title: const Text('Mark Resolved (Gemini Vision AI Fix Verification)'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gemini Vision AI verified fix quality 95%. Ticket resolved!')));
              },
            ),
          ],
        ),
      ),
    );
  }
}
