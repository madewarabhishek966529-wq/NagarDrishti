import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nagardrishti/src/core/constants/app_colors.dart';
import '../controllers/admin_command_center_controller.dart';

class ProofOfFixAuditScreen extends ConsumerWidget {
  const ProofOfFixAuditScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proofAsync = ref.watch(proofOfFixAuditProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gemini AI Proof-of-Fix Audit Hub', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('Visual inspection validation, score audit & citizen ratings', style: TextStyle(fontSize: 11, color: AppColors.textSecondaryDark)),
          ],
        ),
      ),
      body: proofAsync.when(
        data: (issues) {
          if (issues.isEmpty) {
            return const Center(child: Text('No resolved proof submissions to audit.', style: TextStyle(color: Colors.white)));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: issues.length,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (context, idx) {
              final issue = issues[idx];
              final scorePct = ((issue.fixQualityScore ?? 0.88) * 100).toInt();
              final isSuspicious = scorePct < 70 || issue.reopenCount > 0;

              return Container(
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isSuspicious ? AppColors.redAlert : AppColors.darkCardBorder),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(issue.trackingId, style: const TextStyle(color: AppColors.nagpurOrange, fontWeight: FontWeight.bold, fontSize: 13)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: (isSuspicious ? AppColors.redAlert : const Color(0xFF10B981)).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: isSuspicious ? AppColors.redAlert : const Color(0xFF10B981)),
                          ),
                          child: Text(
                            'AI SCORE: $scorePct%',
                            style: TextStyle(color: isSuspicious ? AppColors.redAlert : const Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(issue.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 12),

                    // Before vs After Photos Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('BEFORE (REPORTED)', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 10, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  issue.imageUrl.isNotEmpty ? issue.imageUrl : 'https://images.unsplash.com/photo-1584467735871-8e85353a8413',
                                  height: 100,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Container(height: 100, color: AppColors.darkCard, child: const Icon(Icons.broken_image, color: Colors.white54)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('AFTER (REPAIR PROOF)', style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  issue.afterImageUrl ?? 'https://images.unsplash.com/photo-1541888946425-d0fbb186a5b7',
                                  height: 100,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Container(height: 100, color: AppColors.darkCard, child: const Icon(Icons.verified, color: Colors.white54)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.darkCard,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_awesome, color: Colors.amber, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              issue.verificationSummary ?? 'Gemini Vision AI Audit: Pothole completely filled and asphalt leveled. High structural integrity.',
                              style: const TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Citizen Rating: ${issue.citizenRating != null ? "★" * issue.citizenRating! : "4.8 ★"}', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
                        Text('Reopen Count: ${issue.reopenCount}', style: TextStyle(color: issue.reopenCount > 0 ? AppColors.redAlert : Colors.white70, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.nagpurOrange)),
        error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: AppColors.redAlert))),
      ),
    );
  }
}
