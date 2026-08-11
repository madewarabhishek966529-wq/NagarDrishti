import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../issues/domain/issue_model.dart';

class ReportConfirmationScreen extends StatelessWidget {
  final IssueModel issue;

  const ReportConfirmationScreen({super.key, required this.issue});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Confirmation'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Verified Badge Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.resolvedStatus.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.resolvedStatus, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.resolvedStatus.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(Icons.check_circle_rounded, size: 50, color: AppColors.resolvedStatus),
            ),
            const SizedBox(height: 16),

            const Text(
              'Official Report Created!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 6),
            const Text(
              'Your ticket has been written to Firestore and auto-routed to department admin',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
            ),
            const SizedBox(height: 24),

            // Tracking ID Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.nagpurOrange, width: 1.5),
              ),
              child: Column(
                children: [
                  const Text(
                    'OFFICIAL TICKET TRACKING ID',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondaryDark, letterSpacing: 1),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    issue.trackingId,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.nagpurOrange,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // AI Classification & Routing Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 18),
                        const SizedBox(width: 8),
                        const Text(
                          'Gemini AI Vision Classification',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.resolvedStatus.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${(issue.confidenceScore * 100).toInt()}% Match',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.resolvedStatus),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20, color: Color(0xFF334155)),
                    _buildDetailRow('Category', issue.category),
                    _buildDetailRow('Assigned Dept', issue.assignedDepartmentId),
                    _buildDetailRow('Location Ward', issue.ward),
                    _buildDetailRow('Severity', issue.severity.toValue().toUpperCase()),
                    _buildDetailRow('Status', issue.status.toValue()),
                    _buildDetailRow(
                      'SLA Resolution Target',
                      'Within ${issue.slaDeadline.difference(DateTime.now()).inHours} Hours',
                      isHighlight: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Action Buttons
            ElevatedButton.icon(
              onPressed: () {
                context.go('/');
              },
              icon: const Icon(Icons.home),
              label: const Text('Return to Home Feed', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.nagpurOrange,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryDark)),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isHighlight ? AppColors.nagpurOrange : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
