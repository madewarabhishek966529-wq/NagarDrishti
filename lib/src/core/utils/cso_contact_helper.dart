import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_constants.dart';
import '../../features/report/presentation/controllers/report_controller.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';

class CsoContactInfo {
  final String name;
  final String phone;
  final String designation;
  final String zoneId;
  final String zoneName;

  const CsoContactInfo({
    required this.name,
    required this.phone,
    required this.designation,
    required this.zoneId,
    required this.zoneName,
  });
}

class CsoContactHelper {
  static CsoContactInfo getCsoForWard(String ward) {
    final zoneId = AppConstants.wardToZoneIdMap[ward] ?? 'zone_04';
    final zoneName = AppConstants.zoneIdToNameMap[zoneId] ?? 'Dhantoli';
    final officerData = AppConstants.zoneCsoOfficersMap[zoneId] ?? {
      'name': 'Rajesh Gaidhani',
      'phone': '9823350242',
      'designation': 'Zonal Officer / CSO',
    };

    return CsoContactInfo(
      name: officerData['name']!,
      phone: officerData['phone']!,
      designation: officerData['designation']!,
      zoneId: zoneId,
      zoneName: zoneName,
    );
  }

  static CsoContactInfo getCsoForZone(String zoneId) {
    final zoneName = AppConstants.zoneIdToNameMap[zoneId] ?? 'Dhantoli';
    final officerData = AppConstants.zoneCsoOfficersMap[zoneId] ?? {
      'name': 'Rajesh Gaidhani',
      'phone': '9823350242',
      'designation': 'Zonal Officer / CSO',
    };

    return CsoContactInfo(
      name: officerData['name']!,
      phone: officerData['phone']!,
      designation: officerData['designation']!,
      zoneId: zoneId,
      zoneName: zoneName,
    );
  }

  static Future<void> initiateCsoCall({
    required BuildContext context,
    required WidgetRef ref,
    required String phoneNumber,
    required String officerName,
    String? issueId,
    String? trackingId,
    String? zoneName,
  }) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri telUri = Uri.parse('tel:$cleanPhone');

    final user = ref.read(authStateProvider).value;
    final citizenId = user?.uid ?? 'citizen_guest';

    // Record Call Audit Event in Issues Repository / Firestore
    try {
      await ref.read(issuesRepositoryProvider).recordCallEvent(
        issueId: issueId ?? 'DIRECT_LOOKUP',
        trackingId: trackingId ?? 'GENERAL_CSO',
        citizenId: citizenId,
        officerName: officerName,
        officerPhone: phoneNumber,
        action: 'CALL_OFFICER',
      );
    } catch (_) {}

    if (await canLaunchUrl(telUri)) {
      await launchUrl(telUri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dialing $phoneNumber ($officerName)...'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  static Future<void> initiateHelplineCall({
    required BuildContext context,
  }) async {
    final Uri telUri = Uri.parse('tel:18001208040');
    if (await canLaunchUrl(telUri)) {
      await launchUrl(telUri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dialing NMC Citizen Helpline 1800-120-8040...'),
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }
}
