import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

abstract class NotificationService {
  Future<void> initialize();
  Future<void> sendRedAlertPushNotification({
    required String departmentId,
    required String ward,
    required String trackingId,
    required int reportCount,
  });
  Future<void> notifyCitizensEscalated({
    required String trackingId,
    required int reportCount,
  });
  Future<void> notifyCsoRedAlert({
    required String zoneId,
    required String trackingId,
    required String category,
    required int reportCount,
  });
  Future<void> notifyCsoSlaBreached({
    required String zoneId,
    required String trackingId,
    required String category,
  });
  Future<void> notifyCsoSosEmergency({
    required String zoneId,
    required String trackingId,
    required String title,
  });
  Future<void> notifyCsoReopenedIssue({
    required String zoneId,
    required String trackingId,
    required String citizenFeedback,
  });
}

class FcmNotificationService implements NotificationService {
  final FirebaseMessaging? _customMessaging;

  FcmNotificationService({FirebaseMessaging? messaging})
      : _customMessaging = messaging;

  FirebaseMessaging? get _messaging {
    if (_customMessaging != null) return _customMessaging;
    try {
      return FirebaseMessaging.instance;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> initialize() async {
    final msg = _messaging;
    if (msg != null) {
      try {
        await msg.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
      } catch (_) {}
    }
  }

  @override
  Future<void> sendRedAlertPushNotification({
    required String departmentId,
    required String ward,
    required String trackingId,
    required int reportCount,
  }) async {
    debugPrint(
      '🚨 [FCM PUSH -> DEPT ADMIN ($departmentId)]: CRITICAL RED ALERT! Ticket $trackingId in $ward has reached $reportCount citizen reports!',
    );
  }

  @override
  Future<void> notifyCitizensEscalated({
    required String trackingId,
    required int reportCount,
  }) async {
    debugPrint(
      '🔔 [FCM PUSH -> CITIZENS]: Your reported issue ($trackingId) has been escalated to RED ALERT! $reportCount people confirmed this.',
    );
  }

  @override
  Future<void> notifyCsoRedAlert({
    required String zoneId,
    required String trackingId,
    required String category,
    required int reportCount,
  }) async {
    debugPrint(
      '🚨 [FCM PUSH -> CSO OFFICER ($zoneId)]: RED ALERT! $category issue ($trackingId) reached $reportCount citizen reports in your zone.',
    );
  }

  @override
  Future<void> notifyCsoSlaBreached({
    required String zoneId,
    required String trackingId,
    required String category,
  }) async {
    debugPrint(
      '⚠️ [FCM PUSH -> CSO OFFICER ($zoneId)]: SLA BREACH! $category ticket $trackingId has breached resolution window.',
    );
  }

  @override
  Future<void> notifyCsoSosEmergency({
    required String zoneId,
    required String trackingId,
    required String title,
  }) async {
    debugPrint(
      '⚡ [FCM PUSH -> CSO OFFICER ($zoneId)]: 4-HR SOS CRITICAL HAZARD! $title ($trackingId) requires immediate dispatch.',
    );
  }

  @override
  Future<void> notifyCsoReopenedIssue({
    required String zoneId,
    required String trackingId,
    required String citizenFeedback,
  }) async {
    debugPrint(
      '🔄 [FCM PUSH -> CSO OFFICER ($zoneId)]: REOPENED TICKET! Citizen reopened $trackingId: "$citizenFeedback".',
    );
  }
}

