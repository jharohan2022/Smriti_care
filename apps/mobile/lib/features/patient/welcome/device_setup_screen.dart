import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/patient_device_service.dart';
import '../../../core/services/tts_service.dart';

class DeviceSetupScreen extends ConsumerStatefulWidget {
  const DeviceSetupScreen({super.key});

  @override
  ConsumerState<DeviceSetupScreen> createState() => _DeviceSetupScreenState();
}

class _DeviceSetupScreenState extends ConsumerState<DeviceSetupScreen> {
  final _nameController = TextEditingController(text: 'रामनाथ शर्मा (Ramnath Sharma)');
  final _ageController = TextEditingController(text: '72');
  final _ashaNameController = TextEditingController(text: 'सुनीता दीदी (Sunita Didi)');
  final _ashaPhoneController = TextEditingController(text: '+91 98765 43210');
  final _emergencyController = TextEditingController(text: '+91 98111 22334 (Rohan - Son)');

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ttsServiceProvider).speak(
            'स्मरण डिवाइस सेटअप में आपका स्वागत है। आशा कार्यकर्ता कृपया मरीज़ की जानकारी सेट करें।',
          );
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _ashaNameController.dispose();
    _ashaPhoneController.dispose();
    _emergencyController.dispose();
    super.dispose();
  }

  Future<void> _handleActivate() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter patient name.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    await ref.read(patientDeviceProvider.notifier).activateDeviceForPatient(
          name: name,
          age: _ageController.text.trim().isNotEmpty ? _ageController.text.trim() : '70',
          ashaName: _ashaNameController.text.trim().isNotEmpty
              ? _ashaNameController.text.trim()
              : 'सुनीता दीदी (Sunita Didi)',
          ashaPhone: _ashaPhoneController.text.trim().isNotEmpty
              ? _ashaPhoneController.text.trim()
              : '+91 98765 43210',
          emergencyContact: _emergencyController.text.trim().isNotEmpty
              ? _emergencyController.text.trim()
              : '+91 98111 22334',
        );

    setState(() => _isLoading = false);

    if (mounted) {
      context.go('/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    const brandPurple = Color(0xFF6B4EE6);
    const textDark = Color(0xFF1E1B4B);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),

              // Smarana Logo & Header
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/app_logo.png',
                      height: 72,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.spa,
                        size: 56,
                        color: brandPurple,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Smarana Setup',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'One-Time Device & Patient Activation (पहला सेटअप)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Reassurance Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE9FE),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFDDD6FE)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lock_person_rounded, color: brandPurple, size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'यह सेटअप सिर्फ इंस्टॉलेशन के बाद एक बार आता है। इसके बाद लॉगिन का विकल्प हट जाएगा और ऐप सीधे मरीज़ के लिए खुलेगा।',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4C1D95),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Patient Information Form Fields
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Patient Details (मरीज़ की जानकारी)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Patient Name (मरीज़ का नाम)',
                        prefixIcon: const Icon(Icons.person_rounded, color: brandPurple),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Age (उम्र)',
                        prefixIcon: const Icon(Icons.calendar_today_rounded, color: brandPurple),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _ashaNameController,
                      decoration: InputDecoration(
                        labelText: 'Assigned ASHA Worker (आशा कार्यकर्ता का नाम)',
                        prefixIcon: const Icon(Icons.medical_services_rounded, color: Color(0xFF10B981)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _ashaPhoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'ASHA Phone (आशा का फोन)',
                        prefixIcon: const Icon(Icons.phone_rounded, color: Color(0xFF10B981)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _emergencyController,
                      decoration: InputDecoration(
                        labelText: 'Emergency Contact (आपातकालीन संपर्क)',
                        prefixIcon: const Icon(Icons.emergency_rounded, color: Color(0xFFE11D48)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Activation Button: "Activate Device for Patient ➔"
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleActivate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandPurple,
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Activate & Lock Device',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 22),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
