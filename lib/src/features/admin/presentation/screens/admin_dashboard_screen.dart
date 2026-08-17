import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nagardrishti/src/core/constants/app_colors.dart';
import 'package:nagardrishti/src/core/constants/app_constants.dart';
import 'package:nagardrishti/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:nagardrishti/src/features/issues/data/gemini_verification_service.dart';
import 'package:nagardrishti/src/features/issues/domain/issue_model.dart';
import 'package:nagardrishti/src/features/report/presentation/controllers/report_controller.dart';
import 'package:nagardrishti/src/features/admin/domain/admin_command_center_models.dart';
import '../controllers/admin_command_center_controller.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  String _selectedKpiFilter = 'ALL';
  String _selectedZoneFilter = 'ALL';
  String _selectedDeptFilter = 'ALL';

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;
    final kpiAsync = ref.watch(cityKpiOverviewProvider);
    final issuesRepo = ref.watch(issuesRepositoryProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        elevation: 3,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.nagpurOrange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.nagpurOrange),
                  ),
                  child: const Text('NMC COMMAND', style: TextStyle(color: AppColors.nagpurOrange, fontSize: 9, fontWeight: FontWeight.w900)),
                ),
                const SizedBox(width: 6),
                const Flexible(
                  child: Text(
                    'Executive Command',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Text(
              'Authority: ${user?.displayName ?? "Municipal Commissioner"} (${user?.departmentId ?? "All 10 Zones"})',
              style: const TextStyle(fontSize: 10, color: AppColors.textSecondaryDark),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.nagpurOrange, size: 20),
            tooltip: 'Refresh Data',
            onPressed: () {
              ref.invalidate(cityKpiOverviewProvider);
              ref.invalidate(tenZonePerformanceProvider);
              ref.invalidate(departmentPerformanceProvider);
              setState(() {});
            },
          ),
          IconButton(
            icon: const Icon(Icons.menu_open_rounded, color: Colors.white, size: 20),
            tooltip: 'Command Navigation Menu',
            onPressed: () => _showCommandNavModal(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.redAlert, size: 20),
            tooltip: 'Logout',
            onPressed: () {
              ref.read(authControllerProvider.notifier).logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(cityKpiOverviewProvider);
          ref.invalidate(tenZonePerformanceProvider);
          ref.invalidate(departmentPerformanceProvider);
          setState(() {});
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // PRIORITY 1 & 2: Emergency Alert Banner
              _buildPriorityAlertBanner(context, ref),

              const SizedBox(height: 16),

              // PRIORITY 3: KPI Overview Cards Grid (Interactive Clickable Filtering)
              const Text('NMC City Command KPI Metrics', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              kpiAsync.when(
                data: (kpi) => _buildCityKpiGrid(kpi),
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.nagpurOrange)),
                error: (err, _) => Text('Error loading KPIs: $err', style: const TextStyle(color: AppColors.redAlert)),
              ),

              const SizedBox(height: 20),

              // Quick Command Hub Shortcut Grid
              const Text('City Command Hub Modules', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildQuickCommandModulesGrid(context),

              const SizedBox(height: 24),

              // PRIORITY 4: City Complaints Command Queue Header & Filters
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('City Complaints Command Queue', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('Active Filter: ${_selectedKpiFilter.replaceAll("_", " ")}', style: const TextStyle(color: AppColors.nagpurOrange, fontSize: 11, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  if (_selectedKpiFilter != 'ALL')
                    OutlinedButton(
                      onPressed: () => setState(() => _selectedKpiFilter = 'ALL'),
                      child: const Text('Clear KPI Filter', style: TextStyle(fontSize: 10)),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Zone & Department Secondary Filters
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    DropdownButton<String>(
                      value: _selectedZoneFilter,
                      dropdownColor: AppColors.darkSurface,
                      underline: const SizedBox(),
                      items: [
                        const DropdownMenuItem(value: 'ALL', child: Text('All 10 Zones', style: TextStyle(color: Colors.white, fontSize: 12))),
                        ...AppConstants.zoneIdToNameMap.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value, style: const TextStyle(color: Colors.white, fontSize: 12)))),
                      ],
                      onChanged: (v) => setState(() => _selectedZoneFilter = v!),
                    ),
                    const SizedBox(width: 10),
                    DropdownButton<String>(
                      value: _selectedDeptFilter,
                      dropdownColor: AppColors.darkSurface,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: 'ALL', child: Text('All Departments', style: TextStyle(color: Colors.white, fontSize: 12))),
                        DropdownMenuItem(value: 'DEPT_ROADS', child: Text('Roads & Infra', style: TextStyle(color: Colors.white, fontSize: 12))),
                        DropdownMenuItem(value: 'DEPT_WATER', child: Text('Water Supply', style: TextStyle(color: Colors.white, fontSize: 12))),
                        DropdownMenuItem(value: 'DEPT_DRAINAGE', child: Text('Drainage', style: TextStyle(color: Colors.white, fontSize: 12))),
                        DropdownMenuItem(value: 'DEPT_ELECTRIC', child: Text('Electrical', style: TextStyle(color: Colors.white, fontSize: 12))),
                        DropdownMenuItem(value: 'DEPT_SANITATION', child: Text('Sanitation', style: TextStyle(color: Colors.white, fontSize: 12))),
                      ],
                      onChanged: (v) => setState(() => _selectedDeptFilter = v!),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Ticket Table / Queue List
              FutureBuilder<List<IssueModel>>(
                future: issuesRepo.fetchIssues(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.nagpurOrange));
                  }

                  final issues = snapshot.data ?? [];
                  final now = DateTime.now();

                  final filtered = issues.where((issue) {
                    final issueZone = AppConstants.wardToZoneIdMap[issue.ward] ?? 'zone_04';

                    bool matchesZone = _selectedZoneFilter == 'ALL' || issueZone == _selectedZoneFilter;
                    bool matchesDept = _selectedDeptFilter == 'ALL' || issue.assignedDepartmentId == _selectedDeptFilter;

                    bool matchesKpi = true;
                    if (_selectedKpiFilter == 'CRITICAL') matchesKpi = issue.severity == IssueSeverity.critical;
                    if (_selectedKpiFilter == 'RED_ALERTS') matchesKpi = issue.redAlert;
                    if (_selectedKpiFilter == 'SOS') matchesKpi = issue.category == 'SOS Emergency' || issue.slaDeadline.difference(issue.createdAt).inHours <= 4;
                    if (_selectedKpiFilter == 'OVERDUE') matchesKpi = issue.status != IssueStatus.resolved && now.isAfter(issue.slaDeadline);
                    if (_selectedKpiFilter == 'AT_RISK') matchesKpi = issue.status != IssueStatus.resolved && !now.isAfter(issue.slaDeadline) && issue.slaDeadline.difference(now).inHours <= 6;
                    if (_selectedKpiFilter == 'IN_PROGRESS') matchesKpi = issue.status == IssueStatus.inProgress;
                    if (_selectedKpiFilter == 'RESOLVED') matchesKpi = issue.status == IssueStatus.resolved;

                    return matchesZone && matchesDept && matchesKpi;
                  }).toList();

                  if (filtered.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(color: AppColors.darkSurface, borderRadius: BorderRadius.circular(16)),
                      child: const Column(
                        children: [
                          Icon(Icons.check_circle_outline, color: Color(0xFF10B981), size: 48),
                          SizedBox(height: 12),
                          Text('No complaints matching selected command parameters', style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, idx) {
                      final issue = filtered[idx];
                      return _buildAdminTicketCard(context, issue);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityAlertBanner(BuildContext context, WidgetRef ref) {
    final sosQueue = ref.watch(sosEmergencyQueueProvider).value ?? [];
    final redAlerts = ref.watch(redAlertMasterQueueProvider).value ?? [];

    if (sosQueue.isNotEmpty) {
      final sos = sosQueue.first;
      final hoursLeft = sos.slaDeadline.difference(DateTime.now()).inHours;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.redAccent, width: 2),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 30),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🚨 PRIORITY 1: SOS EMERGENCY ACTIVE', style: TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold)),
                  Text('${sos.title} • ${sos.ward} • ${hoursLeft}h SLA left', style: const TextStyle(fontSize: 11, color: Colors.white70)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => context.push('/admin/sos'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
              child: const Text('Action SOS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }

    if (redAlerts.isNotEmpty) {
      final alert = redAlerts.first;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.redAlert.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.redAlert, width: 2),
        ),
        child: Row(
          children: [
            const Icon(Icons.campaign_rounded, color: AppColors.redAlert, size: 30),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🔥 PRIORITY 2: RED ALERT CLUSTER SURGE (${alert.reportCount} REPORTS)', style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold)),
                  Text('${alert.title} • Ward: ${alert.ward}', style: const TextStyle(fontSize: 11, color: Colors.white70)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => context.push('/admin/red-alerts'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.redAlert, foregroundColor: Colors.white),
              child: const Text('Open Hub', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF10B981)),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 28),
          SizedBox(width: 14),
          Expanded(
            child: Text('NMC City Services Operating Normal. No un-actioned SOS or Red Alert surges.', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildCityKpiGrid(CityKpiOverview kpi) {
    final items = [
      {'key': 'ALL', 'title': 'TOTAL COMPLAINTS', 'val': '${kpi.totalComplaints}', 'col': Colors.white},
      {'key': 'CRITICAL', 'title': 'CRITICAL', 'val': '${kpi.criticalComplaints}', 'col': Colors.redAccent},
      {'key': 'RED_ALERTS', 'title': 'RED ALERTS', 'val': '${kpi.redAlertCount}', 'col': AppColors.redAlert},
      {'key': 'SOS', 'title': 'SOS', 'val': '${kpi.sosCount}', 'col': Colors.deepOrange},
      {'key': 'OVERDUE', 'title': 'OVERDUE', 'val': '${kpi.overdueComplaints}', 'col': Colors.orangeAccent},
      {'key': 'AT_RISK', 'title': 'AT RISK', 'val': '${kpi.atRiskComplaints}', 'col': Colors.amber},
      {'key': 'IN_PROGRESS', 'title': 'IN PROGRESS', 'val': '${kpi.inProgressComplaints}', 'col': Colors.purpleAccent},
      {'key': 'RESOLVED', 'title': 'RESOLVED', 'val': '${kpi.resolvedComplaints}', 'col': const Color(0xFF10B981)},
      {'key': 'ALL', 'title': 'SLA %', 'val': '${kpi.overallSlaCompliancePercentage.toStringAsFixed(1)}%', 'col': const Color(0xFF38BDF8)},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.25,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: items.length,
      itemBuilder: (context, idx) {
        final item = items[idx];
        final isSel = _selectedKpiFilter == item['key'];
        final col = item['col'] as Color;

        return GestureDetector(
          onTap: () {
            setState(() => _selectedKpiFilter = item['key'] as String);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSel ? col.withValues(alpha: 0.25) : AppColors.darkSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isSel ? col : col.withValues(alpha: 0.3), width: isSel ? 2 : 1),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(item['val'] as String, style: TextStyle(color: col, fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 2),
                Text(item['title'] as String, style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 9, fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 1),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickCommandModulesGrid(BuildContext context) {
    final modules = [
      {'title': 'Live City Map', 'icon': Icons.map_rounded, 'route': '/admin/map', 'color': AppColors.nagpurOrange},
      {'title': 'Major Problems', 'icon': Icons.warning_rounded, 'route': '/admin/major-problems', 'color': Colors.redAccent},
      {'title': 'Red Alert Center', 'icon': Icons.campaign_rounded, 'route': '/admin/red-alerts', 'color': AppColors.redAlert},
      {'title': 'SOS Center', 'icon': Icons.local_fire_department_rounded, 'route': '/admin/sos', 'color': Colors.deepOrange},
      {'title': '10-Zone Grid', 'icon': Icons.grid_view_rounded, 'route': '/admin/zones', 'color': const Color(0xFF38BDF8)},
      {'title': 'CSO Management', 'icon': Icons.badge_rounded, 'route': '/admin/csos', 'color': const Color(0xFF10B981)},
      {'title': 'SLA Monitor', 'icon': Icons.timer_rounded, 'route': '/admin/sla', 'color': Colors.amber},
      {'title': 'Departments', 'icon': Icons.business_rounded, 'route': '/admin/departments', 'color': const Color(0xFF2563EB)},
      {'title': 'Finance Budget', 'icon': Icons.account_balance_wallet_rounded, 'route': '/admin/finance', 'color': Colors.lightGreenAccent},
      {'title': 'Proof-of-Fix Audit', 'icon': Icons.auto_awesome, 'route': '/admin/proof-of-fix', 'color': Colors.cyanAccent},
      {'title': 'Citizen Validation', 'icon': Icons.rate_review_rounded, 'route': '/admin/citizen-validation', 'color': Colors.purpleAccent},
      {'title': 'City Analytics', 'icon': Icons.analytics_rounded, 'route': '/admin/analytics', 'color': Colors.pinkAccent},
      {'title': 'Audit Logs', 'icon': Icons.history_edu_rounded, 'route': '/admin/audit-logs', 'color': Colors.tealAccent},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.15,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: modules.length,
      itemBuilder: (context, idx) {
        final m = modules[idx];
        final col = m['color'] as Color;

        return GestureDetector(
          onTap: () => context.push(m['route'] as String),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: col.withValues(alpha: 0.3)),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(m['icon'] as IconData, color: col, size: 22),
                const SizedBox(height: 6),
                Text(m['title'] as String, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 1),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAdminTicketCard(BuildContext context, IssueModel issue) {
    final isOverdue = DateTime.now().isAfter(issue.slaDeadline) && issue.status != IssueStatus.resolved;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: issue.redAlert ? AppColors.redAlert : AppColors.darkCardBorder, width: issue.redAlert ? 2 : 1),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (issue.redAlert) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.redAlert, borderRadius: BorderRadius.circular(4)),
                  child: const Text('RED ALERT', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 6),
              ],
              Text(issue.trackingId, style: const TextStyle(color: AppColors.nagpurOrange, fontWeight: FontWeight.bold, fontSize: 12)),
              const Spacer(),
              Text('Ward: ${issue.ward.split("-").last}', style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 8),
          Text(issue.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 4),
          Text('${issue.category} • Reports: ${issue.reportCount} • Dept: ${issue.assignedDepartmentId.replaceAll("DEPT_", "")}', style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 11)),
          const Divider(color: AppColors.darkCardBorder, height: 16),

          Row(
            children: [
              Chip(
                backgroundColor: (isOverdue ? AppColors.redAlert : const Color(0xFF10B981)).withValues(alpha: 0.15),
                side: BorderSide.none,
                label: Text(
                  issue.status.toValue(),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isOverdue ? AppColors.redAlert : const Color(0xFF10B981)),
                ),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () => context.push('/issue/${issue.id}'),
                icon: const Icon(Icons.visibility_outlined, size: 14),
                label: const Text('View', style: TextStyle(fontSize: 11)),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _showStatusChangeModal(context, issue),
                icon: const Icon(Icons.edit, size: 14),
                label: const Text('Update Status', style: TextStyle(fontSize: 11)),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.nagpurOrange, foregroundColor: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCommandNavModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('NMC Command Center Navigation', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(color: AppColors.darkCardBorder, height: 20),
            ListTile(leading: const Icon(Icons.map, color: AppColors.nagpurOrange), title: const Text('City GIS Command Map'), onTap: () { Navigator.pop(ctx); context.push('/admin/map'); }),
            ListTile(leading: const Icon(Icons.warning, color: Colors.redAccent), title: const Text('Major Problems Priority Rank'), onTap: () { Navigator.pop(ctx); context.push('/admin/major-problems'); }),
            ListTile(leading: const Icon(Icons.campaign, color: AppColors.redAlert), title: const Text('Red Alert Center'), onTap: () { Navigator.pop(ctx); context.push('/admin/red-alerts'); }),
            ListTile(leading: const Icon(Icons.local_fire_department, color: Colors.deepOrange), title: const Text('SOS Emergency Command Hub'), onTap: () { Navigator.pop(ctx); context.push('/admin/sos'); }),
            ListTile(leading: const Icon(Icons.grid_view, color: Color(0xFF38BDF8)), title: const Text('10-Zone Performance Grid'), onTap: () { Navigator.pop(ctx); context.push('/admin/zones'); }),
            ListTile(leading: const Icon(Icons.badge, color: Color(0xFF10B981)), title: const Text('CSO Management Roster'), onTap: () { Navigator.pop(ctx); context.push('/admin/csos'); }),
            ListTile(leading: const Icon(Icons.account_balance_wallet, color: Colors.lightGreenAccent), title: const Text('Financial Analytics & Budget'), onTap: () { Navigator.pop(ctx); context.push('/admin/finance'); }),
            ListTile(leading: const Icon(Icons.auto_awesome, color: Colors.cyanAccent), title: const Text('Proof-of-Fix Gemini Audit'), onTap: () { Navigator.pop(ctx); context.push('/admin/proof-of-fix'); }),
            ListTile(leading: const Icon(Icons.history_edu, color: Colors.tealAccent), title: const Text('Immutable Audit Logs'), onTap: () { Navigator.pop(ctx); context.push('/admin/audit-logs'); }),
          ],
        ),
      ),
    );
  }

  void _showStatusChangeModal(BuildContext context, IssueModel issue) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
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
                ref.read(adminActionControllerProvider.notifier).executeAdminAction(
                  issueId: issue.id,
                  actionType: 'CHANGE_STATUS',
                  details: 'Marked Acknowledged',
                  newStatus: IssueStatus.acknowledged,
                );
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status updated to Acknowledged for ${issue.trackingId}')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.engineering_rounded, color: AppColors.inProgressStatus),
              title: const Text('Mark In Progress'),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(adminActionControllerProvider.notifier).executeAdminAction(
                  issueId: issue.id,
                  actionType: 'CHANGE_STATUS',
                  details: 'Marked In Progress',
                  newStatus: IssueStatus.inProgress,
                );
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status updated to In Progress for ${issue.trackingId}')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.auto_awesome, color: AppColors.resolvedStatus),
              title: const Text('Mark Resolved with Gemini AI Verification'),
              onTap: () {
                Navigator.pop(ctx);
                _showGeminiResolutionModal(context, issue);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showGeminiResolutionModal(BuildContext context, IssueModel issue) {
    bool isVerifying = false;
    GeminiVerificationResult? result;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctxState, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctxState).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text('Gemini AI Resolution Audit — ${issue.trackingId}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                ],
              ),
              const SizedBox(height: 12),
              const Text('Upload completed work photo captured by field team to trigger automatic Gemini Vision visual validation.', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark)),
              const SizedBox(height: 16),

              if (result != null) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.resolvedStatus.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.resolvedStatus),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.verified_rounded, color: AppColors.resolvedStatus, size: 20),
                          const SizedBox(width: 8),
                          Text('Fix Quality Score: ${(result!.fixQualityScore * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.resolvedStatus, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(result!.verificationSummary, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              ElevatedButton.icon(
                onPressed: isVerifying
                    ? null
                    : () async {
                        setModalState(() => isVerifying = true);
                        final picker = ImagePicker();
                        final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
                        final bytes = picked != null ? await picked.readAsBytes() : null;

                        final verificationService = GeminiVisionVerificationService();
                        final audit = await verificationService.verifyResolutionQuality(
                          bytes ?? List.generate(10, (i) => i) as dynamic,
                          bytes ?? List.generate(10, (i) => i) as dynamic,
                          issue.category,
                        );

                        setModalState(() {
                          isVerifying = false;
                          result = audit;
                        });

                        await ref.read(issuesRepositoryProvider).resolveIssueWithProof(
                          issueId: issue.id,
                          afterImageUrl: 'https://images.unsplash.com/photo-1541888946425-d0fbb186a5b7',
                          fixQualityScore: audit.fixQualityScore,
                          isVerifiedFixed: audit.isVerifiedFixed,
                          verificationSummary: audit.verificationSummary,
                        );

                        ref.read(adminActionControllerProvider.notifier).executeAdminAction(
                          issueId: issue.id,
                          actionType: 'RESOLVED_GEMINI_AUDIT',
                          details: 'Resolved with Gemini Vision score ${(audit.fixQualityScore * 100).toInt()}%',
                          newStatus: IssueStatus.resolved,
                        );

                        if (mounted) setState(() {});
                      },
                icon: isVerifying ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.photo_camera_rounded),
                label: Text(isVerifying ? 'Gemini AI Auditing Photos...' : 'Pick Repair Photo & Verify'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.nagpurOrange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
