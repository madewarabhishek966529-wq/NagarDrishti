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
}
