import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/ai_classification_service.dart';
import '../../data/location_service.dart';
import '../../data/speech_service.dart';
import '../../../issues/data/issues_repository.dart';
import '../../../issues/data/duplicate_detection_service.dart';
import '../../../notifications/data/notification_service.dart';
import '../../../issues/domain/issue_model.dart';
import '../../../../core/constants/app_constants.dart';

final aiClassificationServiceProvider = Provider<AiClassificationService>((ref) {
  return GeminiVisionClassificationService();
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return DeviceLocationService();
});

final speechServiceProvider = Provider<SpeechService>((ref) {
  return SpeechToTextService();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return FcmNotificationService();
});

final duplicateDetectionServiceProvider = Provider<DuplicateDetectionService>((ref) {
  return HaversineDuplicateDetectionService();
});

final issuesRepositoryProvider = Provider<IssuesRepository>((ref) {
  return FirestoreIssuesRepository();
});

class ReportState {
  final Uint8List? imageBytes;
  final String? imagePath;
  final bool isAnalyzingImage;
  final AiClassificationResult? aiResult;
  final LocationResult? location;
  final bool isFetchingLocation;
  final String selectedCategory;
  final String selectedWard;
  final String voiceDescription;
  final bool isListeningVoice;
  final bool isSubmitting;
  final IssueModel? submittedIssue;
  final String? errorMessage;

  const ReportState({
    this.imageBytes,
    this.imagePath,
    this.isAnalyzingImage = false,
    this.aiResult,
    this.location,
    this.isFetchingLocation = false,
    this.selectedCategory = 'Pothole & Roads',
    this.selectedWard = 'Ward 1 - Laxmi Nagar',
    this.voiceDescription = '',
    this.isListeningVoice = false,
    this.isSubmitting = false,
    this.submittedIssue,
    this.errorMessage,
  });

  ReportState copyWith({
    Uint8List? imageBytes,
    String? imagePath,
    bool? isAnalyzingImage,
    AiClassificationResult? aiResult,
    LocationResult? location,
    bool? isFetchingLocation,
    String? selectedCategory,
    String? selectedWard,
    String? voiceDescription,
    bool? isListeningVoice,
    bool? isSubmitting,
    IssueModel? submittedIssue,
    String? errorMessage,
  }) {
    return ReportState(
      imageBytes: imageBytes ?? this.imageBytes,
      imagePath: imagePath ?? this.imagePath,
      isAnalyzingImage: isAnalyzingImage ?? this.isAnalyzingImage,
      aiResult: aiResult ?? this.aiResult,
      location: location ?? this.location,
      isFetchingLocation: isFetchingLocation ?? this.isFetchingLocation,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedWard: selectedWard ?? this.selectedWard,
      voiceDescription: voiceDescription ?? this.voiceDescription,
      isListeningVoice: isListeningVoice ?? this.isListeningVoice,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submittedIssue: submittedIssue ?? this.submittedIssue,
      errorMessage: errorMessage,
    );
  }
}

class ReportController extends StateNotifier<ReportState> {
  final AiClassificationService aiService;
  final LocationService locationService;
  final SpeechService speechService;
  final IssuesRepository issuesRepository;
  final DuplicateDetectionService duplicateService;
  final NotificationService notificationService;

  ReportController({
    required this.aiService,
    required this.locationService,
    required this.speechService,
    required this.issuesRepository,
    required this.duplicateService,
    required this.notificationService,
  }) : super(const ReportState());

  Future<void> captureImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final picked = await picker.pickImage(source: source, imageQuality: 85);
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        state = state.copyWith(
          imageBytes: bytes,
          imagePath: picked.path,
          isAnalyzingImage: true,
        );

        if (state.location == null) {
          fetchLocation();
        }

        final aiResult = await aiService.classifyIssueImage(bytes);
        state = state.copyWith(
          isAnalyzingImage: false,
          aiResult: aiResult,
          selectedCategory: aiResult.category,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isAnalyzingImage: false,
        errorMessage: 'Image pick failed: $e',
      );
    }
  }

  Future<void> fetchLocation() async {
    state = state.copyWith(isFetchingLocation: true);
    final loc = await locationService.getCurrentLocation();
    state = state.copyWith(
      isFetchingLocation: false,
      location: loc,
      selectedWard: loc.ward,
    );
  }

  void updateCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  void updateWard(String ward) {
    state = state.copyWith(selectedWard: ward);
  }

  Future<void> toggleVoiceNote() async {
    if (state.isListeningVoice) {
      await speechService.stopListening();
      state = state.copyWith(isListeningVoice: false);
    } else {
      state = state.copyWith(isListeningVoice: true);
      await speechService.startListening(
        onResult: (text) {
          state = state.copyWith(
            voiceDescription: text,
            isListeningVoice: false,
          );
        },
      );
    }
  }

  Future<IssueModel?> submitReport({
    required String customDescription,
    required String userId,
  }) async {
    state = state.copyWith(isSubmitting: true);
    try {
      final issueId = 'doc_${DateTime.now().millisecondsSinceEpoch}';
      final trackingNum = (DateTime.now().millisecondsSinceEpoch % 10000).toString().padLeft(4, '0');
      final trackingId = 'NAG-$trackingNum';

      final deptCode = AppConstants.categoryToDepartmentMap[state.selectedCategory] ?? 'DEPT_ROADS';
      final slaHours = AppConstants.categorySlaHours[state.selectedCategory] ?? 48;

      final description = customDescription.isNotEmpty
          ? customDescription
          : (state.voiceDescription.isNotEmpty
              ? state.voiceDescription
              : (state.aiResult?.summary ?? 'Civic issue report captured via Nagardrishti AI.'));

      final newIssue = IssueModel(
        id: issueId,
        trackingId: trackingId,
        title: '${state.selectedCategory} near ${state.location?.address.split(',').first ?? "Road"}',
        description: description,
        category: state.selectedCategory,
        subCategory: state.aiResult?.subCategory ?? '',
        severity: state.aiResult?.severity ?? IssueSeverity.medium,
        confidenceScore: state.aiResult?.confidenceScore ?? 0.88,
        imageUrl: state.imagePath ?? 'https://images.unsplash.com/photo-1515162816999-a0c47dc192f7',
        latitude: state.location?.latitude ?? 21.1458,
        longitude: state.location?.longitude ?? 79.0882,
        address: state.location?.address ?? 'Wardha Road, Nagpur',
        ward: state.selectedWard,
        status: IssueStatus.reported,
        createdBy: userId,
        assignedDepartmentId: deptCode,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        slaDeadline: DateTime.now().add(Duration(hours: slaHours)),
      );

      final saved = await issuesRepository.processNewIssueWithClustering(
        newIssue,
        duplicateService,
        notificationService,
      );

      state = state.copyWith(
        isSubmitting: false,
        submittedIssue: saved,
      );
      return saved;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Submission failed: $e',
      );
      return null;
    }
  }

  void reset() {
    state = const ReportState();
  }
}

final reportControllerProvider = StateNotifierProvider<ReportController, ReportState>((ref) {
  return ReportController(
    aiService: ref.watch(aiClassificationServiceProvider),
    locationService: ref.watch(locationServiceProvider),
    speechService: ref.watch(speechServiceProvider),
    issuesRepository: ref.watch(issuesRepositoryProvider),
    duplicateService: ref.watch(duplicateDetectionServiceProvider),
    notificationService: ref.watch(notificationServiceProvider),
  );
});
