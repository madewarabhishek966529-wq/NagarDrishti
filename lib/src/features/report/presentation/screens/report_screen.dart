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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.nagpurOrange),
              title: const Text('Capture with Camera'),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(reportControllerProvider.notifier).captureImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.nagpurOrange),
              title: const Text('Select from Gallery'),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(reportControllerProvider.notifier).captureImage(ImageSource.gallery);
              },
            ),
          ],
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
        title: const Text('New AI Civic Report'),
        actions: [
          IconButton(
            icon: Icon(
              reportState.isListeningVoice ? Icons.mic : Icons.mic_none_outlined,
              color: reportState.isListeningVoice ? AppColors.redAlert : AppColors.nagpurOrange,
            ),
            onPressed: () {
              ref.read(reportControllerProvider.notifier).toggleVoiceNote();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
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
            // Image Capture Container
            GestureDetector(
              onTap: () => _showImageSourcePicker(context),
              child: Container(
                height: 210,
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: reportState.aiResult != null
                        ? AppColors.resolvedStatus
                        : AppColors.nagpurOrange,
                    width: 2,
                  ),
                ),
                child: reportState.isAnalyzingImage
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          CircularProgressIndicator(color: AppColors.nagpurOrange),
                          SizedBox(height: 16),
                          Text(
                            'Gemini Vision AI Scanning Photo...',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Classifying issue type, severity & department routing',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
                          ),
                        ],
                      )
                    : reportState.imageBytes != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(14),
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
                                      padding: const EdgeInsets.all(12),
                                      color: Colors.black87,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 16),
                                              const SizedBox(width: 6),
                                              Text(
                                                'AI Category: ${reportState.aiResult!.category}',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                                              ),
                                              const Spacer(),
                                              Text(
                                                '${(reportState.aiResult!.confidenceScore * 100).toInt()}% Match',
                                                style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.resolvedStatus),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Severity: ${reportState.aiResult!.severity.toValue().toUpperCase()}',
                                            style: const TextStyle(fontSize: 11, color: AppColors.nagpurOrange),
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
                            children: const [
                              Icon(Icons.camera_alt_outlined, size: 54, color: AppColors.nagpurOrange),
                              SizedBox(height: 12),
                              Text(
                                'Tap to Capture Photo with Gemini AI',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Auto GPS location & instant issue classification',
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
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.my_location, color: AppColors.nagpurOrange, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            reportState.location != null
                                ? 'GPS: ${reportState.location!.address}'
                                : 'Location (Auto GPS)',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (reportState.isFetchingLocation)
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.nagpurOrange),
                          )
                        else
                          IconButton(
                            icon: const Icon(Icons.gps_fixed, size: 18, color: AppColors.nagpurOrange),
                            onPressed: () {
                              ref.read(reportControllerProvider.notifier).fetchLocation();
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: reportState.selectedWard,
                      decoration: const InputDecoration(
                        labelText: 'Nagpur Ward / Zone',
                      ),
                      dropdownColor: AppColors.darkSurface,
                      items: AppConstants.nagpurWards
                          .map((w) => DropdownMenuItem(value: w, child: Text(w)))
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

            // Issue Category Dropdown
            DropdownButtonFormField<String>(
              initialValue: reportState.selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Issue Category',
                prefixIcon: Icon(Icons.category_outlined, color: AppColors.textSecondaryDark),
              ),
              dropdownColor: AppColors.darkSurface,
              items: AppConstants.categoryToDepartmentMap.keys
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  ref.read(reportControllerProvider.notifier).updateCategory(val);
                }
              },
            ),
            const SizedBox(height: 12),

            // Routed Department & SLA Preview
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.alt_route, color: AppColors.nagpurOrange, size: 18),
                  const SizedBox(width: 10),
                  const Text('Routed Dept:', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark)),
                  const SizedBox(width: 6),
                  Text(
                    AppConstants.categoryToDepartmentMap[reportState.selectedCategory] ?? 'DEPT_ROADS',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                  ),
                  const Spacer(),
                  Text(
                    'SLA: ${AppConstants.categorySlaHours[reportState.selectedCategory] ?? 48}h Target',
                    style: const TextStyle(fontSize: 11, color: AppColors.nagpurOrange, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Voice Note / Custom Description
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: reportState.voiceDescription.isNotEmpty
                    ? 'Voice Note: ${reportState.voiceDescription}'
                    : 'Add extra details or tap top mic icon for voice note...',
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
                        nav.push(
                          MaterialPageRoute(
                            builder: (ctx) => ReportConfirmationScreen(issue: issue),
                          ),
                        );
                      }
                    },
              icon: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.send_rounded),
              label: Text(
                isSubmitting ? 'Writing to Firestore...' : 'Submit Official Report',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.nagpurOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
