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

class DailyStep {
  const DailyStep({
    required this.id,
    required this.stepNumber,
    required this.titleHi,
    required this.titleEn,
    required this.icon,
    required this.color,
  });

  final String id;
  final int stepNumber;
  final String titleHi;
  final String titleEn;
  final IconData icon;
  final Color color;
}

class DailyRoutineScenario {
  const DailyRoutineScenario({
    required this.titleHi,
    required this.titleEn,
    required this.steps,
  });

  final String titleHi;
  final String titleEn;
  final List<DailyStep> steps;
}

/// Executive Function & Daily Sequencing Assessment:
/// Displays 3 daily routine activities shuffled, and prompts the patient
/// to tap them in the correct sequential order (Step 1 -> Step 2 -> Step 3).
class DailySequencingGameScreen extends ConsumerStatefulWidget {
  const DailySequencingGameScreen({super.key});

  @override
  ConsumerState<DailySequencingGameScreen> createState() => _DailySequencingGameScreenState();
}

class _DailySequencingGameScreenState extends ConsumerState<DailySequencingGameScreen> {
  static const List<DailyRoutineScenario> _scenarios = [
    DailyRoutineScenario(
      titleHi: 'सुबह की दिनचर्या (Morning Routine)',
      titleEn: 'Morning Routine',
      steps: [
        DailyStep(
          id: 'step1',
          stepNumber: 1,
          titleHi: '1. सोकर उठना (Wake up 🌅)',
          titleEn: '1. Wake Up',
          icon: Icons.wb_sunny_rounded,
          color: Color(0xFFFFA000),
        ),
        DailyStep(
          id: 'step2',
          stepNumber: 2,
          titleHi: '2. दाँत साफ करना (Brush Teeth 🪥)',
          titleEn: '2. Brush Teeth',
          icon: Icons.clean_hands_rounded,
          color: Color(0xFF0288D1),
        ),
        DailyStep(
          id: 'step3',
          stepNumber: 3,
          titleHi: '3. चाय और नाश्ता (Chai & Breakfast ☕)',
          titleEn: '3. Breakfast',
          icon: Icons.free_breakfast_rounded,
          color: Color(0xFF6D4C41),
        ),
      ],
    ),
    DailyRoutineScenario(
      titleHi: 'दवा और आराम (Medicine & Rest)',
      titleEn: 'Medicine & Evening Rest',
      steps: [
        DailyStep(
          id: 'step1_med',
          stepNumber: 1,
          titleHi: '1. समय पर पानी पीना (Drink Water 💧)',
          titleEn: '1. Drink Water',
          icon: Icons.water_drop_rounded,
          color: Color(0xFF1976D2),
        ),
        DailyStep(
          id: 'step2_med',
          stepNumber: 2,
          titleHi: '2. दवा लेना (Take Medicine 💊)',
          titleEn: '2. Take Medicine',
          icon: Icons.medication_rounded,
          color: Color(0xFFE53935),
        ),
        DailyStep(
          id: 'step3_med',
          stepNumber: 3,
          titleHi: '3. आराम करना (Rest & Sleep 🛌)',
          titleEn: '3. Rest & Sleep',
          icon: Icons.bedtime_rounded,
          color: Color(0xFF5C6BC0),
        ),
      ],
    ),
  ];

  final _rng = math.Random();
  final _stopwatch = Stopwatch();

  int _round = 0;
  int _mistakes = 0;
  int _currentStepNeeded = 1;
  late List<DailyStep> _shuffledCards;
  final List<String> _completedStepIds = [];
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
    _currentStepNeeded = 1;
    _completedStepIds.clear();

    final scenario = _scenarios[_round];
    _shuffledCards = List.of(scenario.steps)..shuffle(_rng);

    _stopwatch
      ..reset()
      ..start();

    ref.read(ttsServiceProvider).speak(
          'Arrange these 3 activities in order. Pehle kya karte hain, phir kya? ${scenario.titleHi}',
          langCode: 'hi',
        );

    setState(() {});
  }

  void _onStepCardTapped(DailyStep step) {
    if (_completedStepIds.contains(step.id)) return;

    if (step.stepNumber == _currentStepNeeded) {
      // Correct sequential tap
      setState(() {
        _completedStepIds.add(step.id);
        _currentStepNeeded++;
      });

      ref.read(ttsServiceProvider).speak('शाबाश! (Good!)', langCode: 'hi');

      if (_completedStepIds.length >= 3) {
        _finishRound();
      }
    } else {
      // Mistake in sequence
      setState(() => _mistakes++);
      ref.read(ttsServiceProvider).speak(
            'पहले कौन सा काम करते हैं? Pehle wala step chuniye.',
            langCode: 'hi',
          );
    }
  }

  void _finishRound() {
    _stopwatch.stop();
    final elapsedMs = _stopwatch.elapsedMilliseconds;

    final patientId = ref.read(deviceIdentityProvider).valueOrNull?.patientId ?? 'patient-local';
    final event = TelemetryEvent(
      patientId: patientId,
      gameId: 'daily-sequencing-executive',
      reactionMs: elapsedMs,
      spatialErrorPx: _mistakes.toDouble(),
      patternErrors: _mistakes,
      capturedAt: DateTime.now(),
    );
    ref.read(syncManagerProvider.notifier).enqueue(event);

    _nextRoundTimer?.cancel();
    _nextRoundTimer = Timer(const Duration(milliseconds: 1700), () {
      if (!mounted) return;
      if (_round + 1 < _scenarios.length) {
        setState(() => _round++);
        _startRound();
      } else {
        _showCompletion();
      }
    });
  }

  void _showCompletion() {
    final stars = _mistakes == 0 ? 3 : (_mistakes <= 2 ? 2 : 1);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => GameCompletionDialog(
        title: 'अद्भुत व्यवस्था! (Great Sequencing!)',
        subtitle: 'You arranged all daily routines in correct chronological order!',
        stars: stars,
        onPlayAgain: () {
          setState(() {
            _round = 0;
            _mistakes = 0;
          });
          _startRound();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scenario = _scenarios[_round];

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
          'Arrange Activities',
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
              '${_round + 1} / ${_scenarios.length}',
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
              // Prompt Banner
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFFFD54F), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.format_list_numbered_rounded, size: 36, color: Color(0xFF00695C)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            scenario.titleHi,
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Tap in order: Step $_currentStepNeeded of 3',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF00695C)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Tap cards in the right daily order (क्रम में छुएं):',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 14),

              // Activity Cards
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _shuffledCards.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final step = _shuffledCards[index];
                    final isDone = _completedStepIds.contains(step.id);

                    Color cardBg = isDone ? const Color(0xFFE8F5E9) : Colors.white;
                    Color cardBorder = isDone ? const Color(0xFF2E7D32) : step.color.withOpacity(0.4);

                    return InkWell(
                      onTap: () => _onStepCardTapped(step),
                      borderRadius: BorderRadius.circular(22),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: cardBorder, width: isDone ? 3 : 2),
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
                                color: isDone ? const Color(0xFF2E7D32).withOpacity(0.15) : step.color.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(step.icon, size: 36, color: isDone ? const Color(0xFF2E7D32) : step.color),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Text(
                                step.titleHi,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: isDone ? const Color(0xFF1B5E20) : const Color(0xFF0F172A),
                                ),
                              ),
                            ),
                            if (isDone)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFF2E7D32),
                                size: 32,
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
