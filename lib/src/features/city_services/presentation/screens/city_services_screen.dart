import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/app_language_provider.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/city_services_repository.dart';
import '../../domain/city_service_models.dart';

class CityServicesScreen extends ConsumerStatefulWidget {
  const CityServicesScreen({super.key});

  @override
  ConsumerState<CityServicesScreen> createState() => _CityServicesScreenState();
}

class _CityServicesScreenState extends ConsumerState<CityServicesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _makeCall(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri telUri = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(telUri)) {
      await launchUrl(telUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dialing $phone...')),
        );
      }
    }
  }

  Future<void> _openWebUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Opening $url...')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;
    final currentLang = ref.watch(appLanguageProvider);
    final repo = ref.watch(cityServicesRepositoryProvider);
    final zoneId = user?.zoneId ?? 'zone_04';
    final zoneName = user?.zoneName ?? AppConstants.zoneIdToNameMap[zoneId] ?? 'Dhantoli';
    final currentWard = 'Ward – $zoneName';

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.miscellaneous_services_rounded, color: AppColors.nagpurOrange, size: 20),
                const SizedBox(width: 8),
                Text(
                  AppStrings.tr('cityServices', currentLang),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
                ),
              ],
            ),
            Text(
              'Zone ${zoneId.replaceAll("zone_", "")} – $zoneName • Municipal Directory',
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.nagpurOrange,
          labelColor: AppColors.nagpurOrange,
          unselectedLabelColor: AppColors.textSecondaryDark,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          tabs: const [
            Tab(icon: Icon(Icons.delete_outline_rounded, size: 18), text: 'Waste Collection'),
            Tab(icon: Icon(Icons.water_drop_outlined, size: 18), text: 'Water Supply'),
            Tab(icon: Icon(Icons.phone_in_talk_rounded, size: 18), text: 'Emergency SOS'),
            Tab(icon: Icon(Icons.account_balance_wallet_outlined, size: 18), text: 'NMC Payments'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWasteTrackerTab(repo, currentWard),
          _buildWaterSupplyTab(repo, currentWard),
          _buildEmergencyDirectoryTab(repo),
          _buildMunicipalPaymentsTab(repo),
        ],
      ),
    );
  }

  Widget _buildWasteTrackerTab(CityServicesRepository repo, String ward) {
    return FutureBuilder<WasteCollectionStatus>(
      future: repo.fetchWasteCollectionStatus(ward),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.nagpurOrange));
        }

        final waste = snapshot.data!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF065F46), Color(0xFF0F172A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.local_shipping_rounded, color: Color(0xFF10B981), size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'DOOR-TO-DOOR WASTE PICKUP',
                                style: TextStyle(fontSize: 11, color: Color(0xFF10B981), fontWeight: FontWeight.bold, letterSpacing: 0.8),
                              ),
                              Text(
                                waste.area,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF10B981)),
                          ),
                          child: Text(
                            waste.status,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: AppColors.darkCardBorder, height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Expected Pickup Window:', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
                        Text(waste.expectedTimeWindow, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Assigned Van Number:', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
                        Text(waste.vehicleNumber, style: const TextStyle(color: AppColors.nagpurOrange, fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Driver Contact Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.nagpurOrange.withValues(alpha: 0.2),
                        child: const Icon(Icons.person_rounded, color: AppColors.nagpurOrange),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(waste.driverName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            const SizedBox(height: 2),
                            const Text('NMC Sanitation Squad Driver', style: TextStyle(fontSize: 11, color: AppColors.textSecondaryDark)),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _makeCall(waste.driverPhone),
                        icon: const Icon(Icons.phone, size: 14),
                        label: const Text('Call Driver', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Segregation Guidelines Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Row(
                        children: [
                          Icon(Icons.recycling_rounded, color: Color(0xFF10B981), size: 20),
                          SizedBox(width: 8),
                          Text('NMC Waste Segregation Mandatory Rules', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text('• Green Bin: Wet kitchen waste & biodegradable matter.', style: TextStyle(fontSize: 12, color: Colors.white70)),
                      SizedBox(height: 4),
                      Text('• Blue Bin: Dry plastic, paper, cardboard & metal waste.', style: TextStyle(fontSize: 12, color: Colors.white70)),
                      SizedBox(height: 4),
                      Text('• Red Bin: E-waste, batteries & hazardous domestic items.', style: TextStyle(fontSize: 12, color: Colors.white70)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWaterSupplyTab(CityServicesRepository repo, String ward) {
    return FutureBuilder<WaterSupplySchedule>(
      future: repo.fetchWaterSupplySchedule(ward),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.nagpurOrange));
        }

        final water = snapshot.data!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF0F172A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.4), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.water_drop_rounded, color: Colors.lightBlueAccent, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'MUNICIPAL TAP WATER SCHEDULE',
                                style: TextStyle(fontSize: 11, color: Colors.lightBlueAccent, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                              ),
                              Text(
                                water.ward,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.blueAccent),
                          ),
                          child: Text(
                            water.status,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.lightBlueAccent),
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: AppColors.darkCardBorder, height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('🌅 Morning Supply Hours:', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
                        Text(water.morningTimings, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('🌆 Evening Supply Hours:', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
                        Text(water.eveningTimings, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Emergency Water Tanker Request Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.nagpurOrange, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.nagpurOrange.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.fire_truck_rounded, color: AppColors.nagpurOrange, size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Emergency Water Tanker Request', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                              Text('Request immediate NMC water tanker dispatch', style: TextStyle(fontSize: 11, color: AppColors.textSecondaryDark)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: () => _makeCall(water.tankerBookingPhone),
                      icon: const Icon(Icons.phone_forwarded_rounded, size: 18),
                      label: Text('Call Water Tanker Cell (${water.tankerBookingPhone})', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.nagpurOrange,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmergencyDirectoryTab(CityServicesRepository repo) {
    return FutureBuilder<List<EmergencyHelplineItem>>(
      future: repo.fetchEmergencyHelplines(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.nagpurOrange));
        }

        final helplines = snapshot.data!;

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: helplines.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, idx) {
            final item = helplines[idx];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: item.color.withValues(alpha: 0.4), width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item.icon, color: item.color, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                        const SizedBox(height: 2),
                        Text(item.department, style: TextStyle(fontSize: 11, color: item.color, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(item.description, style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _makeCall(item.phone),
                    icon: const Icon(Icons.phone, size: 14),
                    label: Text(item.phone, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: item.color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMunicipalPaymentsTab(CityServicesRepository repo) {
    return FutureBuilder<List<MunicipalPaymentItem>>(
      future: repo.fetchMunicipalPayments(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.nagpurOrange));
        }

        final payments = snapshot.data!;

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: payments.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, idx) {
            final item = payments[idx];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.darkCardBorder),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.nagpurOrange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item.icon, color: AppColors.nagpurOrange, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                        const SizedBox(height: 2),
                        Text(item.subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => _openWebUrl(item.url),
                    icon: const Icon(Icons.open_in_new_rounded, size: 14, color: AppColors.nagpurOrange),
                    label: const Text('Pay Online', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.nagpurOrange)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.nagpurOrange),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
