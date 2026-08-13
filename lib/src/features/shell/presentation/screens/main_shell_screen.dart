import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_language_provider.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../map/presentation/screens/map_screen.dart';
import '../../../report/presentation/screens/report_screen.dart';
import '../../../leaderboard/presentation/screens/leaderboard_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

class MainShellScreen extends ConsumerStatefulWidget {
  const MainShellScreen({super.key});

  @override
  ConsumerState<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends ConsumerState<MainShellScreen> {
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
    final currentLang = ref.watch(appLanguageProvider);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 48,
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.location_city_rounded, color: AppColors.nagpurOrange, size: 20),
            const SizedBox(width: 6),
            Text(
              AppStrings.tr('appName', currentLang),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<AppLanguage>(
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.darkCardBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.language_rounded, size: 14, color: AppColors.nagpurOrange),
                  const SizedBox(width: 4),
                  Text(
                    currentLang.label,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
            color: AppColors.darkSurface,
            onSelected: (lang) {
              ref.read(appLanguageProvider.notifier).setLanguage(lang);
            },
            itemBuilder: (ctx) => AppLanguage.values
                .map((lang) => PopupMenuItem(
                      value: lang,
                      child: Text(lang.label, style: const TextStyle(fontSize: 13, color: Colors.white)),
                    ))
                .toList(),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_active_rounded, color: AppColors.nagpurOrange, size: 20),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🔔 FCM Notification Tray: 2 new updates in Ward 2 Dharampeth')),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.orangeGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.nagpurOrange.withValues(alpha: 0.5),
              blurRadius: 16,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              setState(() => _currentIndex = 2); // Open Report AI scan tab
            },
            child: const Icon(Icons.add_a_photo_rounded, size: 28, color: Colors.white),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: AppColors.darkSurface,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        elevation: 12,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.grid_view_rounded, 'Dashboard'),
              _buildNavItem(1, Icons.map_rounded, 'Live Map'),
              const SizedBox(width: 48), // FAB cutout clearance
              _buildNavItem(3, Icons.emoji_events_rounded, 'Rankings'),
              _buildNavItem(4, Icons.account_circle_rounded, 'Profile'),
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 3,
              width: isSelected ? 16 : 0,
              decoration: BoxDecoration(
                color: AppColors.nagpurOrange,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

