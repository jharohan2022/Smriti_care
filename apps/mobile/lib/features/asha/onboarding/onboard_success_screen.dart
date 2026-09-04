import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../patients/asha_patient_repository.dart';

class OnboardSuccessScreen extends StatelessWidget {
  const OnboardSuccessScreen({super.key, this.patient});
  final AshaPatientRecord? patient;

  @override
  Widget build(BuildContext context) {
    const emeraldBrand = Color(0xFF059669);
    const textDark = Color(0xFF0F172A);

    final name = patient?.name ?? 'Ramesh Das';
    final age = patient?.age ?? 72;
    final village = patient?.village ?? 'Rampur Gaon';
    final language = patient?.language ?? 'Hindi';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 1),

              // Big Green Checkmark Icon Container
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF86EFAC), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: emeraldBrand.withOpacity(0.18),
                      blurRadius: 18,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.check_rounded, color: emeraldBrand, size: 54),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Patient Profile\nSafalta se Ban Gaya!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: textDark,
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 24),

              // Patient Summary Card
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
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 34,
                      backgroundColor: Color(0xFFEFF6FF),
                      child: Text('👴', style: TextStyle(fontSize: 36)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Umar: $age saal',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          Text(
                            'Gaon: $village',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          Text(
                            'Bhasha: $language',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: emeraldBrand,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // Button 1: Patient Profile Dekhein (Assessment / Profile)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    context.push('/asha/assessment/intro');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: emeraldBrand,
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFA7F3D0), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.badge_rounded, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Patient Profile Dekhein',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Button 2: Home Par Jayein
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/asha/dashboard');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: emeraldBrand,
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Home Par Jayein',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
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
