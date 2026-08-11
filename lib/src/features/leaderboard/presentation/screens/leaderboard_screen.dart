import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nagpur Citizen Leaderboard'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Banner Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.nagpurOrangeDark, AppColors.nagpurOrange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events, color: Colors.amberAccent, size: 48),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Civic Hero League',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Earn points when reported issues get confirmed and resolved!',
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Top Verified Citizen Reporters',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _buildLeaderboardTile(1, 'Aarav Sharma', '280 Points', 'Pothole Hunter Badge', Colors.amber),
            const SizedBox(height: 8),
            _buildLeaderboardTile(2, 'Priya Deshmukh', '245 Points', 'Drainage Master Badge', Colors.grey.shade300),
            const SizedBox(height: 8),
            _buildLeaderboardTile(3, 'Rajesh Kulkarni', '210 Points', 'Verified Reporter Badge', Colors.brown.shade300),
            const SizedBox(height: 8),
            _buildLeaderboardTile(4, 'Siddharth Patil', '185 Points', 'Lighting Watchdog', Colors.blueGrey),
            const SizedBox(height: 8),
            _buildLeaderboardTile(5, 'Neha Joshi', '160 Points', 'Active Citizen', Colors.blueGrey),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardTile(int rank, String name, String points, String badge, Color badgeColor) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: badgeColor),
              ),
              child: Center(
                child: Text(
                  '#$rank',
                  style: TextStyle(fontWeight: FontWeight.bold, color: badgeColor, fontSize: 13),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(badge, style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark)),
                ],
              ),
            ),
            Text(
              points,
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.nagpurOrange, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
