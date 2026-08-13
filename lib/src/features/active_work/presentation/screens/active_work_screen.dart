import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/active_work_repository.dart';
import '../../domain/active_work_model.dart';

final activeWorkRepositoryProvider = Provider<ActiveWorkRepository>((ref) {
  return FirestoreActiveWorkRepository();
});

class ActiveWorkScreen extends ConsumerStatefulWidget {
  const ActiveWorkScreen({super.key});

  @override
  ConsumerState<ActiveWorkScreen> createState() => _ActiveWorkScreenState();
}

class _ActiveWorkScreenState extends ConsumerState<ActiveWorkScreen> {
  @override
  Widget build(BuildContext context) {
    final activeWorkRepo = ref.watch(activeWorkRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nagpur Active Work Layer'),
      ),
      body: FutureBuilder<List<ActiveWorkModel>>(
        future: activeWorkRepo.fetchActiveWorks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.nagpurOrange));
          }

          final works = snapshot.data ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.inProgressStatus.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.inProgressStatus, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.engineering, color: AppColors.inProgressStatus, size: 36),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Municipal Active Repair Works',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Live work sites currently being serviced by city departments.',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                ...works.map((work) => _buildWorkCard(work)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWorkCard(ActiveWorkModel work) {
    final daysRemaining = work.expectedCompletionDate.difference(DateTime.now()).inDays;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Chip(
                  backgroundColor: AppColors.inProgressStatus.withValues(alpha: 0.2),
                  side: BorderSide.none,
                  label: Text(
                    work.departmentName,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.inProgressStatus),
                  ),
                ),
                const Spacer(),
                Text(work.ward, style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark)),
              ],
            ),
            const SizedBox(height: 8),
            Text(work.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(work.description, style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryDark)),
            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(Icons.schedule, size: 16, color: AppColors.nagpurOrange),
                const SizedBox(width: 6),
                Text(
                  'Expected completion: $daysRemaining days target',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.nagpurOrange),
                ),
              ],
            ),
            const Divider(height: 20, color: Color(0xFF334155)),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    ref.read(activeWorkRepositoryProvider).upvoteActiveWork(work.id);
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Work confirmed by citizen! (+1 Upvote)')));
                  },
                  icon: const Icon(Icons.thumb_up_alt_outlined, size: 16, color: AppColors.resolvedStatus),
                  label: Text('Confirm Work (${work.upvotesCount})', style: const TextStyle(color: Colors.white, fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.resolvedStatus),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    ref.read(activeWorkRepositoryProvider).flagStalledWork(work.id);
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Flagged work as stalled.')));
                  },
                  icon: const Icon(Icons.flag_outlined, size: 16, color: AppColors.redAlert),
                  label: Text('Flag Stalled (${work.flaggedStalledCount})', style: const TextStyle(color: AppColors.redAlert, fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
