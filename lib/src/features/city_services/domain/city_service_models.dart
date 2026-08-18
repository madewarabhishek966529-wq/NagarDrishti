import 'package:flutter/material.dart';

class WasteCollectionStatus {
  final String ward;
  final String area;
  final String vehicleNumber;
  final String driverName;
  final String driverPhone;
  final String expectedTimeWindow;
  final String status; // 'On Route', 'Completed', 'Upcoming'

  const WasteCollectionStatus({
    required this.ward,
    required this.area,
    required this.vehicleNumber,
    required this.driverName,
    required this.driverPhone,
    required this.expectedTimeWindow,
    required this.status,
  });
}

class WaterSupplySchedule {
  final String ward;
  final String morningTimings;
  final String eveningTimings;
  final String tankerBookingPhone;
  final String status; // 'Normal Supply', 'Low Pressure', 'Interrupted'

  const WaterSupplySchedule({
    required this.ward,
    required this.morningTimings,
    required this.eveningTimings,
    required this.tankerBookingPhone,
    required this.status,
  });
}

class EmergencyHelplineItem {
  final String title;
  final String department;
  final String phone;
  final IconData icon;
  final Color color;
  final String description;

  const EmergencyHelplineItem({
    required this.title,
    required this.department,
    required this.phone,
    required this.icon,
    required this.color,
    required this.description,
  });
}

class MunicipalPaymentItem {
  final String title;
  final String category;
  final String subtitle;
  final String url;
  final IconData icon;

  const MunicipalPaymentItem({
    required this.title,
    required this.category,
    required this.subtitle,
    required this.url,
    required this.icon,
  });
}
