import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Civic Hero Leaderboard', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Hero Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.orangeGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.nagpurOrange.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.emoji_events_rounded, color: Colors.amberAccent, size: 40),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Nagpur Civic Hero League',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Earn reputation points when your AI reported issues get resolved!',
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Top 3 Podium Row
            const Text(
              'Top Verified Citizen Champions',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildPodiumTile(rank: 2, name: 'Priya D.', points: '245 Pts', badge: 'Silver', color: Colors.grey.shade400, height: 110),
                _buildPodiumTile(rank: 1, name: 'Aarav S.', points: '280 Pts', badge: 'Gold Champion', color: Colors.amber, height: 135),
                _buildPodiumTile(rank: 3, name: 'Rajesh K.', points: '210 Pts', badge: 'Bronze', color: const Color(0xFFCD7F32), height: 95),
              ],
            ),
            const SizedBox(height: 24),

            const Text(
              'Leaderboard Rankings',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _buildLeaderboardTile(1, 'Aarav Sharma', '280 Points', 'Pothole Hunter Badge', Colors.amber),
            const SizedBox(height: 10),
            _buildLeaderboardTile(2, 'Priya Deshmukh', '245 Points', 'Drainage Master Badge', Colors.grey.shade300),
            const SizedBox(height: 10),
            _buildLeaderboardTile(3, 'Rajesh Kulkarni', '210 Points', 'Verified Reporter Badge', const Color(0xFFCD7F32)),
            const SizedBox(height: 10),
            _buildLeaderboardTile(4, 'Siddharth Patil', '185 Points', 'Lighting Watchdog', AppColors.nagpurOrange),
            const SizedBox(height: 10),
            _buildLeaderboardTile(5, 'Neha Joshi', '160 Points', 'Active Citizen', AppColors.inProgressStatus),
          ],
        ),
      ),
    );
  }

  Widget _buildPodiumTile({
    required int rank,
    required String name,
    required String points,
    required String badge,
    required Color color,
    required double height,
  }) {
    return Column(
      children: [
        CircleAvatar(
          radius: rank == 1 ? 26 : 22,
          backgroundColor: color,
          child: Text(
            '#$rank',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 13),
          ),
        ),
        const SizedBox(height: 6),
        Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        Text(points, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 8),
        Container(
          width: 90,
          height: height,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            border: Border.all(color: color, width: 1.5),
          ),
          child: Center(
            child: Icon(
              rank == 1 ? Icons.workspace_premium_rounded : Icons.star_rounded,
              color: color,
              size: rank == 1 ? 32 : 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardTile(int rank, String name, String points, String badge, Color badgeColor) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.darkCardBorder),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: badgeColor, width: 1.5),
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
