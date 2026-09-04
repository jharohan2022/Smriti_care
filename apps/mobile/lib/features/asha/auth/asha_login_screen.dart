import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/asha_auth_service.dart';
import '../../../core/services/tts_service.dart';

class AshaLoginScreen extends ConsumerStatefulWidget {
  const AshaLoginScreen({super.key});

  @override
  ConsumerState<AshaLoginScreen> createState() => _AshaLoginScreenState();
}

class _AshaLoginScreenState extends ConsumerState<AshaLoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Login Controllers
  final _loginPhoneController = TextEditingController(text: '9876543210');
  final _loginPasswordController = TextEditingController(text: '1234');

  // Registration Controllers
  final _regNameController = TextEditingController(text: 'सुनीता देवी (Sunita Devi)');
  final _regIdController = TextEditingController(text: 'ASHA-8841');
  final _regPhoneController = TextEditingController(text: '9876543210');
  final _regSubCenterController = TextEditingController(text: 'Rampur Sub-Center');
  final _regVillageController = TextEditingController(text: 'Rampur Gaon');
  final _regPasswordController = TextEditingController(text: '1234');

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginPhoneController.dispose();
    _loginPasswordController.dispose();
    _regNameController.dispose();
    _regIdController.dispose();
    _regPhoneController.dispose();
    _regSubCenterController.dispose();
    _regVillageController.dispose();
    _regPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    await ref.read(ashaAuthProvider.notifier).login(
          phone: _loginPhoneController.text.trim(),
          password: _loginPasswordController.text.trim(),
        );
    setState(() => _isLoading = false);

    if (mounted) {
      context.go('/asha/dashboard');
    }
  }

  Future<void> _handleRegister() async {
    setState(() => _isLoading = true);
    await ref.read(ashaAuthProvider.notifier).register(
          name: _regNameController.text.trim(),
          ashaId: _regIdController.text.trim(),
          phone: _regPhoneController.text.trim(),
          subCenter: _regSubCenterController.text.trim(),
          village: _regVillageController.text.trim(),
          password: _regPasswordController.text.trim(),
        );
    setState(() => _isLoading = false);

    if (mounted) {
      context.go('/asha/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    const emeraldBrand = Color(0xFF059669);
    const textDark = Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),

              // Header Branding
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/app_logo.png',
                      height: 64,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.spa,
                        size: 50,
                        color: emeraldBrand,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Smarana',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: textDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const Text(
                      'ASHA Sathi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: emeraldBrand,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Seva, Sampark Aur Suraksha',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ASHA Worker Illustration Container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFECFDF5), Color(0xFFE0F2FE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('👩‍⚕️', style: TextStyle(fontSize: 38)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Saath Mein, Har Buzurg',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF065F46),
                            ),
                          ),
                          Text(
                            'Ek Surakshit Kal Ki Ore ❤️',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF047857),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Tab Bar for Login & Register
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: emeraldBrand,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: const Color(0xFF475569),
                  labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                  tabs: const [
                    Tab(text: 'Login (लॉग इन)'),
                    Tab(text: 'Register (पंजीकरण)'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Form Container
              SizedBox(
                height: 380,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Login Tab Form
                    Column(
                      children: [
                        TextField(
                          controller: _loginPhoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'Mobile Number (मोबाइल नंबर)',
                            prefixIcon: const Icon(Icons.phone_rounded, color: emeraldBrand),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _loginPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Password / PIN (पासवर्ड)',
                            prefixIcon: const Icon(Icons.lock_rounded, color: emeraldBrand),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Contact Sub-Center Admin to reset PIN.')),
                              );
                            },
                            child: const Text('Forgot Password? (पासवर्ड भूल गए?)'),
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: emeraldBrand,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text('Login (लॉग इन करें)',
                                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                          ),
                        ),
                      ],
                    ),

                    // Registration Tab Form
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          TextField(
                            controller: _regNameController,
                            decoration: InputDecoration(
                              labelText: 'ASHA Full Name (आशा कार्यकर्ता का नाम)',
                              prefixIcon: const Icon(Icons.badge_rounded, color: emeraldBrand),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _regIdController,
                            decoration: InputDecoration(
                              labelText: 'ASHA ID (आशा पहचान संख्या)',
                              prefixIcon: const Icon(Icons.fingerprint_rounded, color: emeraldBrand),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _regPhoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: 'Mobile Number',
                              prefixIcon: const Icon(Icons.phone_rounded, color: emeraldBrand),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _regVillageController,
                            decoration: InputDecoration(
                              labelText: 'Assigned Village (आवंटित गाँव)',
                              prefixIcon: const Icon(Icons.location_city_rounded, color: emeraldBrand),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _regPasswordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Create PIN (4-digit PIN)',
                              prefixIcon: const Icon(Icons.lock_rounded, color: emeraldBrand),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleRegister,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: emeraldBrand,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text('Naya Panjikaran Karein',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
