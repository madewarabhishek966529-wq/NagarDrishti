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
  final _adminFormKey = GlobalKey<FormState>();

  final _emailPhoneController = TextEditingController(text: 'citizen@nagpur.gov.in');
  final _citizenPasswordController = TextEditingController(text: 'nagpur123');

  final _adminEmailController = TextEditingController(text: 'admin.roads@nagpur.gov.in');
  final _adminPasswordController = TextEditingController(text: 'admin123');
  String _selectedDepartment = 'DEPT_ROADS';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailPhoneController.dispose();
    _citizenPasswordController.dispose();
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
            colors: [AppColors.darkBackground, Color(0xFF020617)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Header / Logo Badge
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: AppColors.nagpurOrange.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.nagpurOrange, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.nagpurOrange.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.location_city_rounded,
                      size: 40,
                      color: AppColors.nagpurOrange,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    AppConstants.appName,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'AI Civic Reporter & Smart Governance Portal',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondaryDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Dual Tab Pill
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.darkSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: AppColors.nagpurOrange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: Colors.white,
                      unselectedLabelColor: AppColors.textSecondaryDark,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      tabs: const [
                        Tab(text: 'Citizen Login'),
                        Tab(text: 'Dept Admin'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tab View Container
                  SizedBox(
                    height: 360,
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
                                  prefixIcon: Icon(Icons.person_outline, color: AppColors.textSecondaryDark),
                                ),
                                validator: (v) => (v == null || v.isEmpty) ? 'Required field' : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _citizenPasswordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'Password or OTP',
                                  prefixIcon: Icon(Icons.lock_outline, color: AppColors.textSecondaryDark),
                                ),
                                validator: (v) => (v == null || v.isEmpty) ? 'Required field' : null,
                              ),
                              const SizedBox(height: 24),
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
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      )
                                    : const Text(
                                        'Login as Citizen',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                              ),
                              const SizedBox(height: 16),
                              OutlinedButton.icon(
                                onPressed: () {
                                  ref.read(authControllerProvider.notifier).loginCitizenPhone('+91 9876543210', '123456');
                                },
                                icon: const Icon(Icons.bolt, color: AppColors.nagpurOrange),
                                label: const Text('Quick Citizen Demo Pass', style: TextStyle(color: Colors.white)),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppColors.nagpurOrange),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                                  labelText: 'Admin Officer Email',
                                  prefixIcon: Icon(Icons.badge_outlined, color: AppColors.textSecondaryDark),
                                ),
                                validator: (v) => (v == null || v.isEmpty) ? 'Required field' : null,
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _adminPasswordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'Admin Password',
                                  prefixIcon: Icon(Icons.shield_outlined, color: AppColors.textSecondaryDark),
                                ),
                                validator: (v) => (v == null || v.isEmpty) ? 'Required field' : null,
                              ),
                              const SizedBox(height: 20),
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
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      )
                                    : const Text(
                                        'Login to Admin Dashboard',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
