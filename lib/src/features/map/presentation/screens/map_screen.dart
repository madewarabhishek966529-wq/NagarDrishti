import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String _selectedFilter = 'All Issues';

  final List<String> _filters = [
    'All Issues',
    'Red Alerts',
    'Active Work',
    'Resolved',
    'Potholes',
    'Drainage',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Smart City Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.layers_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map Placeholder Container (Interactive map in Phase 6)
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFF0F172A),
            child: Stack(
              children: [
                // Stylized Grid/Map background placeholder
                Opacity(
                  opacity: 0.15,
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6),
                    itemBuilder: (context, index) => Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white24, width: 0.5),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.nagpurOrange.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.nagpurOrange, width: 2),
                        ),
                        child: const Icon(Icons.map_rounded, size: 54, color: AppColors.nagpurOrange),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Nagpur Live Heatmap & Geofence Cluster',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Showing ward issue density, red alerts & active work zones',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
                      ),
                    ],
                  ),
                ),

                // Simulated Map Pins
                Positioned(
                  top: 180,
                  left: 120,
                  child: _buildMapPin('RED ALERT', AppColors.redAlert, '14 Reports'),
                ),
                Positioned(
                  top: 320,
                  right: 90,
                  child: _buildMapPin('Active Work', AppColors.inProgressStatus, 'Road Repair'),
                ),
                Positioned(
                  bottom: 220,
                  left: 80,
                  child: _buildMapPin('Pothole', AppColors.nagpurOrange, 'Ward 2'),
                ),
              ],
            ),
          ),

          // Top Filter Chips Bar
          Positioned(
            top: 12,
            left: 12,
            right: 12,
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
                      backgroundColor: AppColors.darkSurface,
                      side: const BorderSide(color: Color(0xFF334155)),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textSecondaryDark,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Bottom Quick Card Overlay
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Card(
              color: AppColors.darkSurface.withValues(alpha: 0.95),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.redAlert.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.error, color: AppColors.redAlert),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'Ward 4 - Dhantoli (Cluster Focus)',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            '14 nearby duplicate reports auto-grouped into 1 ticket',
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondaryDark),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondaryDark),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPin(String label, Color color, String sub) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 10, spreadRadius: 2),
            ],
          ),
          child: Column(
            children: [
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              Text(sub, style: const TextStyle(color: Colors.white70, fontSize: 9)),
            ],
          ),
        ),
        Icon(Icons.arrow_drop_down, color: color, size: 24),
      ],
    );
  }
}
