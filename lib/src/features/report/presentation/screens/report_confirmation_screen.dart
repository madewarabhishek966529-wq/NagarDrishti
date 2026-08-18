import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nagardrishti/src/core/constants/app_colors.dart';
import 'package:nagardrishti/src/core/constants/app_constants.dart';
import 'package:nagardrishti/src/core/utils/app_language_provider.dart';
import 'package:nagardrishti/src/core/utils/cso_contact_helper.dart';
import 'package:nagardrishti/src/features/issues/domain/issue_model.dart';

class ReportConfirmationScreen extends ConsumerWidget {
  final IssueModel issue;

  const ReportConfirmationScreen({super.key, required this.issue});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(appLanguageProvider);
    final csoInfo = CsoContactHelper.getCsoForWard(issue.ward);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('Complaint Submitted'),
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.darkSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 8),
            // Verified Badge Icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF10B981), width: 2),
              ),
              child: const Icon(Icons.check_circle_rounded, size: 44, color: Color(0xFF10B981)),
            ),
            const SizedBox(height: 14),

            const Text(
              'Complaint Submitted!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 4),
            const Text(
              'Your civic complaint has been registered & assigned to the Zonal CSO.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
            ),
            const SizedBox(height: 20),

            // Tracking ID Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.nagpurOrange, width: 1.5),
              ),
              child: Column(
                children: [
                  const Text(
                    'COMPLAINT TRACKING ID',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondaryDark, letterSpacing: 1),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    issue.trackingId,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColors.nagpurOrange,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // RESPONSIBLE NMC CSO OFFICER CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF10B981), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.badge_rounded, color: Color(0xFF10B981), size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.tr('responsibleOfficer', currentLang),
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              csoInfo.name,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            Text(
                              '${csoInfo.designation} • ${csoInfo.zoneName}',
                              style: const TextStyle(fontSize: 12, color: AppColors.nagpurOrange, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: AppColors.darkCardBorder, height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Zone Assignment:', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
                      Text('Zone ${csoInfo.zoneId.replaceAll("zone_", "")} – ${csoInfo.zoneName}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Direct CSO Phone:', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
                      Text('📞 ${csoInfo.phone}', style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Call Zonal Officer Button
                  ElevatedButton.icon(
                    onPressed: () {
                      CsoContactHelper.initiateCsoCall(
                        context: context,
                        ref: ref,
                        phoneNumber: csoInfo.phone,
                        officerName: csoInfo.name,
                        issueId: issue.id,
                        trackingId: issue.trackingId,
                        zoneName: csoInfo.zoneName,
                      );
                    },
                    icon: const Icon(Icons.phone_forwarded_rounded, size: 20),
                    label: Text(
                      '${AppStrings.tr("callOfficer", currentLang)} (${csoInfo.phone})',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Issue Summary Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Issue Category', issue.category),
                    _buildDetailRow('Assigned Department', issue.assignedDepartmentId.replaceAll("DEPT_", "")),
                    _buildDetailRow('Ward / Location', issue.ward),
                    _buildDetailRow('SLA Resolution Target', 'Within ${issue.slaDeadline.difference(DateTime.now()).inHours} Hours', isHighlight: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Central Helpline Card
            OutlinedButton.icon(
              onPressed: () => CsoContactHelper.initiateHelplineCall(context: context),
              icon: const Icon(Icons.headset_mic_rounded, color: Colors.white70, size: 18),
              label: Text(
                '${AppStrings.tr("helpline", currentLang)}: ${AppConstants.nmcCitizenHelpline}',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.darkCardBorder),
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),

            // Return Home
            ElevatedButton.icon(
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
                context.go('/');
              },
              icon: const Icon(Icons.home_rounded),
              label: const Text('Return to Citizen Dashboard', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.nagpurOrange,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
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
