import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/city_service_models.dart';

abstract class CityServicesRepository {
  Future<WasteCollectionStatus> fetchWasteCollectionStatus(String ward);
  Future<WaterSupplySchedule> fetchWaterSupplySchedule(String ward);
  Future<List<EmergencyHelplineItem>> fetchEmergencyHelplines();
  Future<List<MunicipalPaymentItem>> fetchMunicipalPayments();
}

class MockCityServicesRepository implements CityServicesRepository {
  @override
  Future<WasteCollectionStatus> fetchWasteCollectionStatus(String ward) async {
    return WasteCollectionStatus(
      ward: ward,
      area: ward.split('-').last.trim(),
      vehicleNumber: 'MH-31-CB-4892',
      driverName: 'Santosh Meshram',
      driverPhone: '9823351122',
      expectedTimeWindow: '08:30 AM – 09:45 AM',
      status: 'On Route',
    );
  }

  @override
  Future<WaterSupplySchedule> fetchWaterSupplySchedule(String ward) async {
    return WaterSupplySchedule(
      ward: ward,
      morningTimings: '06:00 AM – 08:30 AM',
      eveningTimings: '05:30 PM – 07:30 PM',
      tankerBookingPhone: '07122567000',
      status: 'Normal Supply',
    );
  }

  @override
  Future<List<EmergencyHelplineItem>> fetchEmergencyHelplines() async {
    return const [
      EmergencyHelplineItem(
        title: 'NMC Disaster Cell',
        department: 'Nagpur Municipal Corporation',
        phone: '07122567030',
        icon: Icons.cell_tower_rounded,
        color: Colors.redAccent,
        description: '24x7 City emergency response for floods, building collapse & storms',
      ),
      EmergencyHelplineItem(
        title: 'Fire Emergency',
        department: 'NMC Fire Brigade',
        phone: '101',
        icon: Icons.local_fire_department_rounded,
        color: Colors.deepOrange,
        description: 'Immediate fire rescue & hazard containment team',
      ),
      EmergencyHelplineItem(
        title: 'Ambulance & Medical',
        department: '108 Emergency Medical Response',
        phone: '108',
        icon: Icons.medical_services_rounded,
        color: Color(0xFF10B981),
        description: 'Free emergency ambulance & critical trauma response',
      ),
      EmergencyHelplineItem(
        title: 'Nagpur Police Control',
        department: 'Nagpur City Police',
        phone: '112',
        icon: Icons.local_police_rounded,
        color: Colors.blueAccent,
        description: 'City safety, traffic control & law enforcement response',
      ),
      EmergencyHelplineItem(
        title: 'Flood & Drainage Control',
        department: 'NMC Waterworks Cell',
        phone: '07122567035',
        icon: Icons.water_damage_rounded,
        color: Colors.cyan,
        description: 'Waterlogging, sewer overflow & canal breach emergency team',
      ),
      EmergencyHelplineItem(
        title: 'Women Safety Helpline',
        department: 'Maharashtra State Police',
        phone: '1091',
        icon: Icons.health_and_safety_rounded,
        color: Colors.pinkAccent,
        description: 'Dedicated 24x7 women security & rapid protection team',
      ),
    ];
  }

  @override
  Future<List<MunicipalPaymentItem>> fetchMunicipalPayments() async {
    return const [
      MunicipalPaymentItem(
        title: 'NMC Property Tax',
        category: 'Taxation',
        subtitle: 'Pay annual house & commercial property tax online',
        url: 'https://nmcnagpur.gov.in/property-tax',
        icon: Icons.home_work_rounded,
      ),
      MunicipalPaymentItem(
        title: 'Water Charges (OCW)',
        category: 'Water Utility',
        subtitle: 'Pay monthly meter water bill & view consumption history',
        url: 'https://ocwnagpur.com',
        icon: Icons.water_drop_rounded,
      ),
      MunicipalPaymentItem(
        title: 'Trade License Renewal',
        category: 'Commercial',
        subtitle: 'Apply or renew NMC commercial business license',
        url: 'https://nmcnagpur.gov.in/trade-license',
        icon: Icons.store_rounded,
      ),
      MunicipalPaymentItem(
        title: 'Building Plan Fee',
        category: 'Town Planning',
        subtitle: 'Pay construction sanction & layout approval fees',
        url: 'https://nmcnagpur.gov.in/building-permission',
        icon: Icons.architecture_rounded,
      ),
    ];
  }
}

final cityServicesRepositoryProvider = Provider<CityServicesRepository>((ref) {
  return MockCityServicesRepository();
});
