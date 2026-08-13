import 'package:flutter/material.dart';

class AppColors {
  // Brand Primary & Accent
  static const Color nagpurOrange = Color(0xFFFF6B00);
  static const Color nagpurOrangeLight = Color(0xFFFF8C38);
  static const Color nagpurOrangeDark = Color(0xFFD95A00);
  static const Color nagpurGlow = Color(0x66FF6B00);

  // Backgrounds & Surface (Ultra Premium Deep Slate)
  static const Color darkBackground = Color(0xFF0B0F19);
  static const Color darkSurface = Color(0xFF141C2B);
  static const Color darkCard = Color(0xFF1E2A3E);
  static const Color darkCardBorder = Color(0xFF2E3E58);

  static const Color lightBackground = Color(0xFFF6F8FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFEEF2F6);

  // Status & Priority Colors
  static const Color redAlert = Color(0xFFFF3B30);
  static const Color critical = Color(0xFFDC2626);
  static const Color highSeverity = Color(0xFFFF9500);
  static const Color mediumSeverity = Color(0xFFFFCC00);
  static const Color lowSeverity = Color(0xFF34C759);

  static const Color reportedStatus = Color(0xFF8E8E93);
  static const Color acknowledgedStatus = Color(0xFF007AFF);
  static const Color inProgressStatus = Color(0xFFFF9500);
  static const Color resolvedStatus = Color(0xFF34C759);

  // Text
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);

  // Gradients
  static const LinearGradient orangeGradient = LinearGradient(
    colors: [Color(0xFFFF6B00), Color(0xFFFF8C38)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF1A2436), Color(0xFF121927)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient redAlertGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFF991B1B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF047857)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient blueGradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
