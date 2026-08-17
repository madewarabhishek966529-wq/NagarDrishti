import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:intl/intl.dart';
import 'package:nagardrishti/src/core/constants/app_colors.dart';
import 'package:nagardrishti/src/core/constants/app_constants.dart';
import 'package:nagardrishti/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:nagardrishti/src/features/issues/domain/issue_model.dart';
import 'package:nagardrishti/src/features/report/data/location_service.dart';
import '../controllers/cso_controller.dart';
import '../widgets/cso_action_dialog.dart';

class CsoZoneMapScreen extends ConsumerStatefulWidget {
  const CsoZoneMapScreen({super.key});

  @override
  ConsumerState<CsoZoneMapScreen> createState() => _CsoZoneMapScreenState();
}

class _CsoZoneMapScreenState extends ConsumerState<CsoZoneMapScreen> {
  final MapController _mapController = MapController();
  final LocationService _locationService = DeviceLocationService();
  String _selectedFilter = 'All Zone Issues';
  ll.LatLng? _userLocation;
  bool _isLocating = false;

  final List<String> _filters = [
    'All Zone Issues',
    'Red Alerts',
    'In Progress',
    'Critical Hazards',
    'Resolved',
  ];

  static const ll.LatLng _nagpurCenter = ll.LatLng(21.1458, 79.0882);

  @override
  void initState() {
    super.initState();
    _fetchRealUserLocation(autoCenter: true);
  }

  Future<void> _fetchRealUserLocation({bool autoCenter = false}) async {
    setState(() => _isLocating = true);
    try {
      final loc = await _locationService.getCurrentLocation();
      final userLatLng = ll.LatLng(loc.latitude, loc.longitude);
      setState(() {
        _userLocation = userLatLng;
        _isLocating = false;
      });

      if (autoCenter) {
        _mapController.move(userLatLng, 14.5);
      }
    } catch (_) {
      setState(() => _isLocating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authStateProvider).value;
    final zoneId = currentUser?.zoneId ?? 'zone_04';
    final zoneName = currentUser?.zoneName ?? 'Dhantoli';

    final zoneIssuesAsync = ref.watch(csoZoneIssuesProvider(zoneId));

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('GIS Map — Zone 04 ($zoneName)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
            const Text('Auto-filtered strictly for assigned zone', style: TextStyle(fontSize: 11, color: AppColors.textSecondaryDark)),
          ],
        ),
        actions: [
          IconButton(
            icon: _isLocating
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.nagpurOrange))
                : const Icon(Icons.my_location_rounded, color: AppColors.nagpurOrange),
            onPressed: () => _fetchRealUserLocation(autoCenter: true),
          ),
        ],
      ),
      body: zoneIssuesAsync.when(
        data: (List<IssueModel> issues) {
          final filteredIssues = issues.where((IssueModel issue) {
            if (_selectedFilter == 'Red Alerts') return issue.redAlert;
            if (_selectedFilter == 'In Progress') return issue.status == IssueStatus.inProgress;
            if (_selectedFilter == 'Critical Hazards') return issue.severity == IssueSeverity.critical;
            if (_selectedFilter == 'Resolved') return issue.status == IssueStatus.resolved;
            return true;
          }).toList();

          return Stack(
            children: [
              // OpenStreetMap Engine
              FlutterMap(
                mapController: _mapController,
                options: const MapOptions(
                  initialCenter: _nagpurCenter,
                  initialZoom: 14.0,
                  minZoom: 5.0,
                  maxZoom: 18.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                    subdomains: const ['a', 'b', 'c', 'd'],
                    userAgentPackageName: 'com.example.nagardrishti',
                  ),

                  // Red Alert Radii
                  CircleLayer(
                    circles: filteredIssues.where((IssueModel i) => i.redAlert).map((IssueModel issue) {
                      return CircleMarker(
                        point: ll.LatLng(issue.latitude, issue.longitude),
                        radius: 300,
                        useRadiusInMeter: true,
                        color: AppColors.redAlert.withValues(alpha: 0.2),
                        borderColor: AppColors.redAlert,
                        borderStrokeWidth: 2,
                      );
                    }).toList(),
                  ),

                  // Markers Layer
                  MarkerLayer(
                    markers: [
                      if (_userLocation != null)
                        Marker(
                          point: _userLocation!,
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blueAccent.withValues(alpha: 0.25),
                                ),
                              ),
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blueAccent,
                                  border: Border.all(color: Colors.white, width: 3),
                                ),
                              ),
                            ],
                          ),
                        ),

                      ...filteredIssues.map((IssueModel issue) {
                        Color mColor = const Color(0xFF10B981);
                        if (issue.status == IssueStatus.reported) mColor = AppColors.nagpurOrange;
                        if (issue.status == IssueStatus.inProgress) mColor = Colors.purpleAccent;
                        if (issue.redAlert) mColor = AppColors.redAlert;

                        return Marker(
                          point: ll.LatLng(issue.latitude, issue.longitude),
                          width: 140,
                          height: 60,
                          alignment: Alignment.topCenter,
                          child: GestureDetector(
                            onTap: () => _showCsoClusterModal(context, issue, zoneId),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: mColor,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(color: mColor.withValues(alpha: 0.4), blurRadius: 8),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (issue.redAlert) ...[
                                        const Icon(Icons.flash_on_rounded, color: Colors.white, size: 12),
                                        const SizedBox(width: 2),
                                      ],
                                      Flexible(
                                        child: Text(
                                          '${issue.trackingId} (${issue.reportCount})',
                                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.arrow_drop_down_rounded, color: mColor, size: 22),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),

              // Filter Chips
              Positioned(
                top: 14,
                left: 14,
                right: 14,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filters.map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          selected: isSelected,
                          label: Text(filter),
                          onSelected: (val) => setState(() => _selectedFilter = filter),
                          selectedColor: AppColors.nagpurOrange,
                          backgroundColor: AppColors.darkSurface.withValues(alpha: 0.95),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textSecondaryDark,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // Bottom Stats Summary Overlay
              Positioned(
                bottom: 20,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.darkSurface.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.darkCardBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMapStat('Zone Issues', '${filteredIssues.length}', Colors.white),
                      _buildMapStat('Red Alerts', '${filteredIssues.where((IssueModel i) => i.redAlert).length}', AppColors.redAlert),
                      _buildMapStat('Active Work', '${filteredIssues.where((IssueModel i) => i.status == IssueStatus.inProgress).length}', Colors.purpleAccent),
                      _buildMapStat('Resolved', '${filteredIssues.where((IssueModel i) => i.status == IssueStatus.resolved).length}', const Color(0xFF10B981)),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading map: $err', style: const TextStyle(color: AppColors.redAlert))),
      ),
    );
  }

  Widget _buildMapStat(String label, String count, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(count, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 10)),
      ],
    );
  }

  void _showCsoClusterModal(BuildContext context, IssueModel issue, String zoneId) {
    final slaHealth = AppConstants.calculateSlaStatus(
      slaDeadline: issue.slaDeadline,
      isResolved: issue.status == IssueStatus.resolved,
      isRedAlert: issue.redAlert,
      isCritical: issue.severity == IssueSeverity.critical,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (issue.redAlert) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: AppColors.redAlert, borderRadius: BorderRadius.circular(6)),
                    child: const Text('RED ALERT CLUSTER', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(issue.trackingId, style: const TextStyle(color: AppColors.nagpurOrange, fontWeight: FontWeight.bold, fontSize: 14)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.darkCard,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.darkCardBorder),
                  ),
                  child: Text(slaHealth.label, style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 10)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(issue.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text('Category: ${issue.category} • Ward: ${issue.ward}', style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('👥 Reports: ${issue.reportCount} citizen(s)', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                Text('🏢 Department: ${issue.assignedDepartmentId.replaceAll("DEPT_", "")}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 6),
            Text('⏱️ SLA Target: ${DateFormat('dd MMM, hh:mm a').format(issue.slaDeadline)}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
            const Divider(color: AppColors.darkCardBorder, height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    showDialog(
                      context: context,
                      builder: (_) => CsoActionDialog(issue: issue, zoneId: zoneId, initialAction: 'ACCEPT'),
                    );
                  },
                  icon: const Icon(Icons.check, size: 14),
                  label: const Text('Accept', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    showDialog(
                      context: context,
                      builder: (_) => CsoActionDialog(issue: issue, zoneId: zoneId, initialAction: 'ASSIGN_SQUAD'),
                    );
                  },
                  icon: const Icon(Icons.person_add, size: 14),
                  label: const Text('Assign Squad', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    showDialog(
                      context: context,
                      builder: (_) => CsoActionDialog(issue: issue, zoneId: zoneId, initialAction: 'ESCALATE'),
                    );
                  },
                  icon: const Icon(Icons.campaign, size: 14),
                  label: const Text('Escalate', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.redAlert, foregroundColor: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
