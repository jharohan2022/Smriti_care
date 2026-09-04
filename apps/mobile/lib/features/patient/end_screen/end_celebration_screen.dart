import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/tts_service.dart';

class EndCelebrationScreen extends ConsumerStatefulWidget {
  const EndCelebrationScreen({super.key});

  @override
  ConsumerState<EndCelebrationScreen> createState() => _EndCelebrationScreenState();
}

class _EndCelebrationScreenState extends ConsumerState<EndCelebrationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ttsServiceProvider).speak(
            'आज का दिन बहुत अच्छा था! कल फिर मिलेंगे कुछ नया याद करने के लिए।',
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    const brandPurple = Color(0xFF6B4EE6);
    const textDark = Color(0xFF1E1B4B);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Cheerful Sun Celebration Graphic
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFEF3C7),
                  border: Border.all(color: const Color(0xFFFDE68A), width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withOpacity(0.25),
                      blurRadius: 28,
                      spreadRadius: 6,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('🌞', style: TextStyle(fontSize: 72)),
                ),
              ),

              const SizedBox(height: 32),

              // Celebration Text
              const Text(
                'Aaj ka din\nbahut accha tha!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: textDark,
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 14),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Kal phir milenge kuch naya yaad karne ke liye.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4B5563),
                    height: 1.4,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Decorative Blooming Garden Tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🌸 🌻 🌷 🌿', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 8),
                    Text(
                      'Shubh Ratri & Shanti',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF065F46),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 3),

              // Big Button: "Theek Hai ➔"
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/home');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandPurple,
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Theek Hai',
                        style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 24),
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
