import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../patients/asha_patient_repository.dart';

class OnboardStep3Screen extends ConsumerStatefulWidget {
  const OnboardStep3Screen({super.key, this.prevData});
  final Map<String, dynamic>? prevData;

  @override
  ConsumerState<OnboardStep3Screen> createState() => _OnboardStep3ScreenState();
}

class _OnboardStep3ScreenState extends ConsumerState<OnboardStep3Screen> {
  String _selectedLanguage = 'Hindi';
  final List<String> _languages = ['Hindi', 'Bengali', 'Assamese', 'Bodo', 'English'];

  void _handleConfirm() {
    final data = widget.prevData ?? {};
    final name = (data['name'] as String?) ?? 'Ramesh Das';
    final age = int.tryParse((data['age'] as String?) ?? '72') ?? 72;
    final village = (data['village'] as String?) ?? 'Rampur Gaon';
    final district = (data['district'] as String?) ?? 'Sonapur';
    final stateName = (data['state'] as String?) ?? 'Assam';
    final phone = (data['phone'] as String?) ?? '9876543211';
    final caregiver = (data['caregiver'] as String?) ?? 'Family Member';

    final newPatient = AshaPatientRecord(
      id: 'PAT-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      name: name,
      age: age,
      village: village,
      district: district,
      state: stateName,
      language: _selectedLanguage,
      phone: phone,
      caregiverName: caregiver,
      status: AshaTriageStatus.stable,
      score: 8,
      durationSec: 36,
      trendNote: 'Initial baseline created. Ready for regular cognitive exercises.',
      notes: ['New registration completed via ASHA Sathi onboarding wizard.'],
    );

    ref.read(ashaPatientsProvider.notifier).addPatient(newPatient);

    context.push('/asha/onboard/success', extra: newPatient);
  }

  void _showChangeLanguageDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bhasha Chunein (Select Language)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _languages
              .map(
                (lang) => ListTile(
                  title: Text(lang),
                  trailing: _selectedLanguage == lang
                      ? const Icon(Icons.check, color: Color(0xFF059669))
                      : null,
                  onTap: () {
                    setState(() => _selectedLanguage = lang);
                    Navigator.pop(ctx);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const emeraldBrand = Color(0xFF059669);
    const textDark = Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: textDark, size: 28),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 3-Step Progress Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStepCircle('1', isActive: false, isCompleted: true),
                  _buildStepLine(isActive: true),
                  _buildStepCircle('2', isActive: false, isCompleted: true),
                  _buildStepLine(isActive: true),
                  _buildStepCircle('3', isActive: true, isCompleted: false),
                ],
              ),

              const SizedBox(height: 24),

              const Text(
                'Bhasha ki Pushti',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: textDark,
                ),
              ),

              const SizedBox(height: 20),

              // ASHA Didi Question Graphic
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.white,
                      child: Text('👩‍⚕️', style: TextStyle(fontSize: 40)),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Kya yahi bhasha\nsahi hai?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF065F46),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Selected Language Display Tile
              InkWell(
                onTap: _showChangeLanguageDialog,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Chuni gayi bhasha: $_selectedLanguage',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: textDark,
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: Color(0xFF64748B)),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Action 1: Haan, Sahi Hai
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: _handleConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: emeraldBrand,
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Haan, Sahi Hai',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Action 2: Nahi, Bhasha Badlein
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton(
                  onPressed: _showChangeLanguageDialog,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: emeraldBrand,
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFA7F3D0), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Nahi, Bhasha Badlein',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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

  Widget _buildStepCircle(String label, {required bool isActive, required bool isCompleted}) {
    const emeraldBrand = Color(0xFF059669);
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isActive || isCompleted ? emeraldBrand : const Color(0xFFE2E8F0),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check, size: 18, color: Colors.white)
            : Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : const Color(0xFF64748B),
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
      ),
    );
  }

  Widget _buildStepLine({required bool isActive}) {
    const emeraldBrand = Color(0xFF059669);
    return Container(
      width: 40,
      height: 3,
      color: isActive ? emeraldBrand : const Color(0xFFE2E8F0),
    );
  }
}
