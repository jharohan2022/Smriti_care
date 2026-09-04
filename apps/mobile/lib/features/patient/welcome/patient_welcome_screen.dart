import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_state_provider.dart';
import '../../../core/config/flavor_config.dart';
import '../../../core/services/tts_service.dart';
import '../../auth/auth_screen.dart';

/// Smarana (स्मरणा) — Welcome & Landing Screen
/// Designed for warmth, zero-literacy accessibility, and comforting dementia care.
class PatientWelcomeScreen extends ConsumerWidget {
  const PatientWelcomeScreen({super.key});

  static const _narration =
      'Namaste! Welcome to Smarana. Har yaad, hamare saath. Chaliye shuru karein.';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Bar with ASHA Switch & TTS Listen Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ASHA / Healthcare Worker Quick Switch Link
                  TextButton.icon(
                    onPressed: () {
                      ref.read(authStateProvider.notifier).switchRole(AppFlavor.asha);
                    },
                    icon: const Icon(Icons.medical_services_rounded, size: 18, color: Color(0xFFC2185B)),
                    label: const Text(
                      'ASHA Portal',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFC2185B),
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      backgroundColor: const Color(0xFFFFEBEE),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),

                  // TTS Voice Listen Button
                  IconButton(
                    tooltip: 'आवाज़ सुनें (Listen)',
                    icon: const Icon(Icons.volume_up_rounded, size: 30, color: Color(0xFF6A1B9A)),
                    onPressed: () {
                      ref.read(ttsServiceProvider).speak(_narration, langCode: 'hi');
                    },
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Brand Logo: Brain + Leaf with Red & Purple Accents
              Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E5F5),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE1BEE7), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6A1B9A).withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.psychology_rounded, size: 38, color: Color(0xFF7B1FA2)),
                      Transform.translate(
                        offset: const Offset(-4, -4),
                        child: const Icon(Icons.eco_rounded, size: 30, color: Color(0xFF2E7D32)),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Brand Name: Smarana (स्मरणा)
              const Center(
                child: Text(
                  'Smarana',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: Color(0xFF311B92),
                  ),
                ),
              ),

              // Tagline: Har Yaad, Hamare Saath
              const Center(
                child: Text(
                  'Har Yaad, Hamare Saath (हर याद, हमारे साथ)',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF5E35B1),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Heartwarming Handwritten Style Quote
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'Zindagi ke har lamhe ko saath mein...  ♡',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                      color: Colors.blueGrey.shade800,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Hero Visual: Scenic Elderly Couple Looking at Sunrise & Mountains
              Container(
                height: 290,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFFFFD54F), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: Image.asset(
                    'assets/images/smarana_hero.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFFE8F5E9),
                      child: const Center(
                        child: Icon(Icons.volunteer_activism_rounded, size: 80, color: Color(0xFF2E7D32)),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // Primary Action Button: "Chaliye Shuru Karein ➔"
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF5E35B1), // Deep Royal Purple
                      Color(0xFFC2185B), // Warm Crimson Red
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFC2185B).withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      ref.read(ttsServiceProvider).speak(
                            'Shuru karte hain. Welcome to Smarana!',
                            langCode: 'hi',
                          );

                      // Ensure user is signed in as default demo patient if not already authenticated
                      if (!ref.read(authStateProvider).isAuthenticated) {
                        await ref.read(authStateProvider.notifier).loginPatient(
                              name: 'Ramesh Kumar',
                              village: 'Rampur Village',
                              patientId: 'p-rameshkumar',
                              language: 'hi',
                            );
                      }
                      if (context.mounted) {
                        context.go('/home');
                      }
                    },
                    borderRadius: BorderRadius.circular(28),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              'Chaliye Shuru Karein',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 24, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Trust Badges: Zero-Login & Regional Language & Offline
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 6,
                children: [
                  const Text(
                    'Koi login nahi',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E88E5),
                    ),
                  ),
                  Text('•', style: TextStyle(color: Colors.grey.shade400)),
                  const Text(
                    'Sirf aap aur hum',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFE53935),
                    ),
                  ),
                  Text('•', style: TextStyle(color: Colors.grey.shade400)),
                  const Text(
                    'Aapki Boli Mein',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  Text('•', style: TextStyle(color: Colors.grey.shade400)),
                  const Text(
                    'Offline Bhi Kaam Kare',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF6A1B9A),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Option to open detailed registration / login form
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AuthScreen()),
                    );
                  },
                  icon: const Icon(Icons.app_registration_rounded, size: 18, color: Color(0xFFC2185B)),
                  label: const Text(
                    'Naya Registration / Switch Account (पंजीकरण / लॉगिन)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFC2185B),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
