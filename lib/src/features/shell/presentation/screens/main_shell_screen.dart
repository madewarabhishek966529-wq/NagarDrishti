import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../map/presentation/screens/map_screen.dart';
import '../../../report/presentation/screens/report_screen.dart';
import '../../../leaderboard/presentation/screens/leaderboard_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    MapScreen(),
    ReportScreen(),
    LeaderboardScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() => _currentIndex = 2); // Center Report tab
        },
        backgroundColor: AppColors.nagpurOrange,
        elevation: 6,
        child: const Icon(Icons.add_a_photo_rounded, size: 28, color: Colors.white),
      ),
      bottomNavigationBar: BottomAppBar(
        color: AppColors.darkSurface,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        elevation: 10,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, 'Home'),
              _buildNavItem(1, Icons.map_rounded, 'Map'),
              const SizedBox(width: 40), // Spacing for FAB
              _buildNavItem(3, Icons.leaderboard_rounded, 'Rankings'),
              _buildNavItem(4, Icons.person_rounded, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AppColors.nagpurOrange : AppColors.textSecondaryDark;

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
