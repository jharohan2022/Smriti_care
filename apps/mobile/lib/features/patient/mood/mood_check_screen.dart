import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/tts_service.dart';

class MoodItem {
  final String label;
  final String labelHi;
  final String emoji;
  final Color color;

  const MoodItem({
    required this.label,
    required this.labelHi,
    required this.emoji,
    required this.color,
  });
}

class MoodCheckScreen extends ConsumerStatefulWidget {
  const MoodCheckScreen({super.key});

  @override
  ConsumerState<MoodCheckScreen> createState() => _MoodCheckScreenState();
}

class _MoodCheckScreenState extends ConsumerState<MoodCheckScreen> {
  final List<MoodItem> _moods = const [
    MoodItem(label: 'Bahut Achha', labelHi: 'बहुत अच्छा', emoji: '😄', color: Color(0xFF10B981)),
    MoodItem(label: 'Achha', labelHi: 'अच्छा', emoji: '😊', color: Color(0xFF0284C7)),
    MoodItem(label: 'Theek', labelHi: 'ठीक', emoji: '😐', color: Color(0xFFF59E0B)),
    MoodItem(label: 'Thoda Udaas', labelHi: 'थोड़ा उदास', emoji: '🙁', color: Color(0xFFF97316)),
    MoodItem(label: 'Udaas', labelHi: 'उदास', emoji: '😢', color: Color(0xFFEF4444)),
  ];

  int _selectedMoodIndex = 1; // Default "Achha"

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ttsServiceProvider).speak(
            'आज आप कैसा महसूस कर रहे हैं? अपना मूड चुनिए।',
          );
    });
  }

  void _selectMood(int index) {
    setState(() {
      _selectedMoodIndex = index;
    });
    ref.read(ttsServiceProvider).speak(_moods[index].labelHi);
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
              const SizedBox(height: 12),

              // Title Prompt
              const Text(
                'Aaj aap kaisa mehsoos\nkar rahe hain?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: textDark,
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 36),

              // 5 Mood Emoji Tiles Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(_moods.length, (index) {
                  final mood = _moods[index];
                  final isSelected = _selectedMoodIndex == index;

                  return GestureDetector(
                    onTap: () => _selectMood(index),
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? mood.color.withOpacity(0.18) : Colors.white,
                            border: Border.all(
                              color: isSelected ? mood.color : const Color(0xFFE2E8F0),
                              width: isSelected ? 3.0 : 1.5,
                            ),
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color: mood.color.withOpacity(0.3),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                            ],
                          ),
                          child: Text(
                            mood.emoji,
                            style: TextStyle(fontSize: isSelected ? 36 : 28),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          mood.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? mood.color : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),

              const SizedBox(height: 48),

              // Selected Mood Card Display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _moods[_selectedMoodIndex].color.withOpacity(0.4),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _moods[_selectedMoodIndex].color.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_moods[_selectedMoodIndex].emoji, style: const TextStyle(fontSize: 34)),
                    const SizedBox(width: 14),
                    Text(
                      'Aapne chuna: ${_moods[_selectedMoodIndex].labelHi}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _moods[_selectedMoodIndex].color,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Action Button: "Aage Badhien ➔"
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: () {
                    context.push('/end-screen');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Aage Badhien',
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
