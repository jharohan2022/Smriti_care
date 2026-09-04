import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/tts_service.dart';

class WordRecallGameScreen extends ConsumerStatefulWidget {
  const WordRecallGameScreen({super.key});

  @override
  ConsumerState<WordRecallGameScreen> createState() => _WordRecallGameScreenState();
}

class _WordRecallGameScreenState extends ConsumerState<WordRecallGameScreen> {
  final List<String> _options = const ['Kamal', 'Gulab', 'Suraj', 'Ped'];
  final String _correctWord = 'Kamal';
  String? _selectedWord;
  bool _isAnswered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ttsServiceProvider).speak(
            'शब्द याद करें! चित्र को देखिए और बताइए यह कौन सा शब्द है?',
          );
    });
  }

  void _selectWord(String word) {
    setState(() {
      _selectedWord = word;
      _isAnswered = true;
    });

    if (word == _correctWord) {
      ref.read(ttsServiceProvider).speak('शाबाश! कमल बिल्कुल सही उत्तर है।');
    } else {
      ref.read(ttsServiceProvider).speak('फिर से प्रयास करें। यह कमल का फूल है।');
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: textDark, size: 28),
          onPressed: () => context.pop(),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shabd Yaad Karein',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: textDark,
              ),
            ),
            Text(
              'Jo shabd pehle dekhe the?',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            children: [
              const SizedBox(height: 8),

              // Central Object Picture Container (Lotus Flower)
              Container(
                width: double.infinity,
                height: 190,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFFCE7F3), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEC4899).withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('🪷', style: TextStyle(fontSize: 84)),
                      SizedBox(height: 4),
                      Text(
                        'राष्ट्रीय पुष्प (National Flower)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF9D174D),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 4 Accessible Choice Pills
              Expanded(
                child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _options.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final word = _options[index];
                    final isSelected = _selectedWord == word;
                    final isCorrect = word == _correctWord;

                    Color bgColor = Colors.white;
                    Color borderColor = const Color(0xFFE2E8F0);
                    Color textColor = textDark;

                    if (isSelected) {
                      if (isCorrect) {
                        bgColor = const Color(0xFFECFDF5);
                        borderColor = const Color(0xFF10B981);
                        textColor = const Color(0xFF065F46);
                      } else {
                        bgColor = const Color(0xFFFEF2F2);
                        borderColor = const Color(0xFFEF4444);
                        textColor = const Color(0xFF991B1B);
                      }
                    }

                    return GestureDetector(
                      onTap: () => _selectWord(word),
                      child: Container(
                        height: 56,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: borderColor,
                            width: isSelected ? 2.5 : 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              word,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: textColor,
                              ),
                            ),
                            if (isSelected && isCorrect)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFF10B981),
                                size: 24,
                              )
                            else if (isSelected && !isCorrect)
                              const Icon(
                                Icons.cancel_rounded,
                                color: Color(0xFFEF4444),
                                size: 24,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Bottom Forward Navigation Button
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: _isAnswered
                      ? () {
                          context.push('/activities');
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandPurple,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFCBD5E1),
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

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
