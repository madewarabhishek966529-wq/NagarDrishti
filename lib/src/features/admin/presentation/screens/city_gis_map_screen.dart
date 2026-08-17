import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:intl/intl.dart';
import 'package:nagardrishti/src/core/constants/app_colors.dart';
import 'package:nagardrishti/src/core/constants/app_constants.dart';
import 'package:nagardrishti/src/features/issues/domain/issue_model.dart';
import 'package:nagardrishti/src/features/report/data/location_service.dart';
import 'package:nagardrishti/src/features/report/presentation/controllers/report_controller.dart';
import '../controllers/admin_command_center_controller.dart';

class CityGisMapScreen extends ConsumerStatefulWidget {
  const CityGisMapScreen({super.key});

  @override
  ConsumerState<CityGisMapScreen> createState() => _CityGisMapScreenState();
}

class _CityGisMapScreenState extends ConsumerState<CityGisMapScreen> {
  final MapController _mapController = MapController();
  final LocationService _locationService = DeviceLocationService();

  String _selectedZoneFilter = 'ALL';
  final String _selectedCategoryFilter = 'ALL';
  String _selectedStatusFilter = 'ALL';
  bool _showRedAlertRadii = true;
  ll.LatLng? _userLocation;

  static const ll.LatLng _nagpurCenter = ll.LatLng(21.1458, 79.0882);

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    try {
      final loc = await _locationService.getCurrentLocation();
      setState(() {
        _userLocation = ll.LatLng(loc.latitude, loc.longitude);
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final issuesRepo = ref.watch(issuesRepositoryProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('NMC City GIS Command Map', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('Live spatial tracking across all 10 NMC Zones', style: TextStyle(fontSize: 11, color: AppColors.textSecondaryDark)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_showRedAlertRadii ? Icons.radar : Icons.radar_outlined, color: AppColors.redAlert),
            tooltip: 'Toggle Red Alert Radii',
            onPressed: () => setState(() => _showRedAlertRadii = !_showRedAlertRadii),
          ),
          IconButton(
            icon: const Icon(Icons.my_location_rounded, color: AppColors.nagpurOrange),
            onPressed: () {
              if (_userLocation != null) {
                _mapController.move(_userLocation!, 14.5);
              } else {
                _mapController.move(_nagpurCenter, 13.5);
              }
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

          final allIssues = snapshot.data ?? [];
          final filtered = allIssues.where((issue) {
            final issueZone = AppConstants.wardToZoneIdMap[issue.ward] ?? 'zone_04';
            bool matchesZone = _selectedZoneFilter == 'ALL' || issueZone == _selectedZoneFilter;
            bool matchesCat = _selectedCategoryFilter == 'ALL' || issue.category.contains(_selectedCategoryFilter);
            bool matchesStatus = true;
            if (_selectedStatusFilter == 'REPORTED') matchesStatus = issue.status == IssueStatus.reported;
            if (_selectedStatusFilter == 'IN_PROGRESS') matchesStatus = issue.status == IssueStatus.inProgress;
            if (_selectedStatusFilter == 'RED_ALERT') matchesStatus = issue.redAlert;
            if (_selectedStatusFilter == 'RESOLVED') matchesStatus = issue.status == IssueStatus.resolved;

            return matchesZone && matchesCat && matchesStatus;
          }).toList();

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: const MapOptions(
                  initialCenter: _nagpurCenter,
                  initialZoom: 13.0,
                  minZoom: 5.0,
                  maxZoom: 18.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                    subdomains: const ['a', 'b', 'c', 'd'],
                    userAgentPackageName: 'com.example.nagardrishti',
                  ),

                  if (_showRedAlertRadii)
                    CircleLayer(
                      circles: filtered.where((i) => i.redAlert).map((issue) {
                        return CircleMarker(
                          point: ll.LatLng(issue.latitude, issue.longitude),
                          radius: 350,
                          useRadiusInMeter: true,
                          color: AppColors.redAlert.withValues(alpha: 0.22),
                          borderColor: AppColors.redAlert,
                          borderStrokeWidth: 2,
                        );
                      }).toList(),
                    ),

                  MarkerLayer(
                    markers: [
                      if (_userLocation != null)
                        Marker(
                          point: _userLocation!,
                          width: 44,
                          height: 44,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(width: 44, height: 44, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blueAccent.withValues(alpha: 0.25))),
                              Container(width: 18, height: 18, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blueAccent, border: Border.all(color: Colors.white, width: 2.5))),
                            ],
                          ),
                        ),

                      ...filtered.map((issue) {
                        Color markerColor = const Color(0xFF10B981);
                        if (issue.status == IssueStatus.reported) markerColor = AppColors.nagpurOrange;
                        if (issue.status == IssueStatus.inProgress) markerColor = Colors.purpleAccent;
                        if (issue.redAlert) markerColor = AppColors.redAlert;

                        return Marker(
                          point: ll.LatLng(issue.latitude, issue.longitude),
                          width: 130,
                          height: 55,
                          alignment: Alignment.topCenter,
                          child: GestureDetector(
                            onTap: () => _showAdminIssueModal(context, issue),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: markerColor,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [BoxShadow(color: markerColor.withValues(alpha: 0.4), blurRadius: 6)],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (issue.redAlert) const Icon(Icons.flash_on_rounded, color: Colors.white, size: 12),
                                      Text('${issue.trackingId} (${issue.reportCount})', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                                Icon(Icons.arrow_drop_down_rounded, color: markerColor, size: 20),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),

              // Filter Controls Bar
              Positioned(
                top: 12,
                left: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.darkSurface.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.darkCardBorder),
                  ),
                  child: SingleChildScrollView(
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
                          value: _selectedStatusFilter,
                          dropdownColor: AppColors.darkSurface,
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(value: 'ALL', child: Text('All Statuses', style: TextStyle(color: Colors.white, fontSize: 12))),
                            DropdownMenuItem(value: 'REPORTED', child: Text('Reported', style: TextStyle(color: Colors.white, fontSize: 12))),
                            DropdownMenuItem(value: 'IN_PROGRESS', child: Text('In Progress', style: TextStyle(color: Colors.white, fontSize: 12))),
                            DropdownMenuItem(value: 'RED_ALERT', child: Text('Red Alert', style: TextStyle(color: Colors.white, fontSize: 12))),
                            DropdownMenuItem(value: 'RESOLVED', child: Text('Resolved', style: TextStyle(color: Colors.white, fontSize: 12))),
                          ],
                          onChanged: (v) => setState(() => _selectedStatusFilter = v!),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Stats Summary
              Positioned(
                bottom: 16,
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
                      _buildMapStat('Visible Issues', '${filtered.length}', Colors.white),
                      _buildMapStat('Red Alerts', '${filtered.where((i) => i.redAlert).length}', AppColors.redAlert),
                      _buildMapStat('Active Work', '${filtered.where((i) => i.status == IssueStatus.inProgress).length}', Colors.purpleAccent),
                      _buildMapStat('Resolved', '${filtered.where((i) => i.status == IssueStatus.resolved).length}', const Color(0xFF10B981)),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMapStat(String label, String val, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(val, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 10)),
      ],
    );
  }

  void _showAdminIssueModal(BuildContext context, IssueModel issue) {
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
                    child: const Text('RED ALERT', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(issue.trackingId, style: const TextStyle(color: AppColors.nagpurOrange, fontWeight: FontWeight.bold, fontSize: 14)),
                const Spacer(),
                Text(issue.category, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 10),
            Text(issue.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text('📍 ${issue.address}', style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('👥 ${issue.reportCount} reports', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                Text('SLA: ${DateFormat('dd MMM, hh:mm a').format(issue.slaDeadline)}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
            const Divider(color: AppColors.darkCardBorder, height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.push('/issue/${issue.id}');
                  },
                  child: const Text('Full View', style: TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ref.read(adminActionControllerProvider.notifier).executeAdminAction(
                      issueId: issue.id,
                      actionType: 'ESCALATE_EMERGENCY',
                      details: 'Command Center Urgent Escalation',
                    );
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Escalated ${issue.trackingId} to Zone CSO')));
                  },
                  icon: const Icon(Icons.campaign, size: 14),
                  label: const Text('Escalate CSO', style: TextStyle(fontSize: 12)),
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
