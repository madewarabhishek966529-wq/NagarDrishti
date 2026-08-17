import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _citizenFormKey = GlobalKey<FormState>();
  final _csoFormKey = GlobalKey<FormState>();
  final _adminFormKey = GlobalKey<FormState>();

  final _emailPhoneController = TextEditingController(text: 'citizen@nagpur.gov.in');
  final _citizenPasswordController = TextEditingController(text: 'nagpur123');

  final _csoEmailController = TextEditingController(text: 'cso.dhantoli@nagpur.gov.in');
  final _csoPasswordController = TextEditingController(text: 'cso123');
  String _selectedZoneId = 'zone_04';

  final _adminEmailController = TextEditingController(text: 'admin.roads@nagpur.gov.in');
  final _adminPasswordController = TextEditingController(text: 'admin123');
  String _selectedDepartment = 'DEPT_ROADS';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailPhoneController.dispose();
    _citizenPasswordController.dispose();
    _csoEmailController.dispose();
    _csoPasswordController.dispose();
    _adminEmailController.dispose();
    _adminPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0B0F19), Color(0xFF141C2B), Color(0xFF090D15)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Brand Logo Hero
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: AppColors.orangeGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.nagpurOrange.withValues(alpha: 0.4),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.location_city_rounded,
                      size: 42,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    AppConstants.appName,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'AI Civic Reporter & Smart City Governance',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondaryDark,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),

                  // Glassmorphic Card Container
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.darkSurface.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.darkCardBorder, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Segmented Triple Tab Pill
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.darkBackground,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.darkCardBorder),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: TabBar(
                            controller: _tabController,
                            indicator: BoxDecoration(
                              gradient: AppColors.orangeGradient,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.nagpurOrange.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            indicatorSize: TabBarIndicatorSize.tab,
                            labelColor: Colors.white,
                            unselectedLabelColor: AppColors.textSecondaryDark,
                            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                            dividerColor: Colors.transparent,
                            tabs: const [
                              Tab(text: 'Citizen'),
                              Tab(text: 'CSO Officer'),
                              Tab(text: 'Dept Admin'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Form Tab Content
                        SizedBox(
                          height: 350,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              // Citizen Login Form
                              Form(
                                key: _citizenFormKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    TextFormField(
                                      controller: _emailPhoneController,
                                      decoration: const InputDecoration(
                                        labelText: 'Mobile Number or Email',
                                        prefixIcon: Icon(Icons.person_outline_rounded, color: AppColors.textSecondaryDark),
                                      ),
                                      validator: (v) => (v == null || v.isEmpty) ? 'Required field' : null,
                                    ),
                                    const SizedBox(height: 14),
                                    TextFormField(
                                      controller: _citizenPasswordController,
                                      obscureText: true,
                                      decoration: const InputDecoration(
                                        labelText: 'Password or OTP',
                                        prefixIcon: Icon(Icons.lock_outline_rounded, color: AppColors.textSecondaryDark),
                                      ),
                                      validator: (v) => (v == null || v.isEmpty) ? 'Required field' : null,
                                    ),
                                    const SizedBox(height: 20),
                                    ElevatedButton(
                                      onPressed: isLoading
                                          ? null
                                          : () {
                                              if (_citizenFormKey.currentState!.validate()) {
                                                final input = _emailPhoneController.text.trim();
                                                if (input.contains('@')) {
                                                  ref.read(authControllerProvider.notifier).loginCitizenEmail(
                                                        input,
                                                        _citizenPasswordController.text.trim(),
                                                      );
                                                } else {
                                                  ref.read(authControllerProvider.notifier).loginCitizenPhone(
                                                        input,
                                                        _citizenPasswordController.text.trim(),
                                                      );
                                                }
                                              }
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.nagpurOrange,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        elevation: 4,
                                      ),
                                      child: isLoading
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                            )
                                          : const Text(
                                              'Login as Citizen',
                                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                            ),
                                    ),
                                    const SizedBox(height: 12),
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        ref.read(authControllerProvider.notifier).loginCitizenPhone('+91 9876543210', '123456');
                                      },
                                      icon: const Icon(Icons.bolt_rounded, color: AppColors.nagpurOrange),
                                      label: const Text('Quick Citizen Demo Pass', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: AppColors.nagpurOrange),
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // CSO / Zonal Officer Login Form
                              Form(
                                key: _csoFormKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    DropdownButtonFormField<String>(
                                      initialValue: _selectedZoneId,
                                      decoration: const InputDecoration(
                                        labelText: 'Select Assigned Zone',
                                        prefixIcon: Icon(Icons.map_outlined, color: AppColors.textSecondaryDark),
                                      ),
                                      dropdownColor: AppColors.darkSurface,
                                      items: AppConstants.zoneIdToNameMap.entries
                                          .map((e) => DropdownMenuItem(
                                                value: e.key,
                                                child: Text(
                                                  '${e.key.replaceAll("zone_", "Zone ")} — ${e.value}',
                                                  style: const TextStyle(fontSize: 13, color: Colors.white),
                                                ),
                                              ))
                                          .toList(),
                                      onChanged: (val) {
                                        if (val != null) setState(() => _selectedZoneId = val);
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    TextFormField(
                                      controller: _csoEmailController,
                                      decoration: const InputDecoration(
                                        labelText: 'CSO Officer Email',
                                        prefixIcon: Icon(Icons.shield_outlined, color: AppColors.textSecondaryDark),
                                      ),
                                      validator: (v) => (v == null || v.isEmpty) ? 'Required field' : null,
                                    ),
                                    const SizedBox(height: 12),
                                    TextFormField(
                                      controller: _csoPasswordController,
                                      obscureText: true,
                                      decoration: const InputDecoration(
                                        labelText: 'Password',
                                        prefixIcon: Icon(Icons.lock_outline, color: AppColors.textSecondaryDark),
                                      ),
                                      validator: (v) => (v == null || v.isEmpty) ? 'Required field' : null,
                                    ),
                                    const SizedBox(height: 14),
                                    ElevatedButton(
                                      onPressed: isLoading
                                          ? null
                                          : () {
                                              if (_csoFormKey.currentState!.validate()) {
                                                final zoneName = AppConstants.zoneIdToNameMap[_selectedZoneId] ?? 'Dhantoli';
                                                ref.read(authControllerProvider.notifier).loginCsoZonalOfficer(
                                                      _csoEmailController.text.trim(),
                                                      _csoPasswordController.text.trim(),
                                                      _selectedZoneId,
                                                      zoneName,
                                                    );
                                              }
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF10B981),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        elevation: 4,
                                      ),
                                      child: isLoading
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                            )
                                          : const Text(
                                              'Login as CSO Zonal Officer',
                                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                            ),
                                    ),
                                    const SizedBox(height: 10),
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        ref.read(authControllerProvider.notifier).loginCsoZonalOfficer(
                                              'cso.dhantoli@nagpur.gov.in',
                                              'cso123',
                                              'zone_04',
                                              'Dhantoli',
                                            );
                                      },
                                      icon: const Icon(Icons.verified_user_rounded, color: Color(0xFF10B981)),
                                      label: const Text(
                                        'Quick CSO Pass (Rajesh Gaidhani - Zone 04)',
                                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: Color(0xFF10B981)),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Department Admin Login Form
                              Form(
                                key: _adminFormKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    DropdownButtonFormField<String>(
                                      initialValue: _selectedDepartment,
                                      decoration: const InputDecoration(
                                        labelText: 'Select Department',
                                        prefixIcon: Icon(Icons.business_outlined, color: AppColors.textSecondaryDark),
                                      ),
                                      dropdownColor: AppColors.darkSurface,
                                      items: AppConstants.categoryToDepartmentMap.entries
                                          .map((e) => DropdownMenuItem(
                                                value: e.value,
                                                child: Text(
                                                  '${e.value.replaceAll("DEPT_", "")} — (${e.key})',
                                                  style: const TextStyle(fontSize: 13, color: Colors.white),
                                                ),
                                              ))
                                          .toSet()
                                          .toList(),
                                      onChanged: (val) {
                                        if (val != null) setState(() => _selectedDepartment = val);
                                      },
                                    ),
                                    const SizedBox(height: 14),
                                    TextFormField(
                                      controller: _adminEmailController,
                                      decoration: const InputDecoration(
                                        labelText: 'Officer Email',
                                        prefixIcon: Icon(Icons.badge_outlined, color: AppColors.textSecondaryDark),
                                      ),
                                      validator: (v) => (v == null || v.isEmpty) ? 'Required field' : null,
                                    ),
                                    const SizedBox(height: 14),
                                    TextFormField(
                                      controller: _adminPasswordController,
                                      obscureText: true,
                                      decoration: const InputDecoration(
                                        labelText: 'Password',
                                        prefixIcon: Icon(Icons.shield_outlined, color: AppColors.textSecondaryDark),
                                      ),
                                      validator: (v) => (v == null || v.isEmpty) ? 'Required field' : null,
                                    ),
                                    const SizedBox(height: 18),
                                    ElevatedButton(
                                      onPressed: isLoading
                                          ? null
                                          : () {
                                              if (_adminFormKey.currentState!.validate()) {
                                                ref.read(authControllerProvider.notifier).loginDepartmentAdmin(
                                                      _adminEmailController.text.trim(),
                                                      _adminPasswordController.text.trim(),
                                                      _selectedDepartment,
                                                    );
                                              }
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF2563EB),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        elevation: 4,
                                      ),
                                      child: isLoading
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                            )
                                          : const Text(
                                              'Login as Department Admin',
                                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (authState.hasError) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Error: ${authState.error}',
                      style: const TextStyle(color: AppColors.redAlert, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

