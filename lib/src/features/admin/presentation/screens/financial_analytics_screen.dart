import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nagardrishti/src/core/constants/app_colors.dart';
import '../controllers/admin_command_center_controller.dart';

class FinancialAnalyticsScreen extends ConsumerWidget {
  const FinancialAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final finAsync = ref.watch(financialAnalyticsProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('NMC City Financial Analytics & Budget', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('Repair expenditure, zonal spend & contractor budget tracking', style: TextStyle(fontSize: 11, color: AppColors.textSecondaryDark)),
          ],
        ),
      ),
      body: finAsync.when(
        data: (fin) {
          final spentPercentage = (fin.actualExpenditure / fin.allocatedBudget * 100).clamp(0.0, 100.0);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Budget Summary Banner
                Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.darkCardGradient,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.nagpurOrange.withValues(alpha: 0.4)),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Municipal Civic Budget Summary (2026)', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Allocated: ₹${(fin.allocatedBudget / 100000).toStringAsFixed(2)} Lakh', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('Spent: ${(spentPercentage).toStringAsFixed(1)}%', style: const TextStyle(color: Colors.amber, fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 12),

                      LinearProgressIndicator(
                        value: spentPercentage / 100,
                        backgroundColor: AppColors.darkCard,
                        color: spentPercentage > 85 ? AppColors.redAlert : const Color(0xFF10B981),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildBudgetStat('Est. Total Repair', '₹${(fin.estimatedTotalRepairCost / 1000).toStringAsFixed(1)}k', Colors.white),
                          _buildBudgetStat('Actual Expenditure', '₹${(fin.actualExpenditure / 1000).toStringAsFixed(1)}k', Colors.amber),
                          _buildBudgetStat('Remaining Budget', '₹${(fin.remainingBudget / 100000).toStringAsFixed(2)}L', const Color(0xFF10B981)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Department-wise Expenditure
                const Text('Department Expenditure Breakdown', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                ...fin.departmentWiseExpenditure.entries.map((e) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.darkSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.darkCardBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(e.key, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('₹${(e.value / 1000).toStringAsFixed(1)}k', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 24),

                // Contractor Expenditure
                const Text('Contractor Expenditure Audit', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                ...fin.contractorWiseExpenditure.entries.map((e) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.darkSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.darkCardBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(e.key, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('₹${(e.value / 1000).toStringAsFixed(1)}k', style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.nagpurOrange)),
        error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: AppColors.redAlert))),
      ),
    );
  }

  Widget _buildBudgetStat(String label, String val, Color col) {
    return Column(
      children: [
        Text(val, style: TextStyle(color: col, fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 10)),
      ],
    );
  }
}
