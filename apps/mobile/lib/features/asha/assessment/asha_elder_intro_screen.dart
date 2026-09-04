import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/tts_service.dart';

class AshaElderIntroScreen extends ConsumerStatefulWidget {
  const AshaElderIntroScreen({super.key});

  @override
  ConsumerState<AshaElderIntroScreen> createState() => _AshaElderIntroScreenState();
}

class _AshaElderIntroScreenState extends ConsumerState<AshaElderIntroScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ttsServiceProvider).speak(
            'नमस्ते! आज कुछ मज़ेदार गतिविधियाँ करते हैं। गेम शुरू करें।',
          );
    });
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Buzurg ke Liye App',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: textDark,
                ),
              ),

              const Spacer(flex: 1),

              // Elder Holding Tablet Graphic Container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFFA7F3D0), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: emeraldBrand.withOpacity(0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('👴📱', style: TextStyle(fontSize: 48)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Namaste!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Aaj kuch mazedaar\ngatividhiyan karte hain.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF065F46),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // Action Button: "Game Shuru Karein ➔"
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    context.push('/asha/assessment/game');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: emeraldBrand,
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
                        'Game Shuru Karein',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.play_arrow_rounded, size: 26),
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
