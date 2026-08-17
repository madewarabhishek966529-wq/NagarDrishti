import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nagardrishti/src/core/constants/app_colors.dart';
import 'package:nagardrishti/src/features/issues/domain/issue_model.dart';
import '../controllers/cso_controller.dart';

class CsoActionDialog extends ConsumerStatefulWidget {
  final IssueModel issue;
  final String zoneId;
  final String initialAction;

  const CsoActionDialog({
    super.key,
    required this.issue,
    required this.zoneId,
    this.initialAction = 'ACCEPT',
  });

  @override
  ConsumerState<CsoActionDialog> createState() => _CsoActionDialogState();
}

class _CsoActionDialogState extends ConsumerState<CsoActionDialog> {
  late String _selectedAction;
  final _detailsController = TextEditingController();
  final _evidenceUrlController = TextEditingController();
  String _selectedWorker = 'Contractor Squad 1 (Roads)';
  String _selectedDept = 'DEPT_ROADS';

  final List<String> _fieldSquads = [
    'Contractor Squad 1 (Roads)',
    'Emergency Waterlogging Response Unit',
    'Streetlight Maintenance Team A',
    'Sanitation Fast Action Team',
    'Special Zonal Inspection Taskforce',
  ];

  @override
  void initState() {
    super.initState();
    _selectedAction = widget.initialAction;
    _selectedDept = widget.issue.assignedDepartmentId;
  }

  @override
  void dispose() {
    _detailsController.dispose();
    _evidenceUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(csoActionControllerProvider);
    final isLoading = actionState.isLoading;

    return Dialog(
      backgroundColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.security, color: Color(0xFF10B981), size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CSO Zonal Action',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        'Ticket: ${widget.issue.trackingId}',
                        style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(color: AppColors.darkCardBorder, height: 24),

            // Action Selection Dropdown
            DropdownButtonFormField<String>(
              initialValue: _selectedAction,
              decoration: const InputDecoration(
                labelText: 'Action Type',
                prefixIcon: Icon(Icons.flash_on_rounded, color: AppColors.nagpurOrange),
              ),
              dropdownColor: AppColors.darkSurface,
              items: const [
                DropdownMenuItem(value: 'ACCEPT', child: Text('Accept Complaint & Confirm', style: TextStyle(color: Colors.white, fontSize: 13))),
                DropdownMenuItem(value: 'ASSIGN_SQUAD', child: Text('Assign Field Squad', style: TextStyle(color: Colors.white, fontSize: 13))),
                DropdownMenuItem(value: 'IN_PROGRESS', child: Text('Mark In Progress', style: TextStyle(color: Colors.white, fontSize: 13))),
                DropdownMenuItem(value: 'ADD_NOTE', child: Text('Add Internal Officer Note', style: TextStyle(color: Colors.white, fontSize: 13))),
                DropdownMenuItem(value: 'ESCALATE', child: Text('🚨 Escalate to RED ALERT', style: TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold))),
                DropdownMenuItem(value: 'REQUEST_INSPECTION', child: Text('Request Site Inspection', style: TextStyle(color: Colors.white, fontSize: 13))),
                DropdownMenuItem(value: 'REQUEST_VALIDATION', child: Text('Request Citizen Validation', style: TextStyle(color: Colors.white, fontSize: 13))),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedAction = val);
              },
            ),
            const SizedBox(height: 14),

            if (_selectedAction == 'ASSIGN_SQUAD') ...[
              DropdownButtonFormField<String>(
                initialValue: _selectedWorker,
                decoration: const InputDecoration(
                  labelText: 'Select Field Repair Squad',
                  prefixIcon: Icon(Icons.groups_outlined, color: AppColors.textSecondaryDark),
                ),
                dropdownColor: AppColors.darkSurface,
                items: _fieldSquads.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(color: Colors.white, fontSize: 13)))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedWorker = val);
                },
              ),
              const SizedBox(height: 14),
            ],

            TextFormField(
              controller: _detailsController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Officer Action Remarks / Instructions',
                hintText: _selectedAction == 'ESCALATE'
                    ? 'State escalation rationale for zone emergency...'
                    : 'Enter instructions for field squad or internal audit note...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 14),

            TextFormField(
              controller: _evidenceUrlController,
              decoration: const InputDecoration(
                labelText: 'Inspection Photo / Evidence URL (Optional)',
                prefixIcon: Icon(Icons.link, color: AppColors.textSecondaryDark),
                hintText: 'https://...',
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      final details = _detailsController.text.trim().isNotEmpty
                          ? _detailsController.text.trim()
                          : 'Action executed by CSO Officer';
                      final evidence = _evidenceUrlController.text.trim().isNotEmpty ? _evidenceUrlController.text.trim() : null;

                      await ref.read(csoActionControllerProvider.notifier).executeAction(
                            issueId: widget.issue.id,
                            actionType: _selectedAction,
                            details: details,
                            evidenceUrl: evidence,
                            assignedWorker: _selectedWorker,
                            assignedDepartment: _selectedDept,
                            zoneId: widget.zoneId,
                          );

                      if (context.mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('CSO Action "$_selectedAction" executed successfully for ${widget.issue.trackingId}'),
                            backgroundColor: const Color(0xFF10B981),
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedAction == 'ESCALATE' ? AppColors.redAlert : const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text('Confirm Action', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }
}
