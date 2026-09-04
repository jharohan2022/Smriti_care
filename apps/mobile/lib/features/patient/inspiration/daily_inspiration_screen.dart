import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/tts_service.dart';

class DailyInspirationScreen extends ConsumerStatefulWidget {
  const DailyInspirationScreen({super.key});

  @override
  ConsumerState<DailyInspirationScreen> createState() => _DailyInspirationScreenState();
}

class _DailyInspirationScreenState extends ConsumerState<DailyInspirationScreen> {
  bool _isPlayingAudio = false;

  void _toggleAudio() {
    setState(() {
      _isPlayingAudio = !_isPlayingAudio;
    });

    if (_isPlayingAudio) {
      ref.read(ttsServiceProvider).speak(
            'रघुपति राघव राजा राम, पतित पावन सीताराम। ईश्वर अल्लाह तेरो नाम, सब को सन्मति दे भगवान।',
          );
    } else {
      ref.read(ttsServiceProvider).stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    const brandPurple = Color(0xFF6B4EE6);
    const textDark = Color(0xFF1E1B4B);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Daily Inspiration',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: textDark,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Scenic Quote Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE0F2FE), Color(0xFFDCFCE7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFBAE6FD)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('🌿', style: TextStyle(fontSize: 24)),
                        Text('🏔️', style: TextStyle(fontSize: 24)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Yaadein sirf beete kal ki nahi,\nanhone kal ki taaqat bhi hain. ❤️',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0C4A6E),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'स्मरण शांति और ऊर्जा',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0369A1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Card 1: Aaj ka Vichar
              _buildInspirationCard(
                icon: Icons.eco_rounded,
                iconColor: const Color(0xFF059669),
                bgColor: const Color(0xFFECFDF5),
                borderColor: const Color(0xFFA7F3D0),
                title: 'Aaj ka Vichar',
                description: 'Har din ek nayi shuruaat hai. Har subah nayi aasha lekar aati hai.',
                onReadAloud: () {
                  ref.read(ttsServiceProvider).speak(
                        'आज का विचार: हर दिन एक नई शुरुआत है। हर सुबह नई आशा लेकर आती है।',
                      );
                },
              ),

              const SizedBox(height: 14),

              // Card 2: Suno - Apne pasandeeda gaane (Music / Audio Player)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F3FF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFDDD6FE), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: brandPurple.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.music_note_rounded, color: brandPurple, size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Suno',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: textDark,
                                ),
                              ),
                              Text(
                                'Apne pasandeeda gaane & bhajan',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Player Controls with Waveform Visual
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _toggleAudio,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: brandPurple,
                            ),
                            child: Icon(
                              _isPlayingAudio ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            height: 38,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE5E7EB)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: List.generate(
                                14,
                                (i) => Container(
                                  width: 4,
                                  height: (i % 3 == 0)
                                      ? (_isPlayingAudio ? 24 : 14)
                                      : (i % 2 == 0 ? 18 : 10),
                                  decoration: BoxDecoration(
                                    color: _isPlayingAudio ? brandPurple : const Color(0xFFCBD5E1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Card 3: Aaj ka Chhota Sa Wellness Tip
              _buildInspirationCard(
                icon: Icons.favorite_rounded,
                iconColor: const Color(0xFF0284C7),
                bgColor: const Color(0xFFF0F9FF),
                borderColor: const Color(0xFFBAE6FD),
                title: 'Aaj ka Chhota Sa Wellness Tip',
                description: 'Thodi walk, thodi dhoop, aur behtar soch. Subah 15 minute taazi hawa lein.',
                onReadAloud: () {
                  ref.read(ttsServiceProvider).speak(
                        'आज का वेलनेस टिप: थोड़ी वॉक, थोड़ी धूप, और बेहतर सोच। सुबह पंद्रह मिनट ताज़ा हवा लें।',
                      );
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInspirationCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required Color borderColor,
    required String title,
    required String description,
    required VoidCallback onReadAloud,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E1B4B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF475569),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF4B5563), size: 22),
            onPressed: onReadAloud,
            tooltip: 'Sunein',
          ),
        ],
      ),
    );
  }
}
