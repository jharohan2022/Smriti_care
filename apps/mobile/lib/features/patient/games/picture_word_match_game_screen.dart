import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/models/telemetry_event.dart';
import '../../../core/services/device_identity_service.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/sync/sync_manager.dart';
import 'widgets/game_completion_dialog.dart';

class WordPictureCard {
  const WordPictureCard({
    required this.id,
    required this.nameHi,
    required this.nameEn,
    required this.icon,
    required this.color,
    required this.distractorsHi,
  });

  final String id;
  final String nameHi;
  final String nameEn;
  final IconData icon;
  final Color color;
  final List<String> distractorsHi;
}

/// Language & Word-Finding assessment:
/// Displays a high-contrast pictorial representation of a daily object/concept,
/// and asks the patient to identify the correct matching word among options.
class PictureWordMatchGameScreen extends ConsumerStatefulWidget {
  const PictureWordMatchGameScreen({super.key});

  @override
  ConsumerState<PictureWordMatchGameScreen> createState() => _PictureWordMatchGameScreenState();
}

class _PictureWordMatchGameScreenState extends ConsumerState<PictureWordMatchGameScreen> {
  static const List<WordPictureCard> _cards = [
    WordPictureCard(
      id: 'apple',
      nameHi: 'सेब (Apple)',
      nameEn: 'Apple',
      icon: Icons.apple_rounded,
      color: Color(0xFFC62828),
      distractorsHi: ['केला (Banana)', 'आम (Mango)'],
    ),
    WordPictureCard(
      id: 'house',
      nameHi: 'घर (House)',
      nameEn: 'House',
      icon: Icons.home_rounded,
      color: Color(0xFF00695C),
      distractorsHi: ['गाड़ी (Car)', 'दुकान (Shop)'],
    ),
    WordPictureCard(
      id: 'tree',
      nameHi: 'पेड़ (Tree)',
      nameEn: 'Tree',
      icon: Icons.park_rounded,
      color: Color(0xFF2E7D32),
      distractorsHi: ['पहाड़ (Mountain)', 'नदी (River)'],
    ),
    WordPictureCard(
      id: 'clock',
      nameHi: 'घड़ी (Clock)',
      nameEn: 'Clock',
      icon: Icons.access_time_filled_rounded,
      color: Color(0xFFE65100),
      distractorsHi: ['किताब (Book)', 'चश्मा (Glasses)'],
    ),
  ];

  final _rng = math.Random();
  final _stopwatch = Stopwatch();

  int _round = 0;
  int _correctCount = 0;
  late WordPictureCard _currentCard;
  late List<String> _shuffledWordOptions;
  String? _selectedWord;
  bool _isAnswered = false;
  Timer? _nextRoundTimer;

  @override
  void initState() {
    super.initState();
    _startRound();
  }

  @override
  void dispose() {
    _nextRoundTimer?.cancel();
    super.dispose();
  }

  void _startRound() {
    _selectedWord = null;
    _isAnswered = false;
    _currentCard = _cards[_round];

    _shuffledWordOptions = [
      _currentCard.nameHi,
      ..._currentCard.distractorsHi,
    ]..shuffle(_rng);

    _stopwatch
      ..reset()
      ..start();

    ref.read(ttsServiceProvider).speak(
          'What is in this picture? Is tasveer mein kya hai?',
          langCode: 'hi',
        );

    setState(() {});
  }

  void _onWordSelected(String word) {
    if (_isAnswered) return;

    final isCorrect = word == _currentCard.nameHi;
    _stopwatch.stop();
    final elapsedMs = _stopwatch.elapsedMilliseconds;

    setState(() {
      _selectedWord = word;
      _isAnswered = true;
      if (isCorrect) _correctCount++;
    });

    final patientId = ref.read(deviceIdentityProvider).valueOrNull?.patientId ?? 'patient-local';
    final event = TelemetryEvent(
      patientId: patientId,
      gameId: 'picture-word-match',
      reactionMs: elapsedMs,
      spatialErrorPx: isCorrect ? 0.0 : 1.0,
      patternErrors: isCorrect ? 0 : 1,
      capturedAt: DateTime.now(),
    );
    ref.read(syncManagerProvider.notifier).enqueue(event);

    if (isCorrect) {
      ref.read(ttsServiceProvider).speak('बिल्कुल सही! यह ${_currentCard.nameHi} है।', langCode: 'hi');
    } else {
      ref.read(ttsServiceProvider).speak('यह ${_currentCard.nameHi} है। आगे बढ़ते हैं।', langCode: 'hi');
    }

    _nextRoundTimer?.cancel();
    _nextRoundTimer = Timer(const Duration(milliseconds: 1700), () {
      if (!mounted) return;
      if (_round + 1 < _cards.length) {
        setState(() => _round++);
        _startRound();
      } else {
        _showCompletion();
      }
    });
  }

  void _showCompletion() {
    final stars = _correctCount >= 3 ? 3 : (_correctCount >= 2 ? 2 : 1);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => GameCompletionDialog(
        title: 'शाबाश! (Bravo!)',
        subtitle: 'You matched $_correctCount/${_cards.length} picture words correctly!',
        stars: stars,
        onPlayAgain: () {
          setState(() {
            _round = 0;
            _correctCount = 0;
          });
          _startRound();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9E6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 32, color: Color(0xFF00695C)),
          onPressed: () => context.go('/games'),
        ),
        title: const Text(
          'Picture → Word Match',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF00695C)),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF00695C).withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_round + 1} / ${_cards.length}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF00695C)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Picture Card
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: _currentCard.color, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: _currentCard.color.withOpacity(0.15),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(_currentCard.icon, size: 84, color: _currentCard.color),
                    const SizedBox(height: 12),
                    const Text(
                      'What is this picture called?\n(इस तस्वीर का नाम क्या है?)',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Select the correct word (सही शब्द चुनें):',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 14),

              // Options
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _shuffledWordOptions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final word = _shuffledWordOptions[index];
                    final isSelected = _selectedWord == word;
                    final isCorrect = word == _currentCard.nameHi;

                    Color cardBg = Colors.white;
                    Color cardBorder = const Color(0xFF00695C).withOpacity(0.3);
                    if (_isAnswered) {
                      if (isCorrect) {
                        cardBg = const Color(0xFFE8F5E9);
                        cardBorder = const Color(0xFF2E7D32);
                      } else if (isSelected) {
                        cardBg = const Color(0xFFFFEBEE);
                        cardBorder = const Color(0xFFC62828);
                      }
                    }

                    return InkWell(
                      onTap: () => _onWordSelected(word),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: cardBorder, width: isSelected || (isCorrect && _isAnswered) ? 3 : 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00695C).withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF00695C)),
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Text(
                                word,
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),
                            if (_isAnswered)
                              Icon(
                                isCorrect ? Icons.check_circle_rounded : (isSelected ? Icons.cancel_rounded : null),
                                color: isCorrect ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                                size: 28,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
