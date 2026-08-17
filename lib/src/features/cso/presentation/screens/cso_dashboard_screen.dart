import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:nagardrishti/src/core/constants/app_colors.dart';
import 'package:nagardrishti/src/core/constants/app_constants.dart';
import 'package:nagardrishti/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:nagardrishti/src/features/issues/domain/issue_model.dart';
import '../controllers/cso_controller.dart';
import 'package:nagardrishti/src/features/cso/domain/cso_performance_model.dart';
import 'package:nagardrishti/src/features/cso/presentation/widgets/cso_action_dialog.dart';

class CsoDashboardScreen extends ConsumerStatefulWidget {
  const CsoDashboardScreen({super.key});

  @override
  ConsumerState<CsoDashboardScreen> createState() => _CsoDashboardScreenState();
}

class _CsoDashboardScreenState extends ConsumerState<CsoDashboardScreen> {
  String _searchQuery = '';
  String _selectedStatusFilter = 'ALL';

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authStateProvider).value;
    final zoneId = currentUser?.zoneId ?? 'zone_04';
    final zoneName = currentUser?.zoneName ?? 'Dhantoli';

    final issuesAsync = ref.watch(csoZoneIssuesProvider(zoneId));
    final performanceAsync = ref.watch(csoZonePerformanceProvider(zoneId));

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        elevation: 2,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF10B981)),
                  ),
                  child: Text(
                    'CSO OFFICER — ${zoneId.replaceAll("zone_", "ZONE ")}',
                    style: const TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$zoneName Zone Desk',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            Text(
              currentUser?.displayName ?? 'Rajesh Gaidhani',
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_rounded, color: AppColors.nagpurOrange),
            tooltip: 'Zone GIS Map',
            onPressed: () => context.push('/cso/map'),
          ),
          IconButton(
            icon: const Icon(Icons.warning_amber_rounded, color: AppColors.redAlert),
            tooltip: 'Major Problems',
            onPressed: () => context.push('/cso/major-problems'),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white70),
            tooltip: 'Logout',
            onPressed: () {
              ref.read(authControllerProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(csoZoneIssuesProvider(zoneId));
          ref.invalidate(csoZonePerformanceProvider(zoneId));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Zone Banner Card
              _buildZoneHeaderBanner(zoneName, zoneId, performanceAsync),

              const SizedBox(height: 20),

              // Quick Action Bar
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => context.push('/cso/major-problems'),
                      icon: const Icon(Icons.local_fire_department_rounded, size: 18, color: Colors.white),
                      label: const Text('Major Problems Rank', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.redAlert,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => context.push('/cso/map'),
                      icon: const Icon(Icons.my_location_rounded, size: 18, color: Colors.white),
                      label: const Text('Zone GIS Map', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // KPI Metrics Grid
              const Text(
                'Zone 04 Performance KPIs',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              performanceAsync.when(
                data: (perf) => _buildKpiGrid(perf),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Text('Error loading KPIs: $err', style: const TextStyle(color: AppColors.redAlert)),
              ),

              const SizedBox(height: 24),

              // Zone Complaints Management Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Zone Complaints Queue',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.darkCardBorder),
                    ),
                    child: Text(
                      'Filtered Zone: $zoneName',
                      style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 11),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Search & Status Filters
              TextField(
                onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Search by ticket ID, street address, or category...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.textSecondaryDark),
                  filled: true,
                  fillColor: AppColors.darkSurface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 10),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['ALL', 'REPORTED', 'IN_PROGRESS', 'RED_ALERT', 'OVERDUE', 'RESOLVED'].map((status) {
                    final isSel = _selectedStatusFilter == status;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSel,
                        label: Text(
                          status.replaceAll('_', ' '),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isSel ? Colors.white : AppColors.textSecondaryDark,
                          ),
                        ),
                        backgroundColor: AppColors.darkCard,
                        selectedColor: AppColors.nagpurOrange,
                        onSelected: (_) => setState(() => _selectedStatusFilter = status),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              // Issues List
              issuesAsync.when(
                data: (List<IssueModel> issues) {
                  final filtered = issues.where((IssueModel i) {
                    final matchesSearch = _searchQuery.isEmpty ||
                        i.trackingId.toLowerCase().contains(_searchQuery) ||
                        i.title.toLowerCase().contains(_searchQuery) ||
                        i.address.toLowerCase().contains(_searchQuery) ||
                        i.category.toLowerCase().contains(_searchQuery);

                    bool matchesStatus = true;
                    if (_selectedStatusFilter == 'REPORTED') matchesStatus = i.status == IssueStatus.reported;
                    if (_selectedStatusFilter == 'IN_PROGRESS') matchesStatus = i.status == IssueStatus.inProgress;
                    if (_selectedStatusFilter == 'RED_ALERT') matchesStatus = i.redAlert;
                    if (_selectedStatusFilter == 'OVERDUE') matchesStatus = DateTime.now().isAfter(i.slaDeadline) && i.status != IssueStatus.resolved;
                    if (_selectedStatusFilter == 'RESOLVED') matchesStatus = i.status == IssueStatus.resolved;

                    return matchesSearch && matchesStatus;
                  }).toList();

                  if (filtered.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(32),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.darkSurface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.check_circle_outline, color: Color(0xFF10B981), size: 48),
                          SizedBox(height: 12),
                          Text('No issues matching filter in this zone', style: TextStyle(color: Colors.white70)),
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
                      return _buildCsoIssueCard(context, issue, zoneId);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Text('Error loading zone issues: $err', style: const TextStyle(color: AppColors.redAlert)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildZoneHeaderBanner(String zoneName, String zoneId, AsyncValue<CsoZonePerformance> perfAsync) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.darkCardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.darkCardBorder),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NMC Zone 04 — $zoneName',
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Nagpur Municipal Corporation Zonal Office',
                    style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF10B981)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, color: Color(0xFF10B981), size: 8),
                    SizedBox(width: 6),
                    Text('Active Duty', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          perfAsync.when(
            data: (perf) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBannerStat('SLA Compliance', '${perf.slaComplianceRatePercentage.toStringAsFixed(1)}%', const Color(0xFF10B981)),
                _buildBannerStat('Avg Resolution', '${perf.averageResolutionTimeHours.toStringAsFixed(1)}h', const Color(0xFF38BDF8)),
                _buildBannerStat('Citizen Score', '${perf.citizenValidationScore.toStringAsFixed(1)} ★', AppColors.nagpurOrange),
              ],
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerStat(String title, String val, Color color) {
    return Column(
      children: [
        Text(val, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(title, style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 11)),
      ],
    );
  }

  Widget _buildKpiGrid(CsoZonePerformance perf) {
    final kpis = [
      {'title': 'Total Complaints', 'val': '${perf.totalComplaints}', 'icon': Icons.assignment_outlined, 'color': Colors.blue},
      {'title': 'New Complaints', 'val': '${perf.newComplaints}', 'icon': Icons.fiber_new_rounded, 'color': AppColors.nagpurOrange},
      {'title': 'Pending Queue', 'val': '${perf.pendingComplaints}', 'icon': Icons.hourglass_top_rounded, 'color': Colors.amber},
      {'title': 'In Progress', 'val': '${perf.inProgressComplaints}', 'icon': Icons.engineering_rounded, 'color': Colors.purpleAccent},
      {'title': 'Resolved', 'val': '${perf.resolvedComplaints}', 'icon': Icons.check_circle_rounded, 'color': const Color(0xFF10B981)},
      {'title': 'Overdue (Breached)', 'val': '${perf.overdueComplaints}', 'icon': Icons.alarm_off_rounded, 'color': AppColors.redAlert},
      {'title': 'Critical Hazards', 'val': '${perf.criticalComplaints}', 'icon': Icons.warning_rounded, 'color': Colors.redAccent},
      {'title': 'Red Alerts (10+)', 'val': '${perf.redAlertCount}', 'icon': Icons.campaign_rounded, 'color': Colors.deepOrange},
      {'title': 'Approaching SLA', 'val': '${perf.approachingSlaCount}', 'icon': Icons.timer_outlined, 'color': Colors.orangeAccent},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.15,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: kpis.length,
      itemBuilder: (context, idx) {
        final k = kpis[idx];
        final col = k['color'] as Color;
        return Container(
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: col.withValues(alpha: 0.3)),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(k['icon'] as IconData, color: col, size: 22),
              const SizedBox(height: 6),
              Text(
                k['val'] as String,
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                k['title'] as String,
                style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 9),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCsoIssueCard(BuildContext context, IssueModel issue, String zoneId) {
    final slaHealth = AppConstants.calculateSlaStatus(
      slaDeadline: issue.slaDeadline,
      isResolved: issue.status == IssueStatus.resolved,
      isRedAlert: issue.redAlert,
      isCritical: issue.severity == IssueSeverity.critical,
    );

    Color healthColor = const Color(0xFF10B981);
    if (slaHealth == SlaHealthStatus.atRisk) healthColor = Colors.amber;
    if (slaHealth == SlaHealthStatus.overdue) healthColor = AppColors.redAlert;
    if (slaHealth == SlaHealthStatus.critical) healthColor = Colors.redAccent;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: issue.redAlert ? AppColors.redAlert : AppColors.darkCardBorder,
          width: issue.redAlert ? 2 : 1,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Issue Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  issue.imageUrl.isNotEmpty ? issue.imageUrl : 'https://images.unsplash.com/photo-1584467735871-8e85353a8413',
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 60,
                    height: 60,
                    color: AppColors.darkCard,
                    child: const Icon(Icons.image, color: Colors.white54),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (issue.redAlert) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.redAlert,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('RED ALERT', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          issue.trackingId,
                          style: const TextStyle(color: AppColors.nagpurOrange, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: healthColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: healthColor),
                          ),
                          child: Text(
                            slaHealth.label,
                            style: TextStyle(color: healthColor, fontWeight: FontWeight.bold, fontSize: 9),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      issue.title,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${issue.category} • ${issue.ward}',
                      style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Details row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reports: ${issue.reportCount} citizen(s)',
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
              Text(
                'SLA: ${DateFormat('dd MMM, hh:mm a').format(issue.slaDeadline)}',
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),

          const Divider(color: AppColors.darkCardBorder, height: 16),

          // Action Toolbar for CSO
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () => context.push('/issue/${issue.id}'),
                icon: const Icon(Icons.visibility_outlined, size: 14),
                label: const Text('View', style: TextStyle(fontSize: 11)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => CsoActionDialog(issue: issue, zoneId: zoneId, initialAction: 'ACCEPT'),
                  );
                },
                icon: const Icon(Icons.check_rounded, size: 14),
                label: const Text('Accept', style: TextStyle(fontSize: 11)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => CsoActionDialog(issue: issue, zoneId: zoneId, initialAction: 'ASSIGN_SQUAD'),
                  );
                },
                icon: const Icon(Icons.person_add_alt_1_rounded, size: 14),
                label: const Text('Assign', style: TextStyle(fontSize: 11)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => CsoActionDialog(issue: issue, zoneId: zoneId, initialAction: 'ESCALATE'),
                  );
                },
                icon: const Icon(Icons.campaign_rounded, size: 14),
                label: const Text('Escalate', style: TextStyle(fontSize: 11)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.redAlert,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
