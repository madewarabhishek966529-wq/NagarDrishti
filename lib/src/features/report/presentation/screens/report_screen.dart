import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/report_controller.dart';
import 'report_confirmation_screen.dart';

class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _showImageSourcePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Wrap(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.nagpurOrange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: AppColors.nagpurOrange),
                ),
                title: const Text('Capture with Camera', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Instantly scan civic issue with Gemini Vision AI'),
                onTap: () {
                  Navigator.pop(ctx);
                  ref.read(reportControllerProvider.notifier).captureImage(ImageSource.camera);
                },
              ),
              const Divider(height: 1, color: AppColors.darkCardBorder),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.nagpurOrange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: AppColors.nagpurOrange),
                ),
                title: const Text('Select from Gallery', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Upload existing photo from device storage'),
                onTap: () {
                  Navigator.pop(ctx);
                  ref.read(reportControllerProvider.notifier).captureImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reportState = ref.watch(reportControllerProvider);
    final user = ref.watch(authStateProvider).value;
    final isSubmitting = reportState.isSubmitting;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New AI Civic Report', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(
              reportState.isListeningVoice ? Icons.mic_rounded : Icons.mic_none_rounded,
              color: reportState.isListeningVoice ? AppColors.redAlert : AppColors.nagpurOrange,
            ),
            onPressed: () {
              ref.read(reportControllerProvider.notifier).toggleVoiceNote();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              _descriptionController.clear();
              ref.read(reportControllerProvider.notifier).reset();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Photo Scanner Container
            GestureDetector(
              onTap: () => _showImageSourcePicker(context),
              child: Container(
                height: 220,
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: reportState.aiResult != null
                        ? AppColors.resolvedStatus
                        : AppColors.nagpurOrange,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.nagpurOrange.withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: reportState.isAnalyzingImage
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          CircularProgressIndicator(color: AppColors.nagpurOrange),
                          SizedBox(height: 16),
                          Text(
                            'Gemini Vision AI Scanning Photo...',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Extracting category, severity & department routing',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
                          ),
                        ],
                      )
                    : reportState.imageBytes != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.memory(
                                  reportState.imageBytes!,
                                  fit: BoxFit.cover,
                                ),
                                if (reportState.aiResult != null)
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(14),
                                      color: Colors.black87,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.auto_awesome, color: Colors.amber, size: 18),
                                              const SizedBox(width: 6),
                                              Text(
                                                'AI Category: ${reportState.aiResult!.category}',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                                              ),
                                              const Spacer(),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: AppColors.resolvedStatus.withValues(alpha: 0.2),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  '${(reportState.aiResult!.confidenceScore * 100).toInt()}% Match',
                                                  style: const TextStyle(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.bold,
                                                      color: AppColors.resolvedStatus),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Severity: ${reportState.aiResult!.severity.toValue().toUpperCase()}',
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.nagpurOrange),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.nagpurOrange.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.add_a_photo_rounded, size: 44, color: AppColors.nagpurOrange),
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                'Tap to Capture Photo with Gemini AI',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Auto GPS location & instant AI classification',
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
                              ),
                            ],
                          ),
              ),
            ),
            const SizedBox(height: 20),

            // Location & Ward Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.my_location_rounded, color: AppColors.nagpurOrange, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            reportState.location != null
                                ? 'GPS: ${reportState.location!.address}'
                                : 'Auto GPS Location Resolution',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (reportState.isFetchingLocation)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.nagpurOrange),
                          )
                        else
                          IconButton(
                            icon: const Icon(Icons.gps_fixed_rounded, size: 20, color: AppColors.nagpurOrange),
                            onPressed: () {
                              ref.read(reportControllerProvider.notifier).fetchLocation();
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: reportState.selectedWard,
                      decoration: const InputDecoration(
                        labelText: 'Nagpur Ward / Zone',
                      ),
                      dropdownColor: AppColors.darkSurface,
                      items: AppConstants.nagpurWards
                          .map((w) => DropdownMenuItem(value: w, child: Text(w, style: const TextStyle(fontSize: 13))))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          ref.read(reportControllerProvider.notifier).updateWard(val);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Category Selector
            DropdownButtonFormField<String>(
              initialValue: reportState.selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Issue Category',
                prefixIcon: Icon(Icons.category_rounded, color: AppColors.textSecondaryDark),
              ),
              dropdownColor: AppColors.darkSurface,
              items: AppConstants.categoryToDepartmentMap.keys
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat, style: const TextStyle(fontSize: 13))))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  ref.read(reportControllerProvider.notifier).updateCategory(val);
                }
              },
            ),
            const SizedBox(height: 14),

            // Routed Department Preview
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.darkCardBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.alt_route_rounded, color: AppColors.nagpurOrange, size: 20),
                  const SizedBox(width: 10),
                  const Text('Routed Dept:', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark)),
                  const SizedBox(width: 6),
                  Text(
                    AppConstants.categoryToDepartmentMap[reportState.selectedCategory] ?? 'DEPT_ROADS',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.nagpurOrange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'SLA: ${AppConstants.categorySlaHours[reportState.selectedCategory] ?? 48}h Target',
                      style: const TextStyle(fontSize: 11, color: AppColors.nagpurOrange, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // SOS Emergency Hazard Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: reportState.isSosEmergency
                    ? AppColors.redAlert.withValues(alpha: 0.15)
                    : AppColors.darkSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: reportState.isSosEmergency ? AppColors.redAlert : AppColors.darkCardBorder,
                  width: reportState.isSosEmergency ? 2 : 1,
                ),
              ),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeTrackColor: AppColors.redAlert,
                activeThumbColor: Colors.white,
                title: Row(
                  children: const [
                    Icon(Icons.warning_amber_rounded, color: AppColors.redAlert),
                    SizedBox(width: 8),
                    Text(
                      '🚨 SOS Critical Hazard',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.redAlert),
                    ),
                  ],
                ),
                subtitle: const Text(
                  'Immediate 4-hour SLA emergency escalation for severe public risks (open manholes, live wires)',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondaryDark),
                ),
                value: reportState.isSosEmergency,
                onChanged: (_) {
                  ref.read(reportControllerProvider.notifier).toggleSosEmergency();
                },
              ),
            ),
            const SizedBox(height: 16),

            // Description / Voice Note input
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: reportState.voiceDescription.isNotEmpty
                    ? 'Voice Note: ${reportState.voiceDescription}'
                    : 'Add extra landmark details or tap top mic icon for voice note...',
                labelText: 'Description / Voice Note',
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton.icon(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      final nav = Navigator.of(context);
                      final userId = user?.uid ?? 'guest_user';
                      final issue = await ref.read(reportControllerProvider.notifier).submitReport(
                            customDescription: _descriptionController.text.trim(),
                            userId: userId,
                          );
                      if (issue != null) {
                        _descriptionController.clear();
                        ref.read(reportControllerProvider.notifier).reset();
                        nav.push(
                          MaterialPageRoute(
                            builder: (ctx) => ReportConfirmationScreen(issue: issue),
                          ),
                        );
                      }
                    },
              icon: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.send_rounded),
              label: Text(
                isSubmitting
                    ? 'Writing to Firestore...'
                    : (reportState.isSosEmergency ? '⚡ Submit Emergency SOS Alert' : 'Submit Official Report'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: reportState.isSosEmergency ? AppColors.redAlert : AppColors.nagpurOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 4,
              ),
            ),

          ],
        ),
      ),
    );
  }
}
