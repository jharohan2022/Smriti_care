import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/tts_service.dart';
import 'widgets/game_completion_dialog.dart';

class LandmarkQuestion {
  final String questionHi;
  final String questionEn;
  final String correctOptionId;
  final List<LandmarkOption> options;

  const LandmarkQuestion({
    required this.questionHi,
    required this.questionEn,
    required this.correctOptionId,
    required this.options,
  });
}

class LandmarkOption {
  final String id;
  final String nameHi;
  final String nameEn;
  final IconData icon;
  final Color color;

  const LandmarkOption({
    required this.id,
    required this.nameHi,
    required this.nameEn,
    required this.icon,
    required this.color,
  });
}

class MeriDuniyaGameScreen extends ConsumerStatefulWidget {
  const MeriDuniyaGameScreen({super.key});

  @override
  ConsumerState<MeriDuniyaGameScreen> createState() => _MeriDuniyaGameScreenState();
}

class _MeriDuniyaGameScreenState extends ConsumerState<MeriDuniyaGameScreen> {
  static const List<LandmarkQuestion> _questions = [
    LandmarkQuestion(
      questionHi: 'बाज़ार से घर आते समय गाँव के चौराहे पर सबसे पहले कौन सा स्थान आता है?',
      questionEn: 'Which landmark comes first at the village crossroad when returning home from market?',
      correctOptionId: 'temple',
      options: [
        LandmarkOption(id: 'temple', nameHi: 'मंदिर (Village Temple)', nameEn: 'Temple', icon: Icons.temple_hindu_rounded, color: Color(0xFFD97706)),
        LandmarkOption(id: 'school', nameHi: 'प्राथमिक विद्यालय (School)', nameEn: 'School', icon: Icons.school_rounded, color: Color(0xFF2563EB)),
        LandmarkOption(id: 'teashop', nameHi: 'चाय की दुकान (Tea Stall)', nameEn: 'Tea Stall', icon: Icons.local_cafe_rounded, color: Color(0xFF059669)),
        LandmarkOption(id: 'tree', nameHi: 'पुराना बरगद का पेड़ (Banyan)', nameEn: 'Banyan Tree', icon: Icons.park_rounded, color: Color(0xFF15803D)),
      ],
    ),
    LandmarkQuestion(
      questionHi: 'ग्राम पंचायत भवन के ठीक सामने कौन सी जगह स्थित है?',
      questionEn: 'What is located right in front of the Gram Panchayat House?',
      correctOptionId: 'teashop',
      options: [
        LandmarkOption(id: 'teashop', nameHi: 'चाय की दुकान (Tea Shop)', nameEn: 'Tea Shop', icon: Icons.local_cafe_rounded, color: Color(0xFF059669)),
        LandmarkOption(id: 'temple', nameHi: 'मंदिर (Temple)', nameEn: 'Temple', icon: Icons.temple_hindu_rounded, color: Color(0xFFD97706)),
        LandmarkOption(id: 'well', nameHi: 'गाँव का कुआँ (Village Well)', nameEn: 'Village Well', icon: Icons.water_drop_rounded, color: Color(0xFF0288D1)),
        LandmarkOption(id: 'post', nameHi: 'डाकघर (Post Office)', nameEn: 'Post Office', icon: Icons.markunread_mailbox_rounded, color: Color(0xFFDC2626)),
      ],
    ),
    LandmarkQuestion(
      questionHi: 'सुबह टहलते समय मंदिर से आगे जाने पर कौन सा विशाल वृक्ष दिखता है?',
      questionEn: 'Which giant tree is visible past the temple during morning walks?',
      correctOptionId: 'tree',
      options: [
        LandmarkOption(id: 'tree', nameHi: 'बरगद का पेड़ (Banyan Tree)', nameEn: 'Banyan Tree', icon: Icons.park_rounded, color: Color(0xFF15803D)),
        LandmarkOption(id: 'school', nameHi: 'विद्यालय (School)', nameEn: 'School', icon: Icons.school_rounded, color: Color(0xFF2563EB)),
        LandmarkOption(id: 'market', nameHi: 'हाट बाज़ार (Local Market)', nameEn: 'Market', icon: Icons.storefront_rounded, color: Color(0xFF7C3AED)),
        LandmarkOption(id: 'well', nameHi: 'कुआँ (Well)', nameEn: 'Well', icon: Icons.water_drop_rounded, color: Color(0xFF0288D1)),
      ],
    ),
  ];

  int _currentIndex = 0;
  String? _selectedOptionId;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _playQuestionPrompt();
  }

  void _playQuestionPrompt() {
    final q = _questions[_currentIndex];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ttsServiceProvider).speak(q.questionHi, langCode: 'hi');
    });
  }

  void _selectOption(String id) {
    setState(() {
      _selectedOptionId = id;
    });
  }

  void _submitAnswer() {
    if (_selectedOptionId == null) return;
    final currentQ = _questions[_currentIndex];
    if (_selectedOptionId == currentQ.correctOptionId) {
      _score += 10;
      ref.read(ttsServiceProvider).speak('बहुत बढ़िया! सही रास्ता चुना।', langCode: 'hi');
    } else {
      ref.read(ttsServiceProvider).speak('कोई बात नहीं, अगला सवाल देखते हैं।', langCode: 'hi');
    }

    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOptionId = null;
      });
      _playQuestionPrompt();
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => GameCompletionDialog(
          gameTitle: 'Meri Duniya (स्थानिक क्षमता)',
          score: (_score * 10 / (_questions.length * 10)).round(),
          onPlayAgain: () {
            Navigator.pop(ctx);
            setState(() {
              _currentIndex = 0;
              _selectedOptionId = null;
              _score = 0;
            });
            _playQuestionPrompt();
          },
          onNextGame: () {
            Navigator.pop(ctx);
            context.go('/game/memory-tree');
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const brandBlue = Color(0xFF0288D1);
    const textDark = Color(0xFF0F172A);
    final currentQ = _questions[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 28, color: textDark),
          onPressed: () => context.go('/khel'),
        ),
        title: const Text(
          'Meri Duniya (स्थानिक क्षमता)',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textDark),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up_rounded, color: brandBlue, size: 28),
            onPressed: _playQuestionPrompt,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Village Route Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0288D1), Color(0xFF0369A1)],
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: brandBlue.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.map_rounded, color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Question ${_currentIndex + 1} of ${_questions.length}',
                            style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Gaon Ka Rasta (Spatial Recall)',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Question Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFBAE6FD)),
                ),
                child: Text(
                  currentQ.questionHi,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: textDark, height: 1.35),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Sahi sthan chuniye (Select Landmark):',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF475569)),
              ),

              const SizedBox(height: 12),

              // Options List
              Expanded(
                child: ListView.separated(
                  itemCount: currentQ.options.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final opt = currentQ.options[index];
                    final isSel = _selectedOptionId == opt.id;

                    return InkWell(
                      onTap: () => _selectOption(opt.id),
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSel ? const Color(0xFFE0F2FE) : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSel ? brandBlue : const Color(0xFFE2E8F0),
                            width: isSel ? 2.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: opt.color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(opt.icon, color: opt.color, size: 28),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                opt.nameHi,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: isSel ? brandBlue : textDark,
                                ),
                              ),
                            ),
                            Icon(
                              isSel ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                              color: isSel ? brandBlue : const Color(0xFF94A3B8),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedOptionId != null ? _submitAnswer : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Confirm Route (पुष्टि करें)', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
