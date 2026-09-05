import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/tts_service.dart';

class PatientWelcomeScreen extends ConsumerStatefulWidget {
  const PatientWelcomeScreen({super.key});

  @override
  ConsumerState<PatientWelcomeScreen> createState() => _PatientWelcomeScreenState();
}

class _PatientWelcomeScreenState extends ConsumerState<PatientWelcomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ttsServiceProvider).speak(
            'स्मरण में आपका स्वागत है। चलिए शुरू करते हैं।',
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    const brandPurple = Color(0xFF5B43D6);
    const textNavy = Color(0xFF1E1B6B);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: Stack(
        children: [
          // 1. Full-bleed background hero illustration (elderly couple facing hills)
          Positioned.fill(
            child: Image.asset(
              'assets/images/smarana_hero.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFFEDE9FE),
                child: const Center(
                  child: Icon(Icons.nature_people, size: 90, color: brandPurple),
                ),
              ),
            ),
          ),

          // 2. Soft top gradient overlay for crystal clear text readability
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 280,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.85),
                    Colors.white.withOpacity(0.65),
                    Colors.white.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // 3. Main Content Layer
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),

                // Top Header: Logo + Smarana + Subtitle
                Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/app_logo.png',
                        height: 76,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.spa,
                          size: 64,
                          color: brandPurple,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Smarana',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: textNavy,
                          letterSpacing: -0.6,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Har Yaad, Hamare Saath',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF282370),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),

                // Middle Sky Area: Floating Cursive Quotation
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Zindagi ke\nhar lamhe ko\nsaath mein... ♡',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            height: 1.35,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF262074),
                            shadows: [
                              Shadow(
                                color: Colors.white.withOpacity(0.9),
                                blurRadius: 12,
                              ),
                              Shadow(
                                color: Colors.white.withOpacity(0.8),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Overlay Card Container
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, -6),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Primary Button: "Chaliye Shuru Karein ➔"
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            context.go('/greeting');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: brandPurple,
                            foregroundColor: Colors.white,
                            elevation: 4,
                            shadowColor: brandPurple.withOpacity(0.35),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Chaliye Shuru Karein',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, size: 22),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ASHA Sathi Access Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            context.push('/asha/login');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFECFDF5),
                            foregroundColor: const Color(0xFF065F46),
                            elevation: 0,
                            side: const BorderSide(color: Color(0xFF059669), width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.health_and_safety_rounded, color: Color(0xFF059669), size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'ASHA Sathi App (आशा साथी पोर्टल)',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF065F46),
                                  ),
                                ),
                                SizedBox(width: 6),
                                Icon(Icons.arrow_forward_rounded, color: Color(0xFF059669), size: 18),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Bottom Trust Subtitles
                      const Text(
                        'Koi login nahi  |  Sirf aap aur hum',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Aapki Boli Mein  |  Offline Bhi Kaam Kare',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF059669),
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
    );
  }
}
