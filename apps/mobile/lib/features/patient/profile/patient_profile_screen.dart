import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_state_provider.dart';
import '../../../core/config/flavor_config.dart';
import '../../../core/services/tts_service.dart';

class PatientProfileScreen extends ConsumerWidget {
  const PatientProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;

    final name = user?.name ?? 'Ramesh Kumar';
    final patientId = user?.userId ?? 'PAT-8841';
    final age = user?.age ?? 68;
    final gender = user?.gender ?? 'Male (पुरुष)';
    final village = user?.region ?? 'Rampur Village';
    final caregiverName = user?.caregiverName ?? 'Suresh Kumar (Son)';
    final caregiverPhone = user?.caregiverPhone ?? '9876543210';
    final cognitiveStage = user?.medicalNotes ?? 'Mild Memory Loss (प्रारंभिक स्मृति ह्रास)';
    final language = user?.language ?? 'hi';

    const narration =
      'This is your patient profile. Your caregiver is Suresh Kumar. You can call helper or caregiver anytime.';

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9E6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'My Profile (मेरी प्रोफ़ाइल)',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF00695C)),
        ),
        actions: [
          IconButton(
            tooltip: 'Voice Readout',
            icon: const Icon(Icons.volume_up_rounded, size: 32, color: Color(0xFF00695C)),
            onPressed: () => ref.read(ttsServiceProvider).speak(narration, langCode: 'hi'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar & Basic Info Card
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFFFD54F), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 46,
                      backgroundColor: const Color(0xFF00695C).withOpacity(0.15),
                      child: const Icon(Icons.person_rounded, size: 56, color: Color(0xFF00695C)),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00695C).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'ID: $patientId',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00695C),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on_rounded, size: 18, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '$village • Age $age • $gender',
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Emergency Caregiver Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF81C784), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.contact_phone_rounded, color: Color(0xFF2E7D32), size: 26),
                        SizedBox(width: 8),
                        Text(
                          'Primary Caregiver (देखभालकर्ता)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      caregiverName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Phone: $caregiverPhone',
                      style: TextStyle(fontSize: 15, color: Colors.grey.shade800, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: () {
                        ref.read(ttsServiceProvider).speak(
                              'Calling caregiver $caregiverName on $caregiverPhone',
                              langCode: 'en',
                            );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('📞 Dialing Caregiver: $caregiverPhone...'),
                            backgroundColor: const Color(0xFF2E7D32),
                          ),
                        );
                      },
                      icon: const Icon(Icons.call_rounded, size: 24),
                      label: const Text(
                        'Call Caregiver Now (फोन लगाएं)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Health Status & Language
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                      icon: Icons.psychology_rounded,
                      color: Colors.purple,
                      title: 'Cognitive Stage (स्थिति)',
                      subtitle: cognitiveStage,
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(
                      icon: Icons.language_rounded,
                      color: Colors.blue,
                      title: 'Audio Language (भाषा)',
                      subtitle: language == 'hi'
                          ? 'हिन्दी (Hindi)'
                          : (language == 'bn'
                              ? 'বাংলা (Bengali)'
                              : (language == 'ta' ? 'தமிழ் (Tamil)' : 'English')),
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(
                      icon: Icons.sync_rounded,
                      color: Colors.teal,
                      title: 'Sync Status (डेटा सुरक्षा)',
                      subtitle: 'Offline Protected & Cloud Synced',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Logout / Switch Account Button
              OutlinedButton.icon(
                onPressed: () async {
                  await ref.read(authStateProvider.notifier).logout();
                },
                icon: const Icon(Icons.logout_rounded, size: 22),
                label: const Text(
                  'Switch Patient / Sign Out (लॉग आउट)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade700,
                  side: BorderSide(color: Colors.red.shade300, width: 1.5),
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
