import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nagardrishti/src/core/constants/app_colors.dart';
import 'package:nagardrishti/src/core/constants/app_constants.dart';
import '../controllers/admin_command_center_controller.dart';
import '../../domain/admin_command_center_models.dart';

class CsoManagementScreen extends ConsumerStatefulWidget {
  const CsoManagementScreen({super.key});

  @override
  ConsumerState<CsoManagementScreen> createState() => _CsoManagementScreenState();
}

class _CsoManagementScreenState extends ConsumerState<CsoManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final csosAsync = ref.watch(csoManagementProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('NMC CSO Officer Management', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('Zonal officer roster, active status & zone assignment', style: TextStyle(fontSize: 11, color: AppColors.textSecondaryDark)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded, color: Color(0xFF10B981)),
            tooltip: 'Create New CSO',
            onPressed: () => _showCreateCsoModal(context),
          ),
        ],
      ),
      body: csosAsync.when(
        data: (csos) {
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: csos.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, idx) {
              final cso = csos[idx];

              return Container(
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cso.active ? AppColors.darkCardBorder : AppColors.redAlert.withValues(alpha: 0.5)),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.2),
                          child: Text(cso.name.isNotEmpty ? cso.name[0] : 'C', style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(cso.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: (cso.active ? const Color(0xFF10B981) : AppColors.redAlert).withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: cso.active ? const Color(0xFF10B981) : AppColors.redAlert),
                                    ),
                                    child: Text(cso.active ? 'ACTIVE' : 'DEACTIVATED', style: TextStyle(color: cso.active ? const Color(0xFF10B981) : AppColors.redAlert, fontSize: 9, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                              Text('Assigned Zone: Zone ${cso.zoneId.replaceAll("zone_", "")} (${cso.zoneName})', style: const TextStyle(color: AppColors.nagpurOrange, fontSize: 12, fontWeight: FontWeight.w600)),
                              Text('📞 ${cso.phone} • ✉️ ${cso.email}', style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 11)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildCsoStat('Assigned', '${cso.assignedComplaints}', Colors.white),
                        _buildCsoStat('Critical', '${cso.criticalComplaints}', Colors.redAccent),
                        _buildCsoStat('Resolved', '${cso.resolvedComplaints}', const Color(0xFF10B981)),
                        _buildCsoStat('Overdue', '${cso.overdueComplaints}', AppColors.redAlert),
                        _buildCsoStat('SLA Rate', '${cso.slaCompliancePercentage.toStringAsFixed(1)}%', const Color(0xFF38BDF8)),
                      ],
                    ),
                    const Divider(color: AppColors.darkCardBorder, height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            ref.read(adminActionControllerProvider.notifier).updateCsoActiveStatus(cso.uid, !cso.active);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${cso.name} ${cso.active ? "deactivated" : "activated"} successfully')));
                          },
                          icon: Icon(cso.active ? Icons.block : Icons.check_circle, size: 14),
                          label: Text(cso.active ? 'Deactivate' : 'Activate', style: const TextStyle(fontSize: 11)),
                          style: OutlinedButton.styleFrom(foregroundColor: cso.active ? AppColors.redAlert : const Color(0xFF10B981)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Access credential reset email sent to ${cso.email}')));
                          },
                          icon: const Icon(Icons.key, size: 14),
                          label: const Text('Reset Access', style: TextStyle(fontSize: 11)),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
                        ),
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

  Widget _buildCsoStat(String label, String val, Color col) {
    return Column(
      children: [
        Text(val, style: TextStyle(color: col, fontWeight: FontWeight.bold, fontSize: 13)),
        Text(label, style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 10)),
      ],
    );
  }

  void _showCreateCsoModal(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    String selectedZone = 'zone_04';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Add New CSO Zonal Officer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
            const SizedBox(height: 14),
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Officer Full Name')),
            const SizedBox(height: 10),
            TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone Number')),
            const SizedBox(height: 10),
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Government Email')),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: selectedZone,
              decoration: const InputDecoration(labelText: 'Assign NMC Zone'),
              dropdownColor: AppColors.darkSurface,
              items: AppConstants.zoneIdToNameMap.entries
                  .map((e) => DropdownMenuItem(value: e.key, child: Text('${e.key.replaceAll("zone_", "Zone ")} — ${e.value}', style: const TextStyle(color: Colors.white, fontSize: 13))))
                  .toList(),
              onChanged: (v) => selectedZone = v!,
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                final newCso = CsoOfficerDetail(
                  uid: 'cso_${DateTime.now().millisecondsSinceEpoch}',
                  name: nameCtrl.text.trim(),
                  phone: phoneCtrl.text.trim().isNotEmpty ? phoneCtrl.text.trim() : '9823350242',
                  email: emailCtrl.text.trim().isNotEmpty ? emailCtrl.text.trim() : 'cso@nagpur.gov.in',
                  zoneId: selectedZone,
                  zoneName: AppConstants.zoneIdToNameMap[selectedZone] ?? 'NMC Zone',
                  active: true,
                  assignedComplaints: 0,
                  criticalComplaints: 0,
                  resolvedComplaints: 0,
                  overdueComplaints: 0,
                  slaCompliancePercentage: 100.0,
                  averageResolutionTimeHours: 0,
                );

                ref.read(adminActionControllerProvider.notifier).createNewCso(newCso);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('CSO ${newCso.name} added successfully for ${newCso.zoneName}')));
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
              child: const Text('Create & Assign CSO', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
