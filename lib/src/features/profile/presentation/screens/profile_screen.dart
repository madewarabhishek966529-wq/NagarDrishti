import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/domain/app_user.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final isDeptAdmin = user?.role == UserRole.deptAdmin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Citizen Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.redAlert),
            onPressed: () {
              ref.read(authControllerProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 12),
            CircleAvatar(
              radius: 44,
              backgroundColor: isDeptAdmin ? const Color(0xFF2563EB) : AppColors.nagpurOrange,
              child: Text(
                (user?.displayName.isNotEmpty == true) ? user!.displayName[0].toUpperCase() : 'N',
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              user?.displayName ?? 'Nagpur Citizen',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? user?.phoneNumber ?? '',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryDark),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isDeptAdmin ? const Color(0xFF1E3A8A) : AppColors.nagpurOrange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDeptAdmin ? const Color(0xFF3B82F6) : AppColors.nagpurOrange,
                ),
              ),
              child: Text(
                isDeptAdmin ? 'DEPARTMENT OFFICER (${user?.departmentId})' : 'VERIFIED CITIZEN',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDeptAdmin ? Colors.white : AppColors.nagpurOrange,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Profile Options Card
            Card(
              child: Column(
                children: [
                  if (isDeptAdmin) ...[
                    ListTile(
                      leading: const Icon(Icons.dashboard_outlined, color: AppColors.nagpurOrange),
                      title: const Text('Department Admin Dashboard'),
                      subtitle: const Text('Manage SLA alerts, ticket queue & status transitions'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/admin'),
                    ),
                    const Divider(height: 1, color: Color(0xFF334155)),
                  ],
                  ListTile(
                    leading: const Icon(Icons.verified_outlined, color: AppColors.resolvedStatus),
                    title: const Text('Public Transparency Feed'),
                    subtitle: const Text('View verified before/after resolutions'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/public-feed'),
                  ),
                  const Divider(height: 1, color: Color(0xFF334155)),
                  ListTile(
                    leading: const Icon(Icons.engineering_outlined, color: AppColors.inProgressStatus),
                    title: const Text('Public Active Work Layer'),
                    subtitle: const Text('Track ongoing municipal repair work sites'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/active-work'),
                  ),
                  const Divider(height: 1, color: Color(0xFF334155)),
                  ListTile(
                    leading: const Icon(Icons.badge_outlined, color: AppColors.nagpurOrange),
                    title: const Text('My Badges & Rewards'),
                    subtitle: Text('${user?.badges.length ?? 2} badges unlocked'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  const Divider(height: 1, color: Color(0xFF334155)),
                  ListTile(
                    leading: const Icon(Icons.swap_horiz, color: AppColors.nagpurOrange),
                    title: const Text('Switch Role (Demo Portal)'),
                    subtitle: const Text('Toggle between Citizen and Department Admin'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      ref.read(authControllerProvider.notifier).logout();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
