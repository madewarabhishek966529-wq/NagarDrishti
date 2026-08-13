import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../issues/domain/issue_model.dart';
import '../../../../core/utils/demo_seed_data.dart';

class PublicFeedScreen extends StatelessWidget {
  const PublicFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final resolvedIssues = DemoSeedData.getInitialIssues()
        .where((i) => i.status == IssueStatus.resolved)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Public Transparency Feed', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.successGradient,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.resolvedStatus.withValues(alpha: 0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.verified_rounded, color: Colors.white, size: 36),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Nagpur Smart City Transparency Hub',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Verified before/after resolutions audited by Gemini Vision AI.',
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
              'Recently Resolved Civic Issues',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),

            ...resolvedIssues.map((issue) => _buildResolvedCard(context, issue)),
          ],
        ),
      ),
    );
  }

  Widget _buildResolvedCard(BuildContext context, IssueModel issue) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.darkCardBorder),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.resolvedStatus.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.resolvedStatus),
                      const SizedBox(width: 4),
                      Text(
                        'RESOLVED (${issue.trackingId})',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.resolvedStatus),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(issue.ward, style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark)),
              ],
            ),
            const SizedBox(height: 12),
            Text(issue.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 4),
            Text(issue.description, style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryDark)),
            const SizedBox(height: 16),

            // Side-by-side Before/After Photo Cards
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        height: 115,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.redAlert, width: 2),
                          image: DecorationImage(
                            image: NetworkImage(issue.imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text('BEFORE (Reported)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.redAlert)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        height: 115,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.resolvedStatus, width: 2),
                          image: DecorationImage(
                            image: NetworkImage(issue.afterImageUrl ?? issue.imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text('AFTER (Gemini Verified)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.resolvedStatus)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.darkBackground,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.darkCardBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded, color: Colors.amber, size: 18),
                  const SizedBox(width: 8),
                  const Text('AI Fix Audit:', style: TextStyle(fontSize: 11, color: AppColors.textSecondaryDark)),
                  const SizedBox(width: 4),
                  const Text('95% Quality Score', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.resolvedStatus)),
                  const Spacer(),
                  Text('Dept: ${issue.assignedDepartmentId}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.nagpurOrange)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
