import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import '../../../../core/constants/app_colors.dart';
import '../../../report/data/location_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final LocationService _locationService = DeviceLocationService();
  String _selectedFilter = 'All Issues';
  ll.LatLng? _userLocation;
  bool _isLocating = false;

  final List<String> _filters = [
    'All Issues',
    'Red Alerts',
    'Active Work',
    'Resolved',
    'Potholes',
    'Drainage',
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
        _mapController.move(userLatLng, 15.0);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📍 Live GPS Centered: ${loc.address}'),
            backgroundColor: AppColors.nagpurOrange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (_) {
      setState(() => _isLocating = false);
    }
  }

  final List<Map<String, dynamic>> _allMapIssues = [
    {
      'id': 'doc_red_alert_1',
      'title': 'Major Sewer Water Leakage on Wardha Road',
      'category': 'Drainage & Sewage',
      'ward': 'Ward 4 - Dhantoli',
      'reports': 14,
      'isRedAlert': true,
      'status': 'Reported (Red Alert)',
      'color': AppColors.redAlert,
      'location': const ll.LatLng(21.1284, 79.0760),
    },
    {
      'id': 'doc_red_alert_2',
      'title': 'Dangerous Deep Pothole near Dharampeth Square',
      'category': 'Potholes & Roads',
      'ward': 'Ward 2 - Dharampeth',
      'reports': 11,
      'isRedAlert': true,
      'status': 'In Progress',
      'color': AppColors.inProgressStatus,
      'location': const ll.LatLng(21.1462, 79.0621),
    },
    {
      'id': 'active_work_1',
      'title': 'Municipal Road Resurfacing & Asphalt Repair',
      'category': 'Potholes & Roads',
      'ward': 'Ward 1 - Laxmi Nagar',
      'reports': 24,
      'isRedAlert': false,
      'status': 'Active Repair',
      'color': AppColors.inProgressStatus,
      'location': const ll.LatLng(21.1350, 79.0820),
    },
    {
      'id': 'resolved_1',
      'title': 'High Bay LED Streetlight Replacement',
      'category': 'Streetlights & Electrical',
      'ward': 'Ward 3 - Sitabuldi',
      'reports': 6,
      'isRedAlert': false,
      'status': 'Resolved (95% AI Verified)',
      'color': AppColors.resolvedStatus,
      'location': const ll.LatLng(21.1520, 79.0880),
    },
  ];

  List<Map<String, dynamic>> get _filteredIssues {
    if (_selectedFilter == 'All Issues') return _allMapIssues;
    if (_selectedFilter == 'Red Alerts') {
      return _allMapIssues.where((i) => i['isRedAlert'] == true).toList();
    }
    if (_selectedFilter == 'Active Work') {
      return _allMapIssues.where((i) => i['status'] == 'Active Repair' || i['status'] == 'In Progress').toList();
    }
    if (_selectedFilter == 'Resolved') {
      return _allMapIssues.where((i) => i['status'].toString().startsWith('Resolved')).toList();
    }
    if (_selectedFilter == 'Potholes') {
      return _allMapIssues.where((i) => i['category'].toString().contains('Potholes')).toList();
    }
    if (_selectedFilter == 'Drainage') {
      return _allMapIssues.where((i) => i['category'].toString().contains('Drainage')).toList();
    }
    return _allMapIssues;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.public_rounded, color: AppColors.nagpurOrange, size: 22),
            SizedBox(width: 10),
            Text('Nagpur Real World Map', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
      body: Stack(
        children: [
          // 100% Real World OpenStreetMap Engine
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: _nagpurCenter,
              initialZoom: 13.5,
              minZoom: 5.0,
              maxZoom: 18.0,
            ),
            children: [
              // Real World CartoDB / OpenStreetMap Dark Tile Layer
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.example.nagardrishti',
              ),

              // Ward Red Alert Heatmap Radius Circles
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: const ll.LatLng(21.1284, 79.0760),
                    radius: 350,
                    useRadiusInMeter: true,
                    color: AppColors.redAlert.withValues(alpha: 0.22),
                    borderColor: AppColors.redAlert,
                    borderStrokeWidth: 2,
                  ),
                  CircleMarker(
                    point: const ll.LatLng(21.1462, 79.0621),
                    radius: 250,
                    useRadiusInMeter: true,
                    color: AppColors.nagpurOrange.withValues(alpha: 0.2),
                    borderColor: AppColors.nagpurOrange,
                    borderStrokeWidth: 1.5,
                  ),
                ],
              ),

              // Real Interactive Marker Layer
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
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blueAccent.withValues(alpha: 0.6),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ..._filteredIssues.map((issue) {
                    final Color markerColor = issue['color'] as Color;
                    return Marker(
                      point: issue['location'] as ll.LatLng,
                      width: 140,
                      height: 60,
                      alignment: Alignment.topCenter,
                      child: GestureDetector(
                        onTap: () => _showIssueDetailModal(context, issue),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: markerColor,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: markerColor.withValues(alpha: 0.4),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (issue['isRedAlert'] == true) ...[
                                    const Icon(Icons.flash_on_rounded, color: Colors.white, size: 12),
                                    const SizedBox(width: 2),
                                  ],
                                  Flexible(
                                    child: Text(
                                      '${issue['ward'].toString().split("-").last} (${issue['reports']})',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_drop_down_rounded, color: markerColor, size: 22),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),


          // Top Filter Chips Bar
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
                      side: BorderSide(
                        color: isSelected ? AppColors.nagpurOrange : AppColors.darkCardBorder,
                      ),
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

          // Map Control Buttons (Zoom in / Zoom out)
          Positioned(
            right: 16,
            bottom: 110,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'zoom_in',
                  backgroundColor: AppColors.darkSurface,
                  foregroundColor: Colors.white,
                  onPressed: () {
                    final currentZoom = _mapController.camera.zoom;
                    _mapController.move(_mapController.camera.center, currentZoom + 1);
                  },
                  child: const Icon(Icons.add_rounded),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'zoom_out',
                  backgroundColor: AppColors.darkSurface,
                  foregroundColor: Colors.white,
                  onPressed: () {
                    final currentZoom = _mapController.camera.zoom;
                    _mapController.move(_mapController.camera.center, currentZoom - 1);
                  },
                  child: const Icon(Icons.remove_rounded),
                ),
              ],
            ),
          ),

          // Bottom Ward Quick Focus Overlay Card
          Positioned(
            bottom: 20,
            left: 16,
            right: 80,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.darkSurface.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.darkCardBorder, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: AppColors.redAlertGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.flash_on_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'Dhantoli Red Alert Hotspot',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '14 duplicate reports clustered in Ward 4',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondaryDark),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.center_focus_strong_rounded, color: AppColors.nagpurOrange, size: 22),
                    onPressed: () {
                      _mapController.move(const ll.LatLng(21.1284, 79.0760), 16.0);
                      _showIssueDetailModal(context, _allMapIssues.first);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showIssueDetailModal(BuildContext context, Map<String, dynamic> issue) {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: issue['color'],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    issue['status'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.white),
                  ),
                ),
                const Spacer(),
                Text(issue['ward'], style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryDark)),
              ],
            ),
            const SizedBox(height: 12),
            Text(issue['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
            const SizedBox(height: 6),
            Text('Category: ${issue['category']}', style: const TextStyle(fontSize: 13, color: AppColors.nagpurOrange, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.people_outline_rounded, size: 16, color: AppColors.textSecondaryDark),
                const SizedBox(width: 6),
                Text('${issue['reports']} Citizen Reports Clustered', style: const TextStyle(fontSize: 12, color: Colors.white)),
                const Spacer(),
                const Text('SLA Target: 24 Hours', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.resolvedStatus)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
