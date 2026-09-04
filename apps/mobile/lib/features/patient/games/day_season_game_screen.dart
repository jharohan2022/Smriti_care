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

class OrientationOption {
  const OrientationOption({
    required this.id,
    required this.titleHi,
    required this.titleEn,
    required this.icon,
    required this.color,
  });

  final String id;
  final String titleHi;
  final String titleEn;
  final IconData icon;
  final Color color;
}

class OrientationQuestion {
  const OrientationQuestion({
    required this.promptHi,
    required this.promptEn,
    required this.correctId,
    required this.options,
  });

  final String promptHi;
  final String promptEn;
  final String correctId;
  final List<OrientationOption> options;
}

/// Orientation & Reality Anchoring assessment:
/// Prompts the patient on time of day (Morning/Night), seasons (Rain/Summer),
/// and daily time landmarks to ground orientation.
class DaySeasonGameScreen extends ConsumerStatefulWidget {
  const DaySeasonGameScreen({super.key});

  @override
  ConsumerState<DaySeasonGameScreen> createState() => _DaySeasonGameScreenState();
}

class _DaySeasonGameScreenState extends ConsumerState<DaySeasonGameScreen> {
  late List<OrientationQuestion> _questions;
  int _round = 0;
  int _correctCount = 0;
  String? _selectedId;
  bool _isAnswered = false;
  final _stopwatch = Stopwatch();
  Timer? _nextRoundTimer;

  @override
  void initState() {
    super.initState();
    _initQuestions();
    _startRound();
  }

  @override
  void dispose() {
    _nextRoundTimer?.cancel();
    super.dispose();
  }

  void _initQuestions() {
    _questions = [
      const OrientationQuestion(
        promptHi: 'जब सूरज उगता है, तो कौन सा समय होता है?',
        promptEn: 'When the sun rises, what time of day is it?',
        correctId: 'morning',
        options: [
          OrientationOption(
            id: 'morning',
            titleHi: 'सुबह (Morning 🌅)',
            titleEn: 'Morning',
            icon: Icons.wb_sunny_rounded,
            color: Color(0xFFFFA000),
          ),
          OrientationOption(
            id: 'night',
            titleHi: 'रात (Night 🌙)',
            titleEn: 'Night',
            icon: Icons.bedtime_rounded,
            color: Color(0xFF3949AB),
          ),
        ],
      ),
      const OrientationQuestion(
        promptHi: 'जब आसमान से पानी गिरता है, तो कौन सा मौसम होता है?',
        promptEn: 'When water falls from the sky, which season is it?',
        correctId: 'rain',
        options: [
          OrientationOption(
            id: 'rain',
            titleHi: 'बारिश का मौसम (Monsoon 🌧️)',
            titleEn: 'Monsoon Rain',
            icon: Icons.umbrella_rounded,
            color: Color(0xFF0288D1),
          ),
          OrientationOption(
            id: 'summer',
            titleHi: 'तेज़ धूप (Summer Sun ☀️)',
            titleEn: 'Summer Sun',
            icon: Icons.sunny,
            color: Color(0xFFE65100),
          ),
        ],
      ),
      const OrientationQuestion(
        promptHi: 'जब आसमान में तारे और चाँद दिखते हैं, तो क्या होता है?',
        promptEn: 'When stars and moon shine in the sky, what time is it?',
        correctId: 'night',
        options: [
          OrientationOption(
            id: 'afternoon',
            titleHi: 'दोपहर (Afternoon ☀️)',
            titleEn: 'Afternoon',
            icon: Icons.wb_twilight_rounded,
            color: Color(0xFFFB8C00),
          ),
          OrientationOption(
            id: 'night',
            titleHi: 'रात का समय (Night Time 🌌)',
            titleEn: 'Night Time',
            icon: Icons.nightlight_round,
            color: Color(0xFF283593),
          ),
        ],
      ),
    ];
  }

  void _startRound() {
    _selectedId = null;
    _isAnswered = false;

    _stopwatch
      ..reset()
      ..start();

    final q = _questions[_round];
    ref.read(ttsServiceProvider).speak(
          '${q.promptHi} ${q.promptEn}',
          langCode: 'hi',
        );

    setState(() {});
  }

  void _onOptionSelected(OrientationOption option) {
    if (_isAnswered) return;

    final q = _questions[_round];
    final isCorrect = option.id == q.correctId;
    _stopwatch.stop();
    final elapsedMs = _stopwatch.elapsedMilliseconds;

    setState(() {
      _selectedId = option.id;
      _isAnswered = true;
      if (isCorrect) _correctCount++;
    });

    final patientId = ref.read(deviceIdentityProvider).valueOrNull?.patientId ?? 'patient-local';
    final event = TelemetryEvent(
      patientId: patientId,
      gameId: 'day-season-orientation',
      reactionMs: elapsedMs,
      spatialErrorPx: isCorrect ? 0.0 : 1.0,
      patternErrors: isCorrect ? 0 : 1,
      capturedAt: DateTime.now(),
    );
    ref.read(syncManagerProvider.notifier).enqueue(event);

    if (isCorrect) {
      ref.read(ttsServiceProvider).speak('शाबाश! बिल्कुल सही समय। (Correct!)', langCode: 'hi');
    } else {
      ref.read(ttsServiceProvider).speak('आगे बढ़ते हैं।', langCode: 'hi');
    }

    _nextRoundTimer?.cancel();
    _nextRoundTimer = Timer(const Duration(milliseconds: 1700), () {
      if (!mounted) return;
      if (_round + 1 < _questions.length) {
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
        title: 'उत्कृष्ट समझ! (Great Orientation!)',
        subtitle: 'You answered $_correctCount/${_questions.length} day and season questions correctly!',
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
    final q = _questions[_round];

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
          'Day & Season Game',
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
              '${_round + 1} / ${_questions.length}',
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
              // Question Card
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: const Color(0xFFFFD54F), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(Icons.calendar_month_rounded, size: 48, color: Color(0xFF00695C)),
                    const SizedBox(height: 12),
                    Text(
                      q.promptHi,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      q.promptEn,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'Choose the correct answer (सही उत्तर चुनें):',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 14),

              // Options
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: q.options.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final opt = q.options[index];
                    final isSelected = _selectedId == opt.id;
                    final isCorrect = opt.id == q.correctId;

                    Color cardBg = Colors.white;
                    Color cardBorder = opt.color.withOpacity(0.4);
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
                      onTap: () => _onOptionSelected(opt),
                      borderRadius: BorderRadius.circular(22),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(22),
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
                                color: opt.color.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(opt.icon, size: 38, color: opt.color),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Text(
                                opt.titleHi,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),
                            if (_isAnswered)
                              Icon(
                                isCorrect ? Icons.check_circle_rounded : (isSelected ? Icons.cancel_rounded : null),
                                color: isCorrect ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                                size: 30,
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
