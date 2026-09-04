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

class PatternElement {
  const PatternElement({
    required this.id,
    required this.nameHi,
    required this.nameEn,
    required this.icon,
    required this.color,
  });

  final String id;
  final String nameHi;
  final String nameEn;
  final IconData icon;
  final Color color;
}

class PatternPuzzle {
  const PatternPuzzle({
    required this.sequence,
    required this.correctAnswer,
    required this.options,
    required this.description,
  });

  final List<PatternElement> sequence;
  final PatternElement correctAnswer;
  final List<PatternElement> options;
  final String description;
}

/// Reasoning & Problem-Solving Assessment:
/// Displays an alternating sequence (e.g. A, B, A, B, ?) and prompts
/// the patient to select the missing element that completes the pattern.
class CompletePatternGameScreen extends ConsumerStatefulWidget {
  const CompletePatternGameScreen({super.key});

  @override
  ConsumerState<CompletePatternGameScreen> createState() => _CompletePatternGameScreenState();
}

class _CompletePatternGameScreenState extends ConsumerState<CompletePatternGameScreen> {
  static const _sun = PatternElement(id: 'sun', nameHi: 'सूरज (Sun)', nameEn: 'Sun', icon: Icons.wb_sunny_rounded, color: Color(0xFFFFA000));
  static const _moon = PatternElement(id: 'moon', nameHi: 'चाँद (Moon)', nameEn: 'Moon', icon: Icons.nightlight_round, color: Color(0xFF5C6BC0));
  static const _circle = PatternElement(id: 'circle', nameHi: 'लाल गोला (Red Circle)', nameEn: 'Red Circle', icon: Icons.circle, color: Color(0xFFE53935));
  static const _square = PatternElement(id: 'square', nameHi: 'नीला चौकोर (Blue Square)', nameEn: 'Blue Square', icon: Icons.crop_square_rounded, color: Color(0xFF1E88E5));
  static const _leaf = PatternElement(id: 'leaf', nameHi: 'पत्ता (Leaf)', nameEn: 'Leaf', icon: Icons.eco_rounded, color: Color(0xFF43A047));
  static const _flower = PatternElement(id: 'flower', nameHi: 'गुलाब (Flower)', nameEn: 'Flower', icon: Icons.local_florist_rounded, color: Color(0xFFD81B60));
  static const _star = PatternElement(id: 'star', nameHi: 'तारा (Star)', nameEn: 'Star', icon: Icons.star_rounded, color: Color(0xFFFB8C00));

  late List<PatternPuzzle> _puzzles;
  int _round = 0;
  int _correctCount = 0;
  PatternElement? _selectedOption;
  bool _isAnswered = false;
  final _stopwatch = Stopwatch();
  Timer? _nextRoundTimer;

  @override
  void initState() {
    super.initState();
    _initPuzzles();
    _startRound();
  }

  @override
  void dispose() {
    _nextRoundTimer?.cancel();
    super.dispose();
  }

  void _initPuzzles() {
    _puzzles = [
      const PatternPuzzle(
        sequence: [_sun, _moon, _sun, _moon],
        correctAnswer: _sun,
        options: [_sun, _moon, _leaf],
        description: 'Sun, Moon, Sun, Moon... What comes next?',
      ),
      const PatternPuzzle(
        sequence: [_circle, _square, _circle, _square],
        correctAnswer: _circle,
        options: [_circle, _square, _star],
        description: 'Circle, Square, Circle, Square... What comes next?',
      ),
      const PatternPuzzle(
        sequence: [_leaf, _flower, _leaf, _flower],
        correctAnswer: _leaf,
        options: [_flower, _leaf, _sun],
        description: 'Leaf, Flower, Leaf, Flower... What comes next?',
      ),
      const PatternPuzzle(
        sequence: [_star, _circle, _star, _circle],
        correctAnswer: _star,
        options: [_moon, _circle, _star],
        description: 'Star, Circle, Star, Circle... What comes next?',
      ),
    ];
  }

  void _startRound() {
    _selectedOption = null;
    _isAnswered = false;

    _stopwatch
      ..reset()
      ..start();

    final puzzle = _puzzles[_round];
    ref.read(ttsServiceProvider).speak(
          'Complete the pattern. Is pattern ko pura kijiye: ${puzzle.description}',
          langCode: 'hi',
        );

    setState(() {});
  }

  void _onOptionSelected(PatternElement selected) {
    if (_isAnswered) return;

    final puzzle = _puzzles[_round];
    final isCorrect = selected.id == puzzle.correctAnswer.id;

    _stopwatch.stop();
    final elapsedMs = _stopwatch.elapsedMilliseconds;

    setState(() {
      _selectedOption = selected;
      _isAnswered = true;
      if (isCorrect) _correctCount++;
    });

    final patientId = ref.read(deviceIdentityProvider).valueOrNull?.patientId ?? 'patient-local';
    final event = TelemetryEvent(
      patientId: patientId,
      gameId: 'complete-pattern',
      reactionMs: elapsedMs,
      spatialErrorPx: isCorrect ? 0.0 : 1.0,
      patternErrors: isCorrect ? 0 : 1,
      capturedAt: DateTime.now(),
    );
    ref.read(syncManagerProvider.notifier).enqueue(event);

    if (isCorrect) {
      ref.read(ttsServiceProvider).speak('शाबाश! बिल्कुल सही पैटर्न! (Correct pattern!)', langCode: 'hi');
    } else {
      ref.read(ttsServiceProvider).speak('सही जवाब ${puzzle.correctAnswer.nameHi} है। आगे बढ़ते हैं।', langCode: 'hi');
    }

    _nextRoundTimer?.cancel();
    _nextRoundTimer = Timer(const Duration(milliseconds: 1700), () {
      if (!mounted) return;
      if (_round + 1 < _puzzles.length) {
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
        title: 'अद्भुत तर्कशक्ति! (Great Reasoning!)',
        subtitle: 'You completed $_correctCount/${_puzzles.length} patterns successfully!',
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
    final puzzle = _puzzles[_round];

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
          'Complete the Pattern',
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
              '${_round + 1} / ${_puzzles.length}',
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
              // Prompt Question
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFFFD54F), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(Icons.extension_rounded, size: 36, color: Color(0xFF00695C)),
                    SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'What comes in the question mark (❓)?\n(क्रम में अगला क्या आएगा?)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Pattern Display Sequence Row
              Container(
                padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.purple.shade200, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ...puzzle.sequence.map((item) {
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: item.color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(item.icon, size: 38, color: item.color),
                      );
                    }),
                    // Question Mark Slot
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _isAnswered
                            ? (_selectedOption?.id == puzzle.correctAnswer.id
                                ? const Color(0xFFE8F5E9)
                                : const Color(0xFFFFEBEE))
                            : const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _isAnswered
                              ? (_selectedOption?.id == puzzle.correctAnswer.id
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFFC62828))
                              : const Color(0xFFFFA000),
                          width: 2.5,
                        ),
                      ),
                      child: _isAnswered && _selectedOption != null
                          ? Icon(_selectedOption!.icon, size: 38, color: _selectedOption!.color)
                          : const Text(
                              '❓',
                              style: TextStyle(fontSize: 28),
                            ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              const Text(
                'Choose the missing symbol (सही विकल्प चुनें):',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 14),

              // Options
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: puzzle.options.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final option = puzzle.options[index];
                    final isSelected = _selectedOption?.id == option.id;
                    final isCorrect = option.id == puzzle.correctAnswer.id;

                    Color cardBg = Colors.white;
                    Color cardBorder = option.color.withOpacity(0.4);
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
                      onTap: () => _onOptionSelected(option),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: option.color.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(option.icon, size: 34, color: option.color),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Text(
                                option.nameHi,
                                style: const TextStyle(
                                  fontSize: 18,
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
